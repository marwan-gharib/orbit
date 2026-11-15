import 'package:orbit/core/utils/api_result.dart';

import '../entities/opportunity_entity.dart';
import '../repositories/opportunities_repository.dart';

/// Fetches a single opportunity through the list endpoint (`opportunity_id`).
class GetOpportunityUseCase {
  GetOpportunityUseCase(this._repository);

  final OpportunitiesRepository _repository;

  Future<ApiResult<Opportunity>> call(int opportunityId) =>
      _repository.getOpportunity(opportunityId);
}
