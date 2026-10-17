import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/features/onboarding/data/models/onboarding_page_model.dart';
import 'package:orbit/features/onboarding/domain/entities/onboarding_page.dart';

void main() {
  group('OnboardingPageModel', () {
    const tModel = OnboardingPageModel(
      id: 2,
      illustrationType: OnboardingIllustrationType.finance,
    );

    const tEntity = OnboardingPage(
      id: 2,
      illustrationType: OnboardingIllustrationType.finance,
    );

    test('toEntity maps every field', () {
      final entity = tModel.toEntity();

      expect(entity, tEntity);
      expect(entity.id, tModel.id);
      expect(entity.illustrationType, tModel.illustrationType);
    });

    test('fromEntity maps every field', () {
      final model = OnboardingPageModel.fromEntity(tEntity);

      expect(model.id, tEntity.id);
      expect(model.illustrationType, tEntity.illustrationType);
    });

    test('toEntity then fromEntity round-trips', () {
      final roundTripped = OnboardingPageModel.fromEntity(tModel.toEntity());
      expect(roundTripped.id, tModel.id);
      expect(roundTripped.illustrationType, tModel.illustrationType);
    });
  });
}
