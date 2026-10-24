import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/features/splash/data/datasources/local/splash_local_data_source.dart';
import 'package:orbit/features/splash/data/repositories/splash_repository_impl.dart';
import 'package:orbit/features/splash/domain/entities/splash_state_entity.dart';
import 'package:orbit/features/splash/data/models/startup_status_model.dart';
import 'package:orbit/core/errors/failures.dart';

class MockSplashLocalDataSource extends Mock implements SplashLocalDataSource {}

void main() {
  late MockSplashLocalDataSource localDataSource;
  late SplashRepositoryImpl repository;

  setUp(() {
    localDataSource = MockSplashLocalDataSource();
    repository = SplashRepositoryImpl(localDataSource);
  });

  const tModel = StartupStatusModel(
    hasAuthToken: true,
    onboardingSeen: false,
    hasPendingSignup: false,
  );

  const tEntity = SplashStateEntity(
    hasAuthToken: true,
    onboardingSeen: false,
    hasPendingSignup: false,
  );

  test('should return entity when data source succeeds', () async {
    when(() => localDataSource.getStartupStatus())
        .thenAnswer((_) async => Success(tModel));

    final result = await repository.checkStartupStatus();

    expect(result, isA<Success<SplashStateEntity>>());
    expect((result as Success<SplashStateEntity>).data, equals(tEntity));
    verify(() => localDataSource.getStartupStatus()).called(1);
  });

  test('should return failure when data source fails', () async {
    const tFailure = CacheFailure(message: 'Storage error');
    when(() => localDataSource.getStartupStatus())
        .thenAnswer((_) async => ResultFailure(tFailure));

    final result = await repository.checkStartupStatus();

    expect(result, isA<ResultFailure<SplashStateEntity>>());
    expect(
      (result as ResultFailure<SplashStateEntity>).failure,
      equals(tFailure),
    );
    verify(() => localDataSource.getStartupStatus()).called(1);
  });
}
