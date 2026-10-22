/// Holds app-wide API key constants (ARCH-10: the only place wire literals
/// live).
abstract final class ApiKeys {
  // ---------------------------------------------------------------------------
  // Client-type header — static, set once on the Dio default headers.
  // ---------------------------------------------------------------------------
  static const String clientTypeHeaderKey = 'X-Client-Type';
  static const String clientTypeHeaderValue = 'Flutter';

  // ---------------------------------------------------------------------------
  // Request header names and request-option identifiers.
  // ---------------------------------------------------------------------------
  static const String authorizationHeaderKey = 'Authorization';

  /// Opt-out flag read from `options.extra` by `AuthInterceptor`: a request
  /// with this flag set to `false` never carries a (stale) Bearer token.
  static const String requiresAuthExtraKey = 'requiresAuth';

  // ---------------------------------------------------------------------------
  // Auth request/response body keys.
  // ---------------------------------------------------------------------------
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user';
  static const String firstNameKey = 'first_name';
  static const String lastNameKey = 'last_name';
  static const String codeKey = 'code';
  static const String emailKey = 'email';
  static const String roleKey = 'role';
  static const String roleNameKey = 'role_name';
  static const String permissionsKey = 'permissions';
  static const String moduleKey = 'module';
  static const String permissionKey = 'permission';

  /// Signup uses `work_email` while login uses `email` — both are wire keys
  /// and must stay distinct.
  static const String workEmailKey = 'work_email';
  static const String passwordKey = 'password';
  static const String refreshKey = 'refresh';
  static const String statusKey = 'status';

  // ---------------------------------------------------------------------------
  // Error response body keys.
  // ---------------------------------------------------------------------------
  static const String errorMessageKey = 'message';
  static const String errorErrorKey = 'error';
  static const String errorDetailKey = 'detail';

  /// Precedence of the error-body keys above (message -> error -> detail):
  /// the first non-empty, message-shaped value wins. Change this list to
  /// change `ErrorBodyParser`'s order everywhere.
  static const List<String> serverMessageKeyPrecedence = [
    errorMessageKey,
    errorErrorKey,
    errorDetailKey,
  ];

  /// Body containers that may hold a `{field: message|messages}` map on
  /// 400/422 responses.
  static const List<String> fieldErrorsKeys = ['errors', 'data'];

  /// Body keys that may carry a backend error identifier for branching.
  static const List<String> errorCodeKeys = ['code', 'error_code', 'errorCode'];
}
