import 'package:orbit/core/utils/api_result.dart';

import '../../domain/entities/dashboard_overview_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/remote/dashboard_remote_data_source.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl(this._remoteDataSource);

  final DashboardRemoteDataSource _remoteDataSource;

  @override
  Future<ApiResult<DashboardOverview>> getOverview() async {
    final result = await _remoteDataSource.fetchOverview();
    return result.fold(
      ResultFailure<DashboardOverview>.new,
      (model) => Success(model.toEntity()),
    );
  }
}
