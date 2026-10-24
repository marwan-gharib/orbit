import 'package:orbit/core/utils/api_result.dart';

import '../entities/employee_status_info_entity.dart';
import '../repositories/auth_repository.dart';

/// Checks an account's employment status; no input, because the pending email
/// is read from the persisted signup (DOM-3).
class GetEmployeeStatusUseCase {
  GetEmployeeStatusUseCase(this._repository);

  final AuthRepository _repository;

  Future<ApiResult<EmployeeStatusInfo>> call() =>
      _repository.getEmployeeStatus();
}
