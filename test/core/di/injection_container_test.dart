import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/config/app_env.dart';
import 'package:orbit/core/di/injection_container.dart';
import 'package:orbit/core/local/cache/cache_service.dart';
import 'package:orbit/core/local/secure/secure_storage_client.dart';
import 'package:orbit/core/network/base_api_client.dart';
import 'package:orbit/features/auth/domain/repositories/auth_repository.dart';
import 'package:orbit/features/auth/presentation/cubits/employee_status/employee_status_cubit.dart';
import 'package:orbit/features/auth/presentation/cubits/login/login_cubit.dart';
import 'package:orbit/features/auth/presentation/cubits/signup/signup_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    AppEnv.debugSeed(baseUrl: 'https://test.local');
    await getIt.reset();
    await initDependencies();
  });

  tearDown(() async {
    AppEnv.reset();
    await getIt.reset();
  });

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

  test('should register the auth repository when dependencies init', () {
    expect(getIt.isRegistered<AuthRepository>(), isTrue);
    expect(getIt<AuthRepository>(), same(getIt<AuthRepository>()));
  });

  test('should resolve a fresh login cubit each time (factory scope)', () {
    expect(getIt<LoginCubit>(), isNot(same(getIt<LoginCubit>())));
  });

  test('should resolve a fresh signup cubit each time (factory scope)', () {
    expect(getIt<SignupCubit>(), isNot(same(getIt<SignupCubit>())));
  });

  test(
    'should resolve a fresh employee status cubit each time (factory scope)',
    () {
      expect(
        getIt<EmployeeStatusCubit>(),
        isNot(same(getIt<EmployeeStatusCubit>())),
      );
    },
  );
}
