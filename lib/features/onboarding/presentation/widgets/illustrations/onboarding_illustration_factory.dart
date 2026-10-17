import 'package:flutter/widgets.dart';
import 'package:orbit/features/onboarding/presentation/view_models/onboarding_page_view_model.dart';
import 'package:orbit/features/onboarding/presentation/widgets/illustrations/slide1_projects_illustration.dart';
import 'package:orbit/features/onboarding/presentation/widgets/illustrations/slide2_people_illustration.dart';
import 'package:orbit/features/onboarding/presentation/widgets/illustrations/slide3_finance_illustration.dart';
import 'package:orbit/features/onboarding/presentation/widgets/illustrations/slide4_insights_illustration.dart';

/// Factory for creating the correct illustration widget for a page.
Widget createIllustration({
  required OnboardingIllustrationType type,
  required double progress,
  required bool isActive,
  required Size size,
  Size? regionSize,
}) {
  return switch (type) {
    OnboardingIllustrationType.projects => Slide1ProjectsIllustration(
      progress: progress,
      isActive: isActive,
      size: size,
      regionSize: regionSize,
    ),
    OnboardingIllustrationType.people => Slide2PeopleIllustration(
      progress: progress,
      isActive: isActive,
      size: size,
    ),
    OnboardingIllustrationType.finance => Slide3FinanceIllustration(
      progress: progress,
      isActive: isActive,
      size: size,
      regionSize: regionSize,
    ),
    OnboardingIllustrationType.insights => Slide4InsightsIllustration(
      progress: progress,
      isActive: isActive,
      size: size,
    ),
  };
}
