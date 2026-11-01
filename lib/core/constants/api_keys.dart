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

  /// Numeric employee id inside the `user` object (login/SSO response and
  /// the cached profile); also the id other modules address employees by.
  static const String idKey = 'id';

  /// Signup uses `work_email` while login uses `email` — both are wire keys
  /// and must stay distinct.
  static const String workEmailKey = 'work_email';
  static const String passwordKey = 'password';
  static const String refreshKey = 'refresh';
  static const String refreshAccessKey = 'access';
  static const String statusKey = 'status';

  // ---------------------------------------------------------------------------
  // Google SSO request wire keys.
  // ---------------------------------------------------------------------------
  static const String issKey = 'iss';
  static const String subKey = 'sub';
  static const String givenNameKey = 'given_name';
  static const String familyNameKey = 'family_name';
  static const String idTokenKey = 'id_token';

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

  // ---------------------------------------------------------------------------
  // CRM — interactions / customer notes / opportunities wire keys.
  // ---------------------------------------------------------------------------

  // Interactions (both standalone list and embedded in opportunities).
  static const String interactionIdKey = 'interaction_id';
  static const String typeKey = 'type';
  static const String subjectKey = 'subject';
  static const String descriptionKey = 'description';
  static const String interactionDateKey = 'interaction_date';
  // `contact_id` / `opportunity_id` / `employee_id` / `customer_id` live in
  // the ids group right below.

  // Customer notes (standalone; the embedded shape is lighter, Phase 4 file).
  static const String noteIdKey = 'note_id';
  static const String noteTextKey = 'note_text';
  static const String createdAtKey = 'created_at';
  static const String updatedAtKey = 'updated_at';
  static const String closedAtKey = 'closed_at';
  static const String customerDetailsKey = 'customer_details';
  static const String employeeDetailsKey = 'employee_details';
  static const String employeeCodeKey = 'employee_code';
  static const String customerCodeKey = 'customer_code';
  static const String nameKey = 'name';
  static const String companyNameKey = 'company_name';

  // Opportunities view (DRF-style page envelope + opportunity fields).
  static const String countKey = 'count';
  static const String nextKey = 'next';
  static const String previousKey = 'previous';
  static const String resultsKey = 'results';
  static const String opportunityIdKey = 'opportunity_id';
  static const String titleKey = 'title';
  static const String stageKey = 'stage';
  static const String estimatedValueKey = 'estimated_value';
  static const String currencyKey = 'currency';
  static const String probabilityKey = 'probability';
  static const String expectedCloseDateKey = 'expected_close_date';
  static const String lostReasonKey = 'lost_reason';
  static const String customerRootKey = 'customer';
  static const String employeeRootKey = 'employee';
  static const String phoneKey = 'phone';
  static const String addressKey = 'address';
  static const String leadSourceKey = 'lead_source';
  static const String employeeNameKey = 'employee_name';
  static const String contactsRootKey = 'contacts';
  static const String jobTitleKey = 'job_title';
  static const String isPrimaryKey = 'is_primary';
  static const String notesRootKey = 'notes';
  static const String interactionsRootKey = 'Interactions';

  // Shared ids and the non-paginated list totals.
  static const String customerIdKey = 'customer_id';
  static const String employeeIdKey = 'employee_id';
  static const String contactIdKey = 'contact_id';
  static const String totalKey = 'total';
  static const String pageKey = 'page';
  static const String pageSizeKey = 'page_size';
}
