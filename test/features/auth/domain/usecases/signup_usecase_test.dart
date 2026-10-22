import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/features/auth/domain/entities/signup_result_entity.dart';
import 'package:orbit/features/auth/domain/params/signup_params.dart';
import 'package:orbit/features/auth/domain/repositories/auth_repository.dart';
import 'package:orbit/features/auth/domain/usecases/signup_usecase.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

const tParams = SignupParams(
  firstName: 'Adam',
  lastName: 'Orbit',
  workEmail: 'adam@orbit.app',
  password: 'secret',
);

const tResult = SignupResult(
  firstName: 'Adam',
  lastName: 'Orbit',
  email: 'adam@orbit.app',
);

void main() {
  late _MockAuthRepository repository;
  late SignupUseCase useCase;

  setUpAll(() {
    registerFallbackValue(tParams);
  });

  setUp(() {
    repository = _MockAuthRepository();
    useCase = SignupUseCase(repository);
  });

  test(
    'should call the repository with the same params and return its result',
    () async {
      when(() => repository.signup(any()))
          .thenAnswer((_) async => const Success(tResult));

      final result = await useCase(tParams);

      expect(result, const Success(tResult));
      verify(() => repository.signup(tParams)).called(1);
    },
  );

  test('should return the repository failure untouched', () async {
    const tFailure = ValidationFailure(message: 'taken');
    when(() => repository.signup(any()))
        .thenAnswer((_) async => const ResultFailure(tFailure));

    final result = await useCase(tParams);

    expect(result, const ResultFailure<SignupResult>(tFailure));
  });
}
