import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/features/onboarding/domain/entities/onboarding_page.dart';
import 'package:orbit/features/onboarding/presentation/mappers/onboarding_page_mapper.dart';

void main() {
  late Translations t;

  setUp(() => t = Translations());

  group('OnboardingPageMapper', () {
    test('should map slide 1 headline and body from slang', () {
      final page = OnboardingPage(
        id: 0,
        illustrationType: OnboardingIllustrationType.projects,
      );

      final viewModel = page.toViewModel(t);

      expect(viewModel.id, 0);
      expect(viewModel.headline, t.onboarding.slide1.headline);
      expect(viewModel.body, t.onboarding.slide1.body);
      expect(viewModel.illustrationType, OnboardingIllustrationType.projects);
    });

    test('should map slide 2 headline and body from slang', () {
      final page = OnboardingPage(
        id: 1,
        illustrationType: OnboardingIllustrationType.people,
      );

      final viewModel = page.toViewModel(t);

      expect(viewModel.id, 1);
      expect(viewModel.headline, t.onboarding.slide2.headline);
      expect(viewModel.body, t.onboarding.slide2.body);
      expect(viewModel.illustrationType, OnboardingIllustrationType.people);
    });

    test('should map slide 3 headline and body from slang', () {
      final page = OnboardingPage(
        id: 2,
        illustrationType: OnboardingIllustrationType.finance,
      );

      final viewModel = page.toViewModel(t);

      expect(viewModel.id, 2);
      expect(viewModel.headline, t.onboarding.slide3.headline);
      expect(viewModel.body, t.onboarding.slide3.body);
      expect(viewModel.illustrationType, OnboardingIllustrationType.finance);
    });

    test('should map slide 4 headline and body from slang', () {
      final page = OnboardingPage(
        id: 3,
        illustrationType: OnboardingIllustrationType.insights,
      );

      final viewModel = page.toViewModel(t);

      expect(viewModel.id, 3);
      expect(viewModel.headline, t.onboarding.slide4.headline);
      expect(viewModel.body, t.onboarding.slide4.body);
      expect(viewModel.illustrationType, OnboardingIllustrationType.insights);
    });

    test('should return empty strings for an unknown page id', () {
      final page = OnboardingPage(
        id: 42,
        illustrationType: OnboardingIllustrationType.projects,
      );

      final viewModel = page.toViewModel(t);

      expect(viewModel.headline, isEmpty);
      expect(viewModel.body, isEmpty);
    });
  });
}
