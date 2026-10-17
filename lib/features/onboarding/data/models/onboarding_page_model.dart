import '../../domain/entities/onboarding_page.dart';

/// Data model for an onboarding page — maps to/from domain entity.
class OnboardingPageModel {
  const OnboardingPageModel({
    required this.id,
    required this.illustrationType,
  });

  final int id;
  final OnboardingIllustrationType illustrationType;

  /// Creates an entity from this model.
  OnboardingPage toEntity() => OnboardingPage(
    id: id,
    illustrationType: illustrationType,
  );

  /// Creates a model from an entity (for completeness, though not used here).
  factory OnboardingPageModel.fromEntity(OnboardingPage entity) =>
      OnboardingPageModel(
        id: entity.id,
        illustrationType: entity.illustrationType,
      );
}
