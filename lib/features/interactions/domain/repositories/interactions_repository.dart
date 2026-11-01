import 'package:orbit/core/utils/api_result.dart';

import '../entities/interaction_context.dart';
import '../entities/interaction_entity.dart';
import '../params/add_interaction_params.dart';
import '../params/interactions_criteria.dart';
import '../params/update_interaction_params.dart';

/// Contract for CRM interaction data access. Implemented in the data layer;
/// used by the interactions use cases.
abstract interface class InteractionsRepository {
  /// Lists/searches interactions under the active criteria. A non-empty
  /// `criteria.searchText` matches subject OR description on the backend —
  /// the implementation merges the two requests. Not paginated; the result
  /// is sorted `interaction_date` desc, then id desc.
  Future<ApiResult<List<Interaction>>> getInteractions(
    InteractionsCriteria criteria,
  );

  /// Adds an interaction owned by the signed-in employee; [employeeId]
  /// arrives resolved (login `user.id`) and is never taken from a caller.
  /// On success the repository announces the change on the CRM signal.
  Future<ApiResult<void>> addInteraction(
    AddInteractionParams params, {
    required int employeeId,
  });

  /// Updates only the five editable fields of [params] (owner ids are
  /// immutable); [InteractionContext] exists only for change signaling.
  Future<ApiResult<void>> updateInteraction(
    UpdateInteractionParams params, {
    required InteractionContext context,
  });

  /// Deletes the interaction by id; [context] exists only for change
  /// signaling. The list refreshes through the signal, never locally.
  Future<ApiResult<void>> deleteInteraction(
    int interactionId, {
    required InteractionContext context,
  });
}
