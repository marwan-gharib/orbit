import 'package:get_it/get_it.dart';
import 'package:orbit/core/network/base_api_client.dart';
import 'package:orbit/core/services/crm_data_change_service.dart';
import 'package:orbit/features/customer_notes/data/datasources/remote/customer_notes_remote_data_source.dart';
import 'package:orbit/features/customer_notes/data/repositories/customer_notes_repository_impl.dart';
import 'package:orbit/features/customer_notes/domain/repositories/customer_notes_repository.dart';
import 'package:orbit/features/customer_notes/domain/usecases/add_customer_note_usecase.dart';
import 'package:orbit/features/customer_notes/domain/usecases/delete_customer_note_usecase.dart';
import 'package:orbit/features/customer_notes/domain/usecases/get_customer_notes_usecase.dart';
import 'package:orbit/features/customer_notes/domain/usecases/update_customer_note_usecase.dart';
import 'package:orbit/features/customer_notes/domain/usecases/watch_note_changes_usecase.dart';
import 'package:orbit/features/customer_notes/presentation/cubits/customer_note_delete/customer_note_delete_cubit.dart';
import 'package:orbit/features/customer_notes/presentation/cubits/customer_note_form/customer_note_form_cubit.dart';
import 'package:orbit/features/customer_notes/presentation/cubits/customer_notes_list/customer_notes_list_cubit.dart';

/// Registers the customer notes feature dependencies (DI-5), in dependency
/// order: datasource → repository → use cases → holders.
Future<void> initCustomerNotesModule(GetIt getIt) async {
  // Data source
  getIt.registerLazySingleton<CustomerNotesRemoteDataSource>(
    () => CustomerNotesRemoteDataSource(getIt<BaseApiClient>()),
  );

  // Repository (the CRM change service is the core broadcast singleton).
  getIt.registerLazySingleton<CustomerNotesRepository>(
    () => CustomerNotesRepositoryImpl(
      getIt<CustomerNotesRemoteDataSource>(),
      getIt<CrmDataChangeService>(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton<GetCustomerNotesUseCase>(
    () => GetCustomerNotesUseCase(getIt<CustomerNotesRepository>()),
  );
  getIt.registerLazySingleton<AddCustomerNoteUseCase>(
    () => AddCustomerNoteUseCase(getIt<CustomerNotesRepository>()),
  );
  getIt.registerLazySingleton<UpdateCustomerNoteUseCase>(
    () => UpdateCustomerNoteUseCase(getIt<CustomerNotesRepository>()),
  );
  getIt.registerLazySingleton<DeleteCustomerNoteUseCase>(
    () => DeleteCustomerNoteUseCase(getIt<CustomerNotesRepository>()),
  );
  getIt.registerLazySingleton<WatchNoteChangesUseCase>(
    () => WatchNoteChangesUseCase(getIt<CrmDataChangeService>()),
  );

  // Holders (factory — one instance per screen, DI-3)
  getIt.registerFactory<CustomerNotesListCubit>(
    () => CustomerNotesListCubit(
      getCustomerNotes: getIt<GetCustomerNotesUseCase>(),
      watchNoteChanges: getIt<WatchNoteChangesUseCase>(),
    ),
  );
  getIt.registerFactory<CustomerNoteFormCubit>(
    () => CustomerNoteFormCubit(
      getIt<AddCustomerNoteUseCase>(),
      getIt<UpdateCustomerNoteUseCase>(),
    ),
  );
  getIt.registerFactory<CustomerNoteDeleteCubit>(
    () => CustomerNoteDeleteCubit(getIt<DeleteCustomerNoteUseCase>()),
  );
}
