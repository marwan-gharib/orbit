import 'package:orbit/core/utils/api_result.dart';

import '../repositories/onboarding_repository.dart';
import '../entities/onboarding_page.dart';

/// Returns the static list of onboarding pages.
class GetOnboardingPagesUseCase {
  GetOnboardingPagesUseCase(this._repository);

  final OnboardingRepository _repository;

  Future<ApiResult<List<OnboardingPage>>> call() => _repository.getPages();
}
