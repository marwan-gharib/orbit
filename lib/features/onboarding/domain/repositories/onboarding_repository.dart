import 'package:orbit/core/utils/api_result.dart';

import '../entities/onboarding_page.dart';

/// Contract for onboarding data access.
/// Implemented in data layer; used by usecases.
abstract interface class OnboardingRepository {
  /// Returns the static list of onboarding pages.
  Future<ApiResult<List<OnboardingPage>>> getPages();

  /// Persists that the user has completed (or skipped) onboarding.
  /// Called when user taps "Get started" or "Skip".
  Future<ApiResult<void>> completeOnboarding();
}
