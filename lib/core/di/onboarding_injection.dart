import 'package:get_it/get_it.dart';

import 'package:orbit/core/local/cache/cache_service.dart';
import 'package:orbit/features/onboarding/data/datasources/local/onboarding_local_data_source.dart';
import 'package:orbit/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:orbit/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:orbit/features/onboarding/domain/usecases/complete_onboarding_usecase.dart';
import 'package:orbit/features/onboarding/domain/usecases/get_onboarding_pages_usecase.dart';
import 'package:orbit/features/onboarding/presentation/cubit/onboarding_cubit.dart';

/// Registers onboarding feature dependencies (DI-5).
/// Call order: datasource → repository → usecases → cubit
Future<void> initOnboardingModule(GetIt getIt) async {
  // Data source
  getIt.registerLazySingleton<OnboardingLocalDataSource>(
    () => OnboardingLocalDataSource(getIt<CacheService>()),
  );

  // Repository
  getIt.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(getIt<OnboardingLocalDataSource>()),
  );

  // Use cases
  getIt.registerLazySingleton<GetOnboardingPagesUseCase>(
    () => GetOnboardingPagesUseCase(getIt<OnboardingRepository>()),
  );

  getIt.registerLazySingleton<CompleteOnboardingUseCase>(
    () => CompleteOnboardingUseCase(getIt<OnboardingRepository>()),
  );

  // Cubit (factory - new instance per onboarding screen)
  getIt.registerFactory<OnboardingCubit>(
    () => OnboardingCubit(
      getIt<GetOnboardingPagesUseCase>(),
      getIt<CompleteOnboardingUseCase>(),
    ),
  );
}
