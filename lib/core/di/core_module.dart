import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:orbit/core/config/app_env.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/local/cache/cache_service.dart';
import 'package:orbit/core/local/cache/shared_preferences_service.dart';
import 'package:orbit/core/local/secure/secure_storage_client.dart';
import 'package:orbit/core/local/secure/secure_storage_impl.dart';
import 'package:orbit/core/network/base_api_client.dart';
import 'package:orbit/core/network/dio_api_client.dart';
import 'package:orbit/core/network/refresh/refresh_dio_client.dart';
import 'package:orbit/core/network/refresh/token_refresh_service.dart';
import 'package:orbit/core/network/refresh/token_refresh_service_impl.dart';
import 'package:orbit/core/network/session/session_cleaner.dart';
import 'package:orbit/core/network/session/session_expired_notifier.dart';
import 'package:orbit/core/router/pending_signup_session.dart';

/// Registers the cross-feature services every feature builds on, in
/// dependency order: storage first, then the API client that talks to secure
/// storage (DI-5).
Future<void> initCoreModule(GetIt getIt) async {
  getIt.registerLazySingleton<PendingSignupSession>(PendingSignupSession.new);

  getIt.registerLazySingleton<SessionExpiredNotifier>(
    SessionExpiredNotifier.new,
  );

  getIt.registerLazySingleton<SecureStorageClient>(SecureStorageImpl.new);

  // Dedicated isolated Dio instance for token refresh operations.
  getIt.registerLazySingleton<Dio>(
    () => RefreshDioClient.create(baseUrl: AppEnv.baseUrl),
    instanceName: 'refreshDio',
  );

  // Token refresh service encapsulating refresh contract and storage persistence.
  getIt.registerLazySingleton<TokenRefreshService>(
    () => TokenRefreshServiceImpl(
      refreshDio: getIt<Dio>(instanceName: 'refreshDio'),
      secureStorage: getIt<SecureStorageClient>(),
      sessionNotifier: getIt<SessionExpiredNotifier>(),
    ),
  );

  // Loaded up front so the app fails fast at startup if persistence is
  // unavailable, instead of on the first read (DATA-9, ARCH-5: only the
  // implementation touches the storage package).
  final cache = await SharedPreferencesService.create();
  getIt.registerLazySingleton<CacheService>(() => cache);

  getIt.registerLazySingleton<BaseApiClient>(
    () => DioApiClient.configured(
      baseUrl: AppEnv.baseUrl,
      secureStorage: getIt<SecureStorageClient>(),
      localeProvider: () =>
          LocaleSettings.currentLocale.flutterLocale.toString(),
      tokenRefreshService: getIt<TokenRefreshService>(),
      sessionCleaner: getIt<SessionCleaner>(),
      sessionExpiredNotifier: getIt<SessionExpiredNotifier>(),
    ),
  );
}
