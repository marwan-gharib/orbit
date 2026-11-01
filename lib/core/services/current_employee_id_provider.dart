import 'package:orbit/core/utils/api_result.dart';

/// The numeric id of the signed-in employee (login response `user.id`), the
/// value CRM writes send as `employee_id`.
///
/// Implemented by the auth feature over its cached session, so consuming
/// features never reach into another feature's storage (ARCH-1).
abstract interface class CurrentEmployeeIdProvider {
  /// Fails with an unauthorized-type failure when no signed-in employee id
  /// is available (missing session, or a profile cached before the field
  /// existed).
  Future<ApiResult<int>> currentEmployeeId();
}
