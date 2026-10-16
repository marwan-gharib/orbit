abstract final class AppConsts {
  /// Backend origin every relative endpoint in `Endpoints` resolves against.
  static const String baseUrl = 'https://api.example.com';

  /// Key for onboarding completion flag in shared preferences (cache).
  /// Read by splash on startup; written by onboarding on completion/skip.
  static const String onboardingSeenKey = 'onboarding_seen';

  /// Key for auth token in secure storage.
  static const String authTokenKey = 'auth_token';
}
