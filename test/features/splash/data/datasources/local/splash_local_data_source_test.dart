import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/constants/app_consts.dart';
import 'package:orbit/core/errors/exceptions.dart';
import 'package:orbit/core/local/cache/cache_service.dart';
import 'package:orbit/core/local/secure/secure_storage_client.dart';
import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/features/splash/data/datasources/local/splash_local_data_source.dart';

class _MockCacheService extends Mock implements CacheService {}

class _MockSecureStorage extends Mock implements SecureStorageClient {}

void main() {
  late _MockCacheService cache;
  late _MockSecureStorage secureStorage;
  late SplashLocalDataSource dataSource;

  setUp(() {
    cache = _MockCacheService();
    secureStorage = _MockSecureStorage();
    dataSource = SplashLocalDataSource(
      cache: cache,
      secureStorage: secureStorage,
    );
  });

  test(
    'should read the access token from the shared secure-storage key',
    () async {
      // Regression pin (B11): splash must check the exact constant the auth
      // feature writes; the strict mock fails on any other key.
      when(() => secureStorage.read(AppConsts.accessTokenKey))
          .thenAnswer((_) async => 'token');
      when(() => cache.readBool(AppConsts.onboardingSeenKey))
          .thenAnswer((_) async => true);

      final result = await dataSource.getStartupStatus();

      expect(result.isSuccess, isTrue);
      expect((result as Success).data.hasAuthToken, isTrue);
      expect((result as Success).data.onboardingSeen, isTrue);
      verify(() => secureStorage.read(AppConsts.accessTokenKey)).called(1);
    },
  );

  test(
    'should report no auth token when the secure-storage key is empty',
    () async {
      when(() => secureStorage.read(AppConsts.accessTokenKey))
          .thenAnswer((_) async => null);
      when(() => cache.readBool(AppConsts.onboardingSeenKey))
          .thenAnswer((_) async => true);

      final result = await dataSource.getStartupStatus();

      expect((result as Success).data.hasAuthToken, isFalse);
    },
  );

  test('should return a failure when secure storage throws', () async {
    when(() => secureStorage.read(AppConsts.accessTokenKey))
        .thenThrow(const SecureStorageException());
    when(() => cache.readBool(AppConsts.onboardingSeenKey))
        .thenAnswer((_) async => true);

    final result = await dataSource.getStartupStatus();

    expect(result.isFailure, isTrue);
  });
}
