import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/errors/exceptions.dart';
import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/features/auth/domain/entities/auth_session_entity.dart';
import 'package:orbit/features/auth/domain/entities/permission_entity.dart';
import 'package:orbit/features/auth/domain/entities/user_entity.dart';
import 'package:orbit/features/auth/domain/enums/user_role.dart';
import 'package:orbit/features/auth/domain/usecases/login_usecase.dart';
import 'package:orbit/features/auth/domain/params/login_params.dart';
import 'package:orbit/features/auth/presentation/cubits/login/login_cubit.dart';
import 'package:orbit/features/auth/presentation/cubits/login/login_state.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

const tUser = User(
  firstName: 'Adam',
  lastName: 'Orbit',
  code: 'EMP-2026-9582',
  email: 'adam@orbit.app',
  role: UserRole.admin,
  roleName: 'Admin',
  permissions: [Permission(module: 'projects', permission: 'view')],
);

const tSession = AuthSession(
  accessToken: 'access-1',
  refreshToken: 'refresh-1',
  user: tUser,
);

void main() {
  late MockLoginUseCase loginUseCase;

  setUpAll(() {
    registerFallbackValue(const LoginParams(email: '', password: ''));
  });

  setUp(() {
    loginUseCase = MockLoginUseCase();
  });

  LoginCubit newCubit() => LoginCubit(loginUseCase);

  group('LoginCubit', () {
    final pending = Completer<ApiResult<AuthSession>>();

    test('should have LoginInitial as the initial state', () {
      expect(newCubit().state, const LoginInitial());
    });

    blocTest<LoginCubit, LoginState>(
      'should emit Loading then Success carrying the session',
      build: () {
        when(() => loginUseCase(any()))
            .thenAnswer((_) async => const Success(tSession));
        return newCubit();
      },
      act: (cubit) => cubit.login(email: 'adam@orbit.app', password: 'secret'),
      expect: () => [
        isA<LoginLoading>(),
        isA<LoginSuccess>().having((s) => s.session, 'session', tSession),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'should emit Loading then Error carrying the failure',
      build: () {
        const tFailure = NetworkFailure(
          message: 'offline',
          reason: NetworkErrorReason.noInternet,
        );
        when(() => loginUseCase(any()))
            .thenAnswer((_) async => const ResultFailure(tFailure));
        return newCubit();
      },
      act: (cubit) => cubit.login(email: 'adam@orbit.app', password: 'secret'),
      expect: () => [
        isA<LoginLoading>(),
        isA<LoginError>().having(
          (s) => s.failure,
          'failure',
          isA<NetworkFailure>().having(
            (f) => f.reason,
            'reason',
            NetworkErrorReason.noInternet,
          ),
        ),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'should surface InvalidCredentialsFailure from a login 401 (B4)',
      build: () {
        when(() => loginUseCase(any())).thenAnswer(
          (_) async => const ResultFailure(
            InvalidCredentialsFailure(message: 'wrong credentials'),
          ),
        );
        return newCubit();
      },
      act: (cubit) => cubit.login(email: 'adam@orbit.app', password: 'secret'),
      expect: () => [
        isA<LoginLoading>(),
        isA<LoginError>().having(
          (s) => s.failure,
          'failure',
          isA<InvalidCredentialsFailure>(),
        ),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'should ignore a second submission while one is in flight',
      build: () {
        when(() => loginUseCase(any())).thenAnswer((_) async => pending.future);
        return newCubit();
      },
      act: (cubit) async {
        final first = cubit.login(email: 'adam@orbit.app', password: 'secret');
        // Let the first call reach `LoginLoading` before the second one.
        await Future<void>.delayed(Duration.zero);
        await cubit.login(email: 'adam@orbit.app', password: 'secret');
        pending.complete(const Success(tSession));
        await first;
      },
      expect: () => [
        isA<LoginLoading>(),
        isA<LoginSuccess>().having((s) => s.session, 'session', tSession),
      ],
      verify: (_) => verify(() => loginUseCase(any())).called(1),
    );

    blocTest<LoginCubit, LoginState>(
      'should allow a new submission after a failure',
      build: () {
        var attempts = 0;
        when(() => loginUseCase(any())).thenAnswer((_) async {
          attempts += 1;
          return attempts == 1
              ? const ResultFailure(InvalidCredentialsFailure(message: 'wrong'))
              : const Success(tSession);
        });
        return newCubit();
      },
      act: (cubit) async {
        await cubit.login(email: 'adam@orbit.app', password: 'bad');
        await cubit.login(email: 'adam@orbit.app', password: 'secret');
      },
      expect: () => [
        isA<LoginLoading>(),
        isA<LoginError>(),
        isA<LoginLoading>(),
        isA<LoginSuccess>(),
      ],
      verify: (_) => verify(() => loginUseCase(any())).called(2),
    );
  });
}
