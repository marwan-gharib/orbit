import 'package:orbit/core/utils/api_result.dart';

import '../entities/dashboard_overview_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardOverviewUseCase {
  GetDashboardOverviewUseCase(this._repository);

  final DashboardRepository _repository;

  Future<ApiResult<DashboardOverview>> call() => _repository.getOverview();
}
