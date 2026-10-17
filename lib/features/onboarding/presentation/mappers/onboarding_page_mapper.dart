import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/features/onboarding/domain/entities/onboarding_page.dart';
import 'package:orbit/features/onboarding/presentation/view_models/onboarding_page_view_model.dart';

/// Maps domain entity to presentation view model.
extension OnboardingPageMapper on OnboardingPage {
  OnboardingPageViewModel toViewModel(Translations t) =>
      OnboardingPageViewModel(
        id: id,
        headline: _getHeadline(t, id),
        body: _getBody(t, id),
        illustrationType: illustrationType, // Same enum type
      );

  String _getHeadline(Translations t, int pageId) {
    return switch (pageId) {
      0 => t.onboarding.slide1.headline,
      1 => t.onboarding.slide2.headline,
      2 => t.onboarding.slide3.headline,
      3 => t.onboarding.slide4.headline,
      _ => '',
    };
  }

  String _getBody(Translations t, int pageId) {
    return switch (pageId) {
      0 => t.onboarding.slide1.body,
      1 => t.onboarding.slide2.body,
      2 => t.onboarding.slide3.body,
      3 => t.onboarding.slide4.body,
      _ => '',
    };
  }
}
