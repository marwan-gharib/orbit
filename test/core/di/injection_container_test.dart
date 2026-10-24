import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/config/app_env.dart';
import 'package:orbit/core/constants/app_consts.dart';
import 'package:orbit/core/di/injection_container.dart';
import 'package:orbit/core/local/cache/cache_service.dart';
import 'package:orbit/core/local/secure/secure_storage_client.dart';
import 'package:orbit/core/network/base_api_client.dart';
import 'package:orbit/core/router/pending_signup_session.dart';
import 'package:orbit/features/auth/data/datasources/google/google_auth_client.dart';
import 'package:orbit/features/auth/domain/repositories/auth_repository.dart';
import 'package:orbit/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:orbit/features/auth/presentation/cubits/employee_status/employee_status_cubit.dart';
import 'package:orbit/features/auth/presentation/cubits/google_sign_in/google_sign_in_cubit.dart';
import 'package:orbit/features/auth/presentation/cubits/login/login_cubit.dart';
import 'package:orbit/features/auth/presentation/cubits/signup/signup_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    AppEnv.debugSeed(
      baseUrl: 'https://test.local',
      googleServerClientId: 'test-google-client-id',
    );
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

  test('should register the pending signup session', () {
    expect(getIt.isRegistered<PendingSignupSession>(), isTrue);
    expect(getIt<PendingSignupSession>(), same(getIt<PendingSignupSession>()));
  });

  test('should resume a persisted pending signup at startup', () async {
    await getIt.reset();
    SharedPreferences.setMockInitialValues(<String, Object>{
      AppConsts.pendingSignupEmailKey: 'adam@orbit.app',
    });
    await initDependencies();

    expect(getIt<PendingSignupSession>().email, 'adam@orbit.app');
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

  test('should register google auth client and sign in usecase', () {
    expect(getIt.isRegistered<GoogleAuthClient>(), isTrue);
    expect(getIt.isRegistered<SignInWithGoogleUseCase>(), isTrue);
  });

  test('should resolve a fresh google sign in cubit each time (factory scope)', () {
    expect(
      getIt<GoogleSignInCubit>(),
      isNot(same(getIt<GoogleSignInCubit>())),
    );
  });

  test('should resume a persisted pending signup with google flag at startup', () async {
    await getIt.reset();
    SharedPreferences.setMockInitialValues(<String, Object>{
      AppConsts.pendingSignupEmailKey: 'adam@orbit.app',
      AppConsts.pendingSignupGoogleKey: true,
    });
    await initDependencies();

    final session = getIt<PendingSignupSession>();
    expect(session.email, 'adam@orbit.app');
    expect(session.registeredWithGoogle, isTrue);
  });
}
