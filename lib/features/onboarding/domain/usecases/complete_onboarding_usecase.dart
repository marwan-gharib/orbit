import 'package:orbit/core/utils/api_result.dart';

import '../repositories/onboarding_repository.dart';

/// Persists the onboarding completion flag.
/// Called when user taps "Get started" (last slide) or "Skip" (any slide).
class CompleteOnboardingUseCase {
  CompleteOnboardingUseCase(this._repository);

  final OnboardingRepository _repository;

  Future<ApiResult<void>> call() => _repository.completeOnboarding();
}
