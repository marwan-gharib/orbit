import 'package:orbit/core/utils/api_result.dart';

import '../entities/employee_status_info_entity.dart';
import '../repositories/auth_repository.dart';

/// Checks an account's employment status; one primitive input, passed
/// directly (DOM-3).
class GetEmployeeStatusUseCase {
  GetEmployeeStatusUseCase(this._repository);

  final AuthRepository _repository;

  Future<ApiResult<EmployeeStatusInfo>> call(String email) =>
      _repository.getEmployeeStatus(email);
}
