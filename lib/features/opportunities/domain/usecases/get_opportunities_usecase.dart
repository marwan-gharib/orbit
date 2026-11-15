import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/core/utils/paged_result.dart';

import '../entities/opportunity_entity.dart';
import '../params/get_opportunities_params.dart';
import '../repositories/opportunities_repository.dart';

/// Fetches one page of opportunities.
class GetOpportunitiesUseCase {
  GetOpportunitiesUseCase(this._repository);

  final OpportunitiesRepository _repository;

  Future<ApiResult<PagedResult<Opportunity>>> call(
    GetOpportunitiesParams params,
  ) => _repository.getOpportunities(
    params.criteria,
    page: params.page,
    pageSize: params.pageSize,
  );
}
