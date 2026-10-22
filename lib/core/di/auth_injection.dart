import 'package:get_it/get_it.dart';

import 'package:orbit/core/local/cache/cache_service.dart';
import 'package:orbit/core/local/secure/secure_storage_client.dart';
import 'package:orbit/core/network/base_api_client.dart';
import 'package:orbit/core/router/pending_signup_session.dart';
import 'package:orbit/features/auth/data/datasources/local/auth_local_data_source.dart';
import 'package:orbit/features/auth/data/datasources/remote/auth_remote_data_source.dart';
import 'package:orbit/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:orbit/features/auth/domain/repositories/auth_repository.dart';
import 'package:orbit/features/auth/domain/usecases/get_employee_status_usecase.dart';
import 'package:orbit/features/auth/domain/usecases/get_session_info_usecase.dart';
import 'package:orbit/features/auth/domain/usecases/login_usecase.dart';
import 'package:orbit/features/auth/domain/usecases/logout_usecase.dart';
import 'package:orbit/features/auth/domain/usecases/signup_usecase.dart';
import 'package:orbit/features/auth/presentation/cubits/employee_status/employee_status_cubit.dart';
import 'package:orbit/features/auth/presentation/cubits/login/login_cubit.dart';
import 'package:orbit/features/auth/presentation/cubits/signup/signup_cubit.dart';

/// Registers auth feature dependencies (DI-5), in dependency order.
Future<void> initAuthModule(GetIt getIt) async {
  // Data sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(getIt<BaseApiClient>()),
  );
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSource(
      cache: getIt<CacheService>(),
      secureStorage: getIt<SecureStorageClient>(),
      pendingSession: getIt<PendingSignupSession>(),
    ),
  );

  // Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      getIt<AuthRemoteDataSource>(),
      getIt<AuthLocalDataSource>(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<SignupUseCase>(
    () => SignupUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<GetEmployeeStatusUseCase>(
    () => GetEmployeeStatusUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<GetSessionInfoUseCase>(
    () => GetSessionInfoUseCase(getIt<AuthRepository>()),
  );

  // Cubits (factory — one instance per screen, DI-3)
  getIt.registerFactory<LoginCubit>(() => LoginCubit(getIt<LoginUseCase>()));
  getIt.registerFactory<SignupCubit>(() => SignupCubit(getIt<SignupUseCase>()));
  getIt.registerFactory<EmployeeStatusCubit>(
    () => EmployeeStatusCubit(getIt<GetEmployeeStatusUseCase>()),
  );

  // Resume the pending-approval flow across launches. A failed read is not
  // fatal: the app starts signed out and the user can sign in again.
  final pending = await getIt<AuthLocalDataSource>().readPendingSignupEmail();
  final pendingEmail = pending.dataOrNull;
  if (pendingEmail != null && pendingEmail.isNotEmpty) {
    getIt<PendingSignupSession>().start(pendingEmail);
  }
}
