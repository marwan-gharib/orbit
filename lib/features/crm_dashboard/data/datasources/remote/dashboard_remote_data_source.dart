import 'package:orbit/core/constants/endpoints.dart';
import 'package:orbit/core/errors/error_mapper.dart';
import 'package:orbit/core/network/base_api_client.dart';
import 'package:orbit/core/utils/api_result.dart';

import '../../models/dashboard_overview_model.dart';

class DashboardRemoteDataSource {
  DashboardRemoteDataSource(this._client);

  final BaseApiClient _client;

  Future<ApiResult<DashboardOverviewModel>> fetchOverview() async {
    try {
      final body = await _client.get(Endpoints.crmOverview);
      if (body is! Map) {
        throw const FormatException('Dashboard body was not a JSON object.');
      }
      return Success(
        DashboardOverviewModel.fromJson(Map<String, dynamic>.from(body)),
      );
    } on Object catch (error, stackTrace) {
      return ResultFailure(ErrorMapper.toFailure(error, stackTrace));
    }
  }
}
