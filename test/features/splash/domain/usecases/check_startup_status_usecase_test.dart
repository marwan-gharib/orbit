import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/features/splash/domain/repositories/splash_repository.dart';
import 'package:orbit/features/splash/domain/usecases/check_startup_status_usecase.dart';
import 'package:orbit/features/splash/domain/entities/splash_state_entity.dart';
import 'package:orbit/core/errors/failures.dart';

class MockSplashRepository extends Mock implements SplashRepository {}

void main() {
  late MockSplashRepository repository;
  late CheckStartupStatusUseCase useCase;

  setUp(() {
    repository = MockSplashRepository();
    useCase = CheckStartupStatusUseCase(repository);
  });

  const tEntity = SplashStateEntity(
    hasAuthToken: true,
    onboardingSeen: false,
    hasPendingSignup: false,
  );

  test('should return entity when repository succeeds', () async {
    when(() => repository.checkStartupStatus())
        .thenAnswer((_) async => Success(tEntity));

    final result = await useCase();

    expect(result, isA<Success<SplashStateEntity>>());
    expect((result as Success<SplashStateEntity>).data, equals(tEntity));
    verify(() => repository.checkStartupStatus()).called(1);
  });

  test('should return failure when repository fails', () async {
    const tFailure = CacheFailure(message: 'Storage error');
    when(() => repository.checkStartupStatus())
        .thenAnswer((_) async => ResultFailure(tFailure));

    final result = await useCase();

    expect(result, isA<ResultFailure<SplashStateEntity>>());
    expect(
      (result as ResultFailure<SplashStateEntity>).failure,
      equals(tFailure),
    );
    verify(() => repository.checkStartupStatus()).called(1);
  });
}
