import 'package:orbit/core/utils/api_result.dart';

import '../entities/interaction_entity.dart';
import '../params/interactions_criteria.dart';
import '../repositories/interactions_repository.dart';

/// Loads/searches the interactions list for the active criteria.
class GetInteractionsUseCase {
  GetInteractionsUseCase(this._repository);

  final InteractionsRepository _repository;

  Future<ApiResult<List<Interaction>>> call(InteractionsCriteria criteria) =>
      _repository.getInteractions(criteria);
}
