import 'package:orbit/core/utils/api_result.dart';

import '../entities/interaction_context.dart';
import '../repositories/interactions_repository.dart';

/// Deletes one interaction by id. The context travels separately (never
/// serialized) so the repository can announce the change correctly.
class DeleteInteractionUseCase {
  DeleteInteractionUseCase(this._repository);

  final InteractionsRepository _repository;

  Future<ApiResult<void>> call(
    int interactionId, {
    required InteractionContext context,
  }) => _repository.deleteInteraction(interactionId, context: context);
}
