import 'package:orbit/core/utils/api_result.dart';

import '../entities/auth_session_entity.dart';
import '../entities/employee_status_info_entity.dart';
import '../entities/session_info_entity.dart';
import '../entities/signup_result_entity.dart';
import '../params/login_params.dart';
import '../params/signup_params.dart';

/// Contract for authentication data access.
/// Implemented in the data layer; used by the auth use cases.
abstract interface class AuthRepository {
  /// Signs in and persists the session (tokens + cached user). Fails loudly
  /// when persistence fails — the session is never half-saved.
  Future<ApiResult<AuthSession>> login(LoginParams params);

  /// Creates a pending account; nothing is persisted (no tokens arrive).
  Future<ApiResult<SignupResult>> signup(SignupParams params);

  /// Revokes the refresh token server-side (when one exists) and always
  /// clears the local session, even if the remote call fails.
  Future<ApiResult<void>> logout();

  /// Checks an account's employment status by work email.
  Future<ApiResult<EmployeeStatusInfo>> getEmployeeStatus(String email);

  /// Local-only snapshot for routing decisions; never fails for missing
  /// data (missing data means "not signed in").
  Future<ApiResult<SessionInfo>> getSessionInfo();
}
