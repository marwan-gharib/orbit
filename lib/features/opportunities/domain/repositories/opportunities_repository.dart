import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/core/utils/paged_result.dart';

import '../entities/opportunity_entity.dart';
import '../params/opportunities_criteria.dart';

/// Contract for opportunities data access. Implemented in the data layer;
/// used by the opportunities use cases.
///
/// The repository is stateless — it receives `page`/`pageSize` and returns
/// a `PagedResult`. The Cubit keeps accumulated items and `hasMore`.
abstract interface class OpportunitiesRepository {
  /// One page of opportunities under `criteria`. `hasMore` is `next != null`
  /// from the DRF-style envelope; `count` is display-only, not used for
  /// paging logic.
  Future<ApiResult<PagedResult<Opportunity>>> getOpportunities(
    OpportunitiesCriteria criteria, {
    required int page,
    required int pageSize,
  });

  /// One opportunity through the same list endpoint (`opportunity_id`).
  /// Empty result means not found.
  Future<ApiResult<Opportunity>> getOpportunity(int opportunityId);
}
