import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/constants/app_consts.dart';
import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/local/cache/cache_service.dart';
import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/features/onboarding/data/datasources/local/onboarding_local_data_source.dart';

class MockCacheService extends Mock implements CacheService {}

void main() {
  late MockCacheService cache;
  late OnboardingLocalDataSource dataSource;

  setUp(() {
    cache = MockCacheService();
    dataSource = OnboardingLocalDataSource(cache);
  });

  group('setOnboardingSeen', () {
    test('should write onboarding_seen true and return success when the cache '
        'write succeeds', () async {
      when(() => cache.writeBool(AppConsts.onboardingSeenKey, true))
          .thenAnswer((_) async {});

      final result = await dataSource.setOnboardingSeen();

      expect(result, const Success<void>(null));
      verify(() => cache.writeBool(AppConsts.onboardingSeenKey, true))
          .called(1);
    });

    test('should return CacheFailure when the cache write throws', () async {
      when(() => cache.writeBool(any(), any()))
          .thenThrow(Exception('Storage unavailable'));

      final result = await dataSource.setOnboardingSeen();

      expect(result, isA<ResultFailure<void>>());
      final failure = (result as ResultFailure<void>).failure;
      expect(failure, isA<CacheFailure>());
      verify(() => cache.writeBool(AppConsts.onboardingSeenKey, true))
          .called(1);
    });
  });

  group('getOnboardingSeen', () {
    test('should return false when the flag is absent', () async {
      when(() => cache.readBool(AppConsts.onboardingSeenKey))
          .thenAnswer((_) async => null);

      final result = await dataSource.getOnboardingSeen();

      expect(result, const Success<bool>(false));
    });

    test('should return true when the flag is set', () async {
      when(() => cache.readBool(AppConsts.onboardingSeenKey))
          .thenAnswer((_) async => true);

      final result = await dataSource.getOnboardingSeen();

      expect(result, const Success<bool>(true));
    });

    test('should return CacheFailure when the cache read throws', () async {
      when(() => cache.readBool(AppConsts.onboardingSeenKey))
          .thenThrow(Exception('Storage unavailable'));

      final result = await dataSource.getOnboardingSeen();

      expect(result, isA<ResultFailure<bool>>());
      final failure = (result as ResultFailure<bool>).failure;
      expect(failure, isA<CacheFailure>());
    });
  });
}
