import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/core/constants/endpoints.dart';
import 'package:orbit/core/errors/error_mapper.dart';
import 'package:orbit/core/network/base_api_client.dart';
import 'package:orbit/core/utils/api_result.dart';

import '../../../domain/params/opportunities_criteria.dart';
import '../../models/opportunities_page_response_model.dart';

/// The whole opportunities-view HTTP surface in one class. GET only on
/// mobile — no create/edit/stage-move. `next` is never parsed as a URL;
/// only `null` vs non-null matters (OQ-10).
class OpportunitiesRemoteDataSource {
  OpportunitiesRemoteDataSource(this._client);

  final BaseApiClient _client;

  Future<ApiResult<OpportunitiesPageResponseModel>> fetchOpportunitiesPage({
    required OpportunitiesCriteria criteria,
    required int page,
    required int pageSize,
  }) async {
    try {
      final body = await _client.get(
        Endpoints.crmOpportunitiesView,
        queryParameters: <String, Object?>{
          ApiKeys.pageKey: page,
          ApiKeys.pageSizeKey: pageSize,
          if (criteria.title != null && criteria.title!.isNotEmpty)
            ApiKeys.titleKey: criteria.title,
          if (criteria.stage != null) ApiKeys.stageKey: criteria.stage!.value,
          if (criteria.status != null)
            ApiKeys.statusKey: criteria.status!.value,
          if (criteria.customerId != null)
            ApiKeys.customerIdKey: criteria.customerId,
        },
      );
      return Success(OpportunitiesPageResponseModel.fromJson(_asMap(body)));
    } on Object catch (error, stackTrace) {
      return ResultFailure(ErrorMapper.toFailure(error, stackTrace));
    }
  }

  /// One opportunity through the same list endpoint (`opportunity_id`).
  /// Shares the query builder with `fetchOpportunitiesPage`.
  Future<ApiResult<OpportunitiesPageResponseModel>> fetchOpportunity(
    int opportunityId,
  ) async {
    try {
      final body = await _client.get(
        Endpoints.crmOpportunitiesView,
        queryParameters: <String, Object?>{
          ApiKeys.pageKey: 1,
          ApiKeys.pageSizeKey: 1,
          ApiKeys.opportunityIdKey: opportunityId,
        },
      );
      return Success(OpportunitiesPageResponseModel.fromJson(_asMap(body)));
    } on Object catch (error, stackTrace) {
      return ResultFailure(ErrorMapper.toFailure(error, stackTrace));
    }
  }

  Map<String, dynamic> _asMap(Object? body) {
    if (body is Map) return Map<String, dynamic>.from(body);
    throw const FormatException('Opportunities body was not a JSON object.');
  }
}
