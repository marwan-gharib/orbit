import 'package:orbit/core/services/current_employee_id_provider.dart';
import 'package:orbit/core/utils/api_result.dart';

import '../params/add_interaction_params.dart';
import '../repositories/interactions_repository.dart';

/// Adds an interaction owned by the signed-in employee. The employee id is
/// resolved here from the cached session (login `user.id`) — never from the
/// caller and never derived from an opportunity object — so a write can
/// never carry a forged or absent owner.
class AddInteractionUseCase {
  AddInteractionUseCase(this._repository, this._employeeIdProvider);

  final InteractionsRepository _repository;
  final CurrentEmployeeIdProvider _employeeIdProvider;

  Future<ApiResult<void>> call(AddInteractionParams params) async {
    final employeeId = await _employeeIdProvider.currentEmployeeId();
    if (employeeId is ResultFailure<int>) {
      // A profile cached before `user.id` existed (or no session): one
      // re-sign-in fixes it, no migration.
      return ResultFailure<void>(employeeId.failure);
    }
    final success = employeeId as Success<int>;
    return _repository.addInteraction(params, employeeId: success.data);
  }
}
