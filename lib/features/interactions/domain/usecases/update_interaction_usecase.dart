import 'package:orbit/core/utils/api_result.dart';

import '../entities/interaction_context.dart';
import '../params/update_interaction_params.dart';
import '../repositories/interactions_repository.dart';

/// Updates one interaction's editable fields. The context travels separately
/// (never serialized) so the repository can announce the change correctly.
class UpdateInteractionUseCase {
  UpdateInteractionUseCase(this._repository);

  final InteractionsRepository _repository;

  Future<ApiResult<void>> call(
    UpdateInteractionParams params, {
    required InteractionContext context,
  }) => _repository.updateInteraction(params, context: context);
}
