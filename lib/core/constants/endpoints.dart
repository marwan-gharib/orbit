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

  // ---------------------------------------------------------------------------
  // CRM — interactions, customer notes and the opportunities view.
  // ---------------------------------------------------------------------------

  /// List/search/create interactions. PATCH updates one interaction; DELETE
  /// carries `interaction_id` in the request BODY, not the URL.
  static const String crmInteractions = '/crm/interactions/';

  /// List (`?customer_id=`) and create customer notes.
  static const String crmCustomerNotes = '/crm/customer-notes/';

  /// Update/delete one note — note id in the path, not the body.
  static String crmCustomerNoteById(int noteId) => '$crmCustomerNotes$noteId/';

  /// Paged opportunities view (`page`, `page_size` plus filter queries).
  static const String crmOpportunitiesView = '/crm/opportunities_view/';
}
