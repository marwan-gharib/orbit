import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/core/errors/exceptions.dart';
import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/features/auth/data/datasources/local/auth_local_data_source.dart';
import 'package:orbit/features/auth/data/datasources/remote/auth_remote_data_source.dart';
import 'package:orbit/features/auth/data/models/login_response_model.dart';
import 'package:orbit/features/auth/data/models/signup_response_model.dart';
import 'package:orbit/features/auth/data/models/user_model.dart';
import 'package:orbit/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:orbit/features/auth/domain/enums/user_role.dart';
import 'package:orbit/features/auth/domain/params/login_params.dart';
import 'package:orbit/features/auth/domain/params/signup_params.dart';

class _MockRemote extends Mock implements AuthRemoteDataSource {}

class _MockLocal extends Mock implements AuthLocalDataSource {}

final LoginResponseModel tSessionModel = LoginResponseModel(
  accessToken: 'access-1',
  refreshToken: 'refresh-1',
  user: UserModel.fromJson(const <String, dynamic>{
    ApiKeys.firstNameKey: 'Adam',
    ApiKeys.lastNameKey: 'Orbit',
    ApiKeys.codeKey: 'EMP-2026-9582',
    ApiKeys.emailKey: 'adam@orbit.app',
    ApiKeys.roleKey: 1,
    ApiKeys.roleNameKey: 'Admin',
    ApiKeys.permissionsKey: <Object?>[],
  }),
);

const tParams = LoginParams(email: 'adam@orbit.app', password: 'secret');

void main() {
  late _MockRemote remote;
  late _MockLocal local;
  late AuthRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(tParams);
    registerFallbackValue(
      const SignupParams(
        firstName: '',
        lastName: '',
        workEmail: '',
        password: '',
      ),
    );
    registerFallbackValue(
      const LoginResponseModel(
        accessToken: 'f',
        refreshToken: 'f',
        user: UserModel(
          firstName: 'f',
          lastName: 'f',
          code: 'f',
          email: 'f',
          role: UserRole.unknown,
          roleName: '',
          permissions: [],
        ),
      ),
    );
  });

  setUp(() {
    remote = _MockRemote();
    local = _MockLocal();
    repository = AuthRepositoryImpl(remote, local);
  });

  group('login', () {
    test(
      'should persist the session and return the entity on success',
      () async {
        when(() => remote.login(any()))
            .thenAnswer((_) async => Success(tSessionModel));
        when(() => local.saveSession(any()))
            .thenAnswer((_) async => const Success<void>(null));

        final result = await repository.login(tParams);

        expect(result.isSuccess, isTrue);
        final entity = (result as Success).data;
        expect(entity.accessToken, 'access-1');
        expect(entity.user.role, UserRole.admin);
        verifyInOrder([
          () => remote.login(tParams),
          () => local.saveSession(tSessionModel),
        ]);
      },
    );

    test(
      'should fail loudly and not return a session when saving fails (B6)',
      () async {
        const tSaveFailure = CacheFailure(message: 'cache down');
        when(() => remote.login(any()))
            .thenAnswer((_) async => Success(tSessionModel));
        when(() => local.saveSession(any()))
            .thenAnswer((_) async => const ResultFailure<void>(tSaveFailure));

        final result = await repository.login(tParams);

        expect(result.isSuccess, isFalse);
        expect((result as ResultFailure).failure, same(tSaveFailure));
      },
    );

    test('should pass remote failures through without persisting', () async {
      const tNetworkFailure = NetworkFailure(
        message: 'offline',
        reason: NetworkErrorReason.noInternet,
      );
      when(() => remote.login(any()))
          .thenAnswer((_) async => const ResultFailure(tNetworkFailure));

      final result = await repository.login(tParams);

      expect(result.isSuccess, isFalse);
      final failure = (result as ResultFailure).failure;
      expect(failure, isA<NetworkFailure>());
      expect((failure as NetworkFailure).reason, NetworkErrorReason.noInternet);
      verifyNever(() => local.saveSession(any()));
    });
  });

  group('signup', () {
    test('should return the echo entity without persisting anything', () async {
      when(() => remote.signup(any())).thenAnswer(
        (_) async => const Success(
          SignupResponseModel(
            firstName: 'Adam',
            lastName: 'Orbit',
            email: 'adam@orbit.app',
          ),
        ),
      );

      final result = await repository.signup(
        const SignupParams(
          firstName: 'Adam',
          lastName: 'Orbit',
          workEmail: 'adam@orbit.app',
          password: 'secret',
        ),
      );

      expect(result.isSuccess, isTrue);
      final entity = (result as Success).data;
      expect(entity.firstName, 'Adam');
      expect(entity.email, 'adam@orbit.app');
      verifyNever(() => local.saveSession(any()));
      verifyNever(() => local.clearSession());
    });

    test('should pass failures through without touching storage', () async {
      const tFailure = ValidationFailure(message: 'taken');
      when(() => remote.signup(any()))
          .thenAnswer((_) async => const ResultFailure(tFailure));

      final result = await repository.signup(
        const SignupParams(
          firstName: 'Adam',
          lastName: 'Orbit',
          workEmail: 'adam@orbit.app',
          password: 'secret',
        ),
      );

      expect((result as ResultFailure).failure, tFailure);
      verifyNever(() => local.saveSession(any()));
    });
  });
}
