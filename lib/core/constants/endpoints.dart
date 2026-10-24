/// Holds backend endpoint path constants in one place.
abstract final class Endpoints {
  /// Sign in with email and password; returns tokens plus the user profile.
  static const String authLogin = '/api/auth/login/';

  /// Create a pending account; returns no tokens.
  static const String authSignup = '/api/auth/signup/';

  /// Revoke the refresh token; requires the Bearer access token.
  static const String authLogout = '/api/auth/logout/';

  /// Exchange an existing refresh token for a fresh access token.
  static const String authRefresh = '/api/auth/refresh/';

  /// Check an account's employment status by email (GET with a JSON body —
  /// isolated in `AuthRemoteDataSource` so it can change in one place).
  static const String authEmployeeStatus = '/api/auth/get_employee_status/';

  /// Mobile SSO endpoint for Google authentication.
  static const String authSsoMobile = '/api/auth/sso_mobile/';
}
