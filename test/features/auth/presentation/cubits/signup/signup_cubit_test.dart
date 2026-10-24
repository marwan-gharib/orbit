import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/features/auth/domain/entities/signup_result_entity.dart';
import 'package:orbit/features/auth/domain/params/signup_params.dart';
import 'package:orbit/features/auth/domain/usecases/signup_usecase.dart';
import 'package:orbit/features/auth/presentation/cubits/signup/signup_cubit.dart';
import 'package:orbit/features/auth/presentation/cubits/signup/signup_state.dart';

class MockSignupUseCase extends Mock implements SignupUseCase {}

const tResult = SignupResult(
  firstName: 'Adam',
  lastName: 'Orbit',
  email: 'adam@orbit.app',
);

const tFailure = ValidationFailure(message: 'email taken');

void main() {
  late MockSignupUseCase signupUseCase;

  setUpAll(() {
    registerFallbackValue(
      const SignupParams(
        firstName: '',
        lastName: '',
        workEmail: '',
        password: '',
      ),
    );
  });

  setUp(() {
    signupUseCase = MockSignupUseCase();
  });

  SignupCubit newCubit() => SignupCubit(signupUseCase);

  group('SignupCubit', () {
    final pending = Completer<ApiResult<SignupResult>>();

    test('should have SignupInitial as the initial state', () {
      expect(newCubit().state, const SignupInitial());
    });

    blocTest<SignupCubit, SignupState>(
      'should emit Loading then Success carrying the created account',
      build: () {
        when(() => signupUseCase(any()))
            .thenAnswer((_) async => const Success(tResult));
        return newCubit();
      },
      act: (cubit) => cubit.signup(
        firstName: 'Adam',
        lastName: 'Orbit',
        workEmail: 'adam@orbit.app',
        password: 'secret',
      ),
      expect: () => [
        isA<SignupLoading>(),
        isA<SignupSuccess>().having((s) => s.result, 'result', tResult),
      ],
    );

    blocTest<SignupCubit, SignupState>(
      'should emit Loading then Error carrying the failure',
      build: () {
        when(() => signupUseCase(any()))
            .thenAnswer((_) async => const ResultFailure(tFailure));
        return newCubit();
      },
      act: (cubit) => cubit.signup(
        firstName: 'Adam',
        lastName: 'Orbit',
        workEmail: 'adam@orbit.app',
        password: 'secret',
      ),
      expect: () => [
        isA<SignupLoading>(),
        isA<SignupError>().having((s) => s.failure, 'failure', tFailure),
      ],
    );

    blocTest<SignupCubit, SignupState>(
      'should ignore a second submission while one is in flight',
      build: () {
        when(() => signupUseCase(any()))
            .thenAnswer((_) async => pending.future);
        return newCubit();
      },
      act: (cubit) async {
        final first = cubit.signup(
          firstName: 'Adam',
          lastName: 'Orbit',
          workEmail: 'adam@orbit.app',
          password: 'secret',
        );
        await Future<void>.delayed(Duration.zero);
        await cubit.signup(
          firstName: 'Adam',
          lastName: 'Orbit',
          workEmail: 'adam@orbit.app',
          password: 'secret',
        );
        pending.complete(const Success(tResult));
        await first;
      },
      expect: () => [
        isA<SignupLoading>(),
        isA<SignupSuccess>().having((s) => s.result, 'result', tResult),
      ],
      verify: (_) => verify(() => signupUseCase(any())).called(1),
    );
  });
}
