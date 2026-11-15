import 'package:orbit/core/utils/api_result.dart';

import '../entities/dashboard_overview_entity.dart';

abstract interface class DashboardRepository {
  Future<ApiResult<DashboardOverview>> getOverview();
}
