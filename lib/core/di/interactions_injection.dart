import 'package:get_it/get_it.dart';
import 'package:orbit/core/network/base_api_client.dart';
import 'package:orbit/core/services/crm_data_change_service.dart';
import 'package:orbit/core/services/current_employee_id_provider.dart';
import 'package:orbit/features/interactions/data/datasources/remote/interactions_remote_data_source.dart';
import 'package:orbit/features/interactions/data/repositories/interactions_repository_impl.dart';
import 'package:orbit/features/interactions/domain/repositories/interactions_repository.dart';
import 'package:orbit/features/interactions/domain/usecases/add_interaction_usecase.dart';
import 'package:orbit/features/interactions/domain/usecases/delete_interaction_usecase.dart';
import 'package:orbit/features/interactions/domain/usecases/get_interactions_usecase.dart';
import 'package:orbit/features/interactions/domain/usecases/update_interaction_usecase.dart';
import 'package:orbit/features/interactions/domain/usecases/watch_interaction_changes_usecase.dart';
import 'package:orbit/features/interactions/presentation/cubits/interaction_delete/interaction_delete_cubit.dart';
import 'package:orbit/features/interactions/presentation/cubits/interaction_form/interaction_form_cubit.dart';
import 'package:orbit/features/interactions/presentation/blocs/interactions_list/interactions_list_bloc.dart';

/// Registers the interactions feature dependencies (DI-5), in dependency
/// order: datasource → repository → use cases → holders.
Future<void> initInteractionsModule(GetIt getIt) async {
  // Data source
  getIt.registerLazySingleton<InteractionsRemoteDataSource>(
    () => InteractionsRemoteDataSource(getIt<BaseApiClient>()),
  );

  // Repository (the CRM change service is the core broadcast singleton).
  getIt.registerLazySingleton<InteractionsRepository>(
    () => InteractionsRepositoryImpl(
      getIt<InteractionsRemoteDataSource>(),
      getIt<CrmDataChangeService>(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton<GetInteractionsUseCase>(
    () => GetInteractionsUseCase(getIt<InteractionsRepository>()),
  );
  getIt.registerLazySingleton<AddInteractionUseCase>(
    () => AddInteractionUseCase(
      getIt<InteractionsRepository>(),
      getIt<CurrentEmployeeIdProvider>(),
    ),
  );
  getIt.registerLazySingleton<UpdateInteractionUseCase>(
    () => UpdateInteractionUseCase(getIt<InteractionsRepository>()),
  );
  getIt.registerLazySingleton<DeleteInteractionUseCase>(
    () => DeleteInteractionUseCase(getIt<InteractionsRepository>()),
  );
  getIt.registerLazySingleton<WatchInteractionChangesUseCase>(
    () => WatchInteractionChangesUseCase(getIt<CrmDataChangeService>()),
  );

  // Holders (factory — one set per screen, DI-3)
  getIt.registerFactory<InteractionsListBloc>(
    () => InteractionsListBloc(
      getIt<GetInteractionsUseCase>(),
      getIt<WatchInteractionChangesUseCase>(),
    ),
  );
  getIt.registerFactory<InteractionFormCubit>(
    () => InteractionFormCubit(
      getIt<AddInteractionUseCase>(),
      getIt<UpdateInteractionUseCase>(),
    ),
  );
  getIt.registerFactory<InteractionDeleteCubit>(
    () => InteractionDeleteCubit(getIt<DeleteInteractionUseCase>()),
  );
}
