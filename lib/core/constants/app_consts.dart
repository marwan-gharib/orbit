abstract final class AppConsts {
  /// Key of the backend base URL in `.env` (the only configuration value read
  /// through `AppEnv`). Bundled assets are extractable, so `.env` must only
  /// hold non-secret configuration — real secrets never go there.
  static const String envBaseUrlKey = 'BASE_URL';

  /// Key of the Google Server Client ID in `.env`.
  static const String envGoogleServerClientIdKey = 'GOOGLE_SERVER_CLIENT_ID';

  /// Secure-storage keys for the auth tokens (A2: tokens live ONLY in secure
  /// storage — never in the cache, never in logs, never inside cached user
  /// data). Shared by `AuthInterceptor` (core/network), the auth feature and
  /// splash's startup check, so all three read/write the exact same keys.
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';

  /// Cache key for the cached user profile (non-token display data).
  static const String authUserCacheKey = 'auth_cached_user';

  /// Cache key for the work email of an account created but not yet approved.
  /// Read at startup so the router can resume the pending-approval flow.
  static const String pendingSignupEmailKey = 'pending_signup_email';

  /// Cache key for the flag indicating whether pending signup was via Google SSO.
  static const String pendingSignupGoogleKey = 'pending_signup_google';

  /// Minimum wait between manual approval checks on the pending screen.
  static const Duration pendingCheckCooldown = Duration(seconds: 30);

  /// How long the approved/rejected moment stays before the pending screen
  /// leaves for its next route.
  static const Duration pendingMomentHold = Duration(seconds: 2);

  /// Key for onboarding completion flag in shared preferences (cache).
  /// Read by splash on startup; written by onboarding on completion/skip.
  static const String onboardingSeenKey = 'onboarding_seen';

  /// Extra key used by TokenRefreshInterceptor to prevent infinite retry loops.
  static const String retryAttemptedExtraKey = 'retry_attempted';
}
