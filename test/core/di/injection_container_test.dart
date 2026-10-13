import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/di/injection_container.dart';
import 'package:orbit/core/local/cache/cache_service.dart';
import 'package:orbit/core/local/secure/secure_storage_client.dart';
import 'package:orbit/core/network/base_api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await getIt.reset();
    await initDependencies();
  });

  tearDown(() => getIt.reset());

  test('should register the secure storage client when dependencies init', () {
    expect(getIt.isRegistered<SecureStorageClient>(), isTrue);
  });

  test('should register the cache service when dependencies init', () {
    expect(getIt.isRegistered<CacheService>(), isTrue);
  });

  test('should register the api client when dependencies init', () {
    expect(getIt.isRegistered<BaseApiClient>(), isTrue);
  });

  test('should resolve the same api client instance when resolved twice', () {
    expect(getIt<BaseApiClient>(), same(getIt<BaseApiClient>()));
  });
}
