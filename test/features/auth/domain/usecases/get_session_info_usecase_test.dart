import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/features/auth/domain/entities/session_info_entity.dart';
import 'package:orbit/features/auth/domain/repositories/auth_repository.dart';
import 'package:orbit/features/auth/domain/usecases/get_session_info_usecase.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

const tInfo = SessionInfo(isAuthenticated: true);

void main() {
  late _MockAuthRepository repository;
  late GetSessionInfoUseCase useCase;

  setUp(() {
    repository = _MockAuthRepository();
    useCase = GetSessionInfoUseCase(repository);
  });

  test('should return the repository result without a call argument', () async {
    when(() => repository.getSessionInfo())
        .thenAnswer((_) async => const Success(tInfo));

    final result = await useCase();

    expect(result, const Success(tInfo));
    verify(() => repository.getSessionInfo()).called(1);
  });

  test('should return the repository failure untouched', () async {
    const tFailure = StorageFailure(message: 'read failed');
    when(() => repository.getSessionInfo())
        .thenAnswer((_) async => const ResultFailure(tFailure));

    final result = await useCase();

    expect(result, const ResultFailure<SessionInfo>(tFailure));
  });
}
