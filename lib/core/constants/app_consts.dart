abstract final class AppConsts {
  /// Key of the backend base URL in `.env` (the only configuration value read
  /// through `AppEnv`). Bundled assets are extractable, so `.env` must only
  /// hold non-secret configuration — real secrets never go there.
  static const String envBaseUrlKey = 'BASE_URL';

  /// Secure-storage keys for the auth tokens (A2: tokens live ONLY in secure
  /// storage — never in the cache, never in logs, never inside cached user
  /// data). Shared by `AuthInterceptor` (core/network), the auth feature and
  /// splash's startup check, so all three read/write the exact same keys.
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';

  /// Cache key for the cached user profile (non-token display data).
  static const String authUserCacheKey = 'auth_cached_user';

  /// Key for onboarding completion flag in shared preferences (cache).
  /// Read by splash on startup; written by onboarding on completion/skip.
  static const String onboardingSeenKey = 'onboarding_seen';
}
