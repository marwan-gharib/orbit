import 'package:get_it/get_it.dart';
import 'package:orbit/core/network/base_api_client.dart';
import 'package:orbit/core/services/crm_data_change_service.dart';
import 'package:orbit/features/opportunities/data/datasources/remote/opportunities_remote_data_source.dart';
import 'package:orbit/features/opportunities/data/repositories/opportunities_repository_impl.dart';
import 'package:orbit/features/opportunities/domain/repositories/opportunities_repository.dart';
import 'package:orbit/features/opportunities/domain/usecases/get_opportunities_usecase.dart';
import 'package:orbit/features/opportunities/domain/usecases/get_opportunity_usecase.dart';
import 'package:orbit/features/opportunities/domain/usecases/watch_crm_changes_usecase.dart';
import 'package:orbit/features/opportunities/presentation/blocs/opportunities_list/opportunities_list_bloc.dart';
import 'package:orbit/features/opportunities/presentation/cubits/opportunity_details/opportunity_details_cubit.dart';

/// Registers the opportunities feature dependencies (DI-5), in dependency
/// order: datasource → repository → use cases → holders.
Future<void> initOpportunitiesModule(GetIt getIt) async {
  // Data source
  getIt.registerLazySingleton<OpportunitiesRemoteDataSource>(
    () => OpportunitiesRemoteDataSource(getIt<BaseApiClient>()),
  );

  // Repository (the CRM change service is the core broadcast singleton).
  getIt.registerLazySingleton<OpportunitiesRepository>(
    () => OpportunitiesRepositoryImpl(getIt<OpportunitiesRemoteDataSource>()),
  );

  // Use cases
  getIt.registerLazySingleton<GetOpportunitiesUseCase>(
    () => GetOpportunitiesUseCase(getIt<OpportunitiesRepository>()),
  );
  getIt.registerLazySingleton<GetOpportunityUseCase>(
    () => GetOpportunityUseCase(getIt<OpportunitiesRepository>()),
  );
  getIt.registerLazySingleton<WatchCrmChangesUseCase>(
    () => WatchCrmChangesUseCase(getIt<CrmDataChangeService>()),
  );

  // Holders (factory — one instance per screen, DI-3)
  getIt.registerFactory<OpportunitiesListBloc>(
    () => OpportunitiesListBloc(
      getOpportunities: getIt<GetOpportunitiesUseCase>(),
    ),
  );
  getIt.registerFactory<OpportunityDetailsCubit>(
    () => OpportunityDetailsCubit(
      getOpportunity: getIt<GetOpportunityUseCase>(),
      watchCrmChanges: getIt<WatchCrmChangesUseCase>(),
    ),
  );
}
