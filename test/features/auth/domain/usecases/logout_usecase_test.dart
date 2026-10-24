import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/features/auth/domain/repositories/auth_repository.dart';
import 'package:orbit/features/auth/domain/usecases/logout_usecase.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repository;
  late LogoutUseCase useCase;

  setUp(() {
    repository = _MockAuthRepository();
    useCase = LogoutUseCase(repository);
  });

  test('should call the repository and return its success', () async {
    when(() => repository.logout())
        .thenAnswer((_) async => const Success<void>(null));

    final result = await useCase();

    expect(result.isSuccess, isTrue);
    verify(() => repository.logout()).called(1);
  });

  test('should return the repository failure untouched', () async {
    const tFailure = StorageFailure(message: 'clear failed');
    when(() => repository.logout())
        .thenAnswer((_) async => const ResultFailure<void>(tFailure));

    final result = await useCase();

    expect(result.isFailure, isTrue);
    expect((result as ResultFailure<void>).failure, tFailure);
  });
}
