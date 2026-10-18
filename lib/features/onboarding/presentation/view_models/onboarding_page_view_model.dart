import 'package:orbit/features/onboarding/domain/entities/onboarding_page.dart';

export 'package:orbit/features/onboarding/domain/entities/onboarding_page.dart'
    show OnboardingIllustrationType;

/// View model for onboarding page — UI-ready data derived from entity.
class OnboardingPageViewModel {
  const OnboardingPageViewModel({
    required this.id,
    required this.headline,
    required this.body,
    required this.illustrationType,
  });

  final int id;
  final String headline;
  final String body;
  final OnboardingIllustrationType illustrationType;
}
