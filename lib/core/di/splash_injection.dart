import 'package:get_it/get_it.dart';

import 'package:orbit/core/local/cache/cache_service.dart';
import 'package:orbit/core/local/secure/secure_storage_client.dart';
import 'package:orbit/features/splash/data/datasources/local/splash_local_data_source.dart';
import 'package:orbit/features/splash/data/repositories/splash_repository_impl.dart';
import 'package:orbit/features/splash/domain/repositories/splash_repository.dart';
import 'package:orbit/features/splash/domain/usecases/check_startup_status_usecase.dart';
import 'package:orbit/features/splash/presentation/cubit/splash_cubit.dart';

/// Registers splash feature dependencies (DI-5).
Future<void> initSplashModule(GetIt getIt) async {
  // Data source
  getIt.registerLazySingleton<SplashLocalDataSource>(
    () => SplashLocalDataSource(
      cache: getIt<CacheService>(),
      secureStorage: getIt<SecureStorageClient>(),
    ),
  );

  // Repository
  getIt.registerLazySingleton<SplashRepository>(
    () => SplashRepositoryImpl(getIt<SplashLocalDataSource>()),
  );

  // Use cases
  getIt.registerLazySingleton<CheckStartupStatusUseCase>(
    () => CheckStartupStatusUseCase(getIt<SplashRepository>()),
  );

  // Cubit (factory - new instance per splash screen)
  getIt.registerFactory<SplashCubit>(
    () => SplashCubit(getIt<CheckStartupStatusUseCase>()),
  );
}
