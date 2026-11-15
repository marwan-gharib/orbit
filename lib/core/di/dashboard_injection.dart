import 'package:get_it/get_it.dart';
import 'package:orbit/core/network/base_api_client.dart';
import 'package:orbit/features/crm_dashboard/data/datasources/remote/dashboard_remote_data_source.dart';
import 'package:orbit/features/crm_dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:orbit/features/crm_dashboard/domain/repositories/dashboard_repository.dart';
import 'package:orbit/features/crm_dashboard/domain/usecases/get_dashboard_overview_usecase.dart';
import 'package:orbit/features/crm_dashboard/presentation/cubits/dashboard/dashboard_cubit.dart';

/// Registers the CRM dashboard feature dependencies (DI-5), in dependency
/// order: datasource → repository → use case → holder.
Future<void> initDashboardModule(GetIt getIt) async {
  getIt.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSource(getIt<BaseApiClient>()),
  );
  getIt.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(getIt<DashboardRemoteDataSource>()),
  );
  getIt.registerLazySingleton<GetDashboardOverviewUseCase>(
    () => GetDashboardOverviewUseCase(getIt<DashboardRepository>()),
  );

  // Holder (factory — one instance per screen, DI-3)
  getIt.registerFactory<DashboardCubit>(
    () => DashboardCubit(getOverview: getIt<GetDashboardOverviewUseCase>()),
  );
}
