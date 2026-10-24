import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/features/auth/data/datasources/local/auth_local_data_source.dart';
import 'package:orbit/features/auth/data/datasources/remote/auth_remote_data_source.dart';
import 'package:orbit/features/auth/data/models/employee_status_response_model.dart';
import 'package:orbit/features/auth/data/models/session_info_model.dart';
import 'package:orbit/features/auth/data/models/user_model.dart';
import 'package:orbit/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:orbit/features/auth/domain/enums/employment_status.dart';

class _MockRemote extends Mock implements AuthRemoteDataSource {}

class _MockLocal extends Mock implements AuthLocalDataSource {}

final UserModel tUserModel = UserModel.fromJson(const <String, dynamic>{
  ApiKeys.firstNameKey: 'Adam',
  ApiKeys.lastNameKey: 'Orbit',
  ApiKeys.codeKey: 'EMP-2026-9582',
  ApiKeys.emailKey: 'adam@orbit.app',
  ApiKeys.roleKey: 1,
  ApiKeys.roleNameKey: 'Admin',
  ApiKeys.permissionsKey: <Object?>[],
});

void main() {
  late _MockRemote remote;
  late _MockLocal local;
  late AuthRepositoryImpl repository;

  setUp(() {
    remote = _MockRemote();
    local = _MockLocal();
    repository = AuthRepositoryImpl(remote, local);
  });

  group('logout', () {
    test(
      'should revoke the refresh token then clear the local session (B10)',
      () async {
        when(() => local.readRefreshToken())
            .thenAnswer((_) async => const Success('refresh-1'));
        when(() => remote.logout(any()))
            .thenAnswer((_) async => const Success<void>(null));
        when(() => local.clearSession())
            .thenAnswer((_) async => const Success<void>(null));

        final result = await repository.logout();

        expect(result.isSuccess, isTrue);
        verifyInOrder([
          () => local.readRefreshToken(),
          () => remote.logout('refresh-1'),
          () => local.clearSession(),
        ]);
      },
    );

    test(
      'should clear locally even when the remote logout fails (B10)',
      () async {
        when(() => local.readRefreshToken())
            .thenAnswer((_) async => const Success('refresh-1'));
        when(() => remote.logout(any())).thenAnswer(
          (_) async => const ResultFailure<void>(
            RequestFailure(message: 'revocation failed'),
          ),
        );
        when(() => local.clearSession())
            .thenAnswer((_) async => const Success<void>(null));

        final result = await repository.logout();

        expect(result.isSuccess, isTrue);
        verifyInOrder([
          () => remote.logout('refresh-1'),
          () => local.clearSession(),
        ]);
      },
    );

    test('should skip the remote phase when no refresh token exists', () async {
      when(() => local.readRefreshToken())
          .thenAnswer((_) async => const Success<String?>(null));
      when(() => local.clearSession())
          .thenAnswer((_) async => const Success<void>(null));

      final result = await repository.logout();

      expect(result.isSuccess, isTrue);
      verifyNever(() => remote.logout(any()));
      verify(() => local.clearSession()).called(1);
    });

    test(
      'should skip the remote phase and still clear when the token read fails',
      () async {
        const tReadFailure = StorageFailure(message: 'keychain locked');
        when(
          () => local.readRefreshToken(),
        ).thenAnswer((_) async => const ResultFailure<String?>(tReadFailure));
        when(() => local.clearSession())
            .thenAnswer((_) async => const Success<void>(null));

        final result = await repository.logout();

        expect(result.isSuccess, isTrue);
        verifyNever(() => remote.logout(any()));
        verify(() => local.clearSession()).called(1);
      },
    );

    test(
      'should return the clear failure when the local clear fails',
      () async {
        when(() => local.readRefreshToken())
            .thenAnswer((_) async => const Success<String?>(null));
        const tClearFailure = StorageFailure(message: 'wiped');
        when(() => local.clearSession())
            .thenAnswer((_) async => const ResultFailure<void>(tClearFailure));

        final result = await repository.logout();

        expect((result as ResultFailure<void>).failure, tClearFailure);
      },
    );
  });

  group('getEmployeeStatus', () {
    const tPendingEmail = 'adam@orbit.app';

    void stubPendingEmail(String? email) {
      when(() => local.readPendingSignupEmail())
          .thenAnswer((_) async => Success<String?>(email));
    }

    test(
      'should check the persisted pending email and map the model',
      () async {
        stubPendingEmail(tPendingEmail);
        when(() => remote.getEmployeeStatus(tPendingEmail)).thenAnswer(
          (_) async => Success(
            EmployeeStatusResponseModel(
              firstName: 'Adam',
              lastName: 'Orbit',
              status: EmploymentStatus.pending,
            ),
          ),
        );

        final result = await repository.getEmployeeStatus();

        expect(result.isSuccess, isTrue);
        final entity = (result as Success).data;
        expect(entity.status, EmploymentStatus.pending);
        expect(entity.firstName, 'Adam');
        verify(() => remote.getEmployeeStatus(tPendingEmail)).called(1);
        verifyNever(() => local.clearCachedPendingSignupEmail());
      },
    );

    test(
      'should pass failures through without clearing the pending email',
      () async {
        stubPendingEmail(tPendingEmail);
        const tFailure = NotFoundFailure(message: 'no account');
        when(() => remote.getEmployeeStatus(tPendingEmail))
            .thenAnswer((_) async => const ResultFailure(tFailure));

        final result = await repository.getEmployeeStatus();

        expect((result as ResultFailure).failure, tFailure);
        verifyNever(() => local.clearCachedPendingSignupEmail());
      },
    );

    test(
      'should fail without a remote call when no email is persisted',
      () async {
        stubPendingEmail(null);

        final result = await repository.getEmployeeStatus();

        expect(result.isFailure, isTrue);
        verifyNever(() => remote.getEmployeeStatus(any()));
      },
    );

    test(
      'should fail without a remote call when the email cannot be read',
      () async {
        const tFailure = StorageFailure(message: 'cache unavailable');
        when(() => local.readPendingSignupEmail())
            .thenAnswer((_) async => const ResultFailure<String?>(tFailure));

        final result = await repository.getEmployeeStatus();

        expect((result as ResultFailure).failure, tFailure);
        verifyNever(() => remote.getEmployeeStatus(any()));
      },
    );

    test('should clear the persisted email on an approved status', () async {
      stubPendingEmail(tPendingEmail);
      when(() => remote.getEmployeeStatus(tPendingEmail)).thenAnswer(
        (_) async => const Success(
          EmployeeStatusResponseModel(
            firstName: 'Adam',
            lastName: 'Orbit',
            status: EmploymentStatus.approved,
          ),
        ),
      );
      when(() => local.clearCachedPendingSignupEmail())
          .thenAnswer((_) async => const Success<void>(null));

      final result = await repository.getEmployeeStatus();

      expect(result.isSuccess, isTrue);
      verify(() => local.clearCachedPendingSignupEmail()).called(1);
    });

    test('should clear the persisted email on a rejected status', () async {
      stubPendingEmail(tPendingEmail);
      when(() => remote.getEmployeeStatus(tPendingEmail)).thenAnswer(
        (_) async => const Success(
          EmployeeStatusResponseModel(
            firstName: 'Adam',
            lastName: 'Orbit',
            status: EmploymentStatus.rejected,
          ),
        ),
      );
      when(() => local.clearCachedPendingSignupEmail())
          .thenAnswer((_) async => const Success<void>(null));

      final result = await repository.getEmployeeStatus();

      expect(result.isSuccess, isTrue);
      verify(() => local.clearCachedPendingSignupEmail()).called(1);
    });
  });

  group('getSessionInfo', () {
    test('should map the local snapshot to its entity', () async {
      when(() => local.readSessionInfo()).thenAnswer(
        (_) async =>
            Success(SessionInfoModel(isAuthenticated: true, user: tUserModel)),
      );

      final result = await repository.getSessionInfo();

      expect(result.isSuccess, isTrue);
      final info = (result as Success).data;
      expect(info.isAuthenticated, isTrue);
      expect(info.user!.email, 'adam@orbit.app');
      verifyNever(() => remote.getEmployeeStatus(any()));
    });

    test('should pass failures through', () async {
      const tFailure = StorageFailure(message: 'read failed');
      when(() => local.readSessionInfo())
          .thenAnswer((_) async => const ResultFailure(tFailure));

      final result = await repository.getSessionInfo();

      expect((result as ResultFailure).failure, tFailure);
    });
  });
}
