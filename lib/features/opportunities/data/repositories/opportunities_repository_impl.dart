import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/core/utils/paged_result.dart';

import '../../domain/entities/opportunity_entity.dart';
import '../../domain/params/opportunities_criteria.dart';
import '../../domain/repositories/opportunities_repository.dart';
import '../datasources/remote/opportunities_remote_data_source.dart';

/// Orchestrates opportunities data: stateless page fetch, `PagedResult`
/// with `hasMore` from `next != null` only (`count` is display-only).
/// Server order is preserved — never re-sorted across pages (OQ-6).
class OpportunitiesRepositoryImpl implements OpportunitiesRepository {
  OpportunitiesRepositoryImpl(this._remoteDataSource);

  final OpportunitiesRemoteDataSource _remoteDataSource;

  @override
  Future<ApiResult<PagedResult<Opportunity>>> getOpportunities(
    OpportunitiesCriteria criteria, {
    required int page,
    required int pageSize,
  }) async {
    final result = await _remoteDataSource.fetchOpportunitiesPage(
      criteria: criteria,
      page: page,
      pageSize: pageSize,
    );
    return result.fold(ResultFailure<PagedResult<Opportunity>>.new, (response) {
      final entities = response.results.map((m) => m.toEntity()).toList();
      final hasMore = response.next != null;
      return Success(
        PagedResult<Opportunity>(
          items: entities,
          hasMore: hasMore,
          nextPage: hasMore ? page + 1 : null,
        ),
      );
    });
  }

  @override
  Future<ApiResult<Opportunity>> getOpportunity(int opportunityId) async {
    final result = await _remoteDataSource.fetchOpportunity(opportunityId);
    return result.fold(ResultFailure<Opportunity>.new, (response) {
      if (response.results.isEmpty) {
        return const ResultFailure(
          NotFoundFailure(message: 'Opportunity not found.'),
        );
      }
      return Success(response.results.first.toEntity());
    });
  }
}
