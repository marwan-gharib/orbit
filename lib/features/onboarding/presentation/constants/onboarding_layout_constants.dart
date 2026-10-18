import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:orbit/core/responsive/responsive.dart';
import 'package:orbit/core/theme/app_radius.dart';
import 'package:orbit/core/theme/app_spacing.dart';

/// Named layout ratios for the onboarding screen. Every size is a fraction of
/// the available size inside the `SafeArea` (`W`/`H`) or of the illustration
/// square side `S` — never raw pixels (UI-6).
abstract final class OnboardingLayoutRatios {
  /// Vertical rhythm as fractions of `H`.
  static const double topPaddingOfHeight = 0.01;
  static const double topBarOfHeight = 0.07;
  static const double controlsOfHeight = 0.07;
  static const double indicatorAboveOfHeight = 0.02;
  static const double indicatorBelowOfHeight = 0.025;
  static const double bottomPaddingOfHeight = 0.025;

  /// Entrance translate distances as fractions of `H` (transform-only, the
  /// layout never moves).
  static const double barSlideOfHeight = 0.03;

  /// Inner slide of the top/bottom bar entrances, as a fraction of the bars'
  /// own height: the pixel slide `barSlideOfHeight·H` expressed through a bar
  /// height of `topBarOfHeight·H` (= 3/7), so it needs no pixel offset.
  static const double barInnerSlideOfBarHeight =
      barSlideOfHeight / topBarOfHeight;
  static const double headlineSlideOfHeight = 0.03;
  static const double bodySlideOfHeight = 0.025;

  /// Page-area internals.
  static const double illustrationOfWidth = 0.88;
  static const double illustrationToTextGapOfHeight = 0.025;
  static const double textGapOfHeight = 0.012;

  /// Indicator: active pill width as a multiple of the dot size.
  static const double dotPillWidthFactor = 3.0;

  /// Next button on slides 1–3: fraction of the remaining row width, with a
  /// design-baseline minimum that fits "Next" + arrow.
  static const double compactNextWidthFraction = 0.6;
  static const double minNextButtonBaseWidth = 120;

  /// Crossfade slide distance of the Next/Get started label, as a fraction of
  /// the button height.
  static const double nextLabelSlideOfButtonHeight = 0.4;

  /// Devices at or below this illustration side run no idle loops
  /// (FEATURE.md §10 low-end fallback).
  static const double lowEndMaxSide = 360;
}

/// Widget keys for the onboarding layout so tests can assert geometry without
/// hunting widget internals.
abstract final class OnboardingLayoutKeys {
  static const Key topBar = Key('onboarding_top_bar');
  static const Key pageArea = Key('onboarding_page_area');
  static const Key indicator = Key('onboarding_indicator');
  static const Key controls = Key('onboarding_controls');
  static const Key skipButton = Key('onboarding_skip_button');
  static const Key backButton = Key('onboarding_back_button');
  static const Key nextButton = Key('onboarding_next_button');
  static const Key headline = Key('onboarding_headline');
  static const Key body = Key('onboarding_body');
  static const Key illustration = Key('onboarding_illustration');
}

/// Single source of truth for onboarding layout sizes, derived from the
/// available size inside the `SafeArea` through [OnboardingLayoutRatios]. The
/// screen positions every element from these values only, so animation never
/// moves or resizes layout.
@immutable
class OnboardingLayout {
  const OnboardingLayout({required this.availableSize});

  factory OnboardingLayout.fromSize(Size availableSize) =>
      OnboardingLayout(availableSize: availableSize);

  final Size availableSize;

  /// Smallest interactive dimension, from the app's 48 dp tap-target rule.
  static double get minTouchTarget => Responsive.adapt(48);

  static double get minButtonHeight => Responsive.adapt(48);
  static double get maxButtonHeight => Responsive.adapt(56);

  /// Large-screen bound for the illustration: the design baseline's short
  /// side through the clamped `Responsive.adapt` scale, same policy as the
  /// splash stage.
  static double get maxIllustrationSide =>
      Responsive.adapt(Responsive.designSize.shortestSide);

  double get height => availableSize.height;

  double get topPadding =>
      OnboardingLayoutRatios.topPaddingOfHeight * availableSize.height;

  double get topBarHeight =>
      (OnboardingLayoutRatios.topBarOfHeight * availableSize.height).clamp(
        minTouchTarget,
        maxButtonHeight,
      );

  double get controlsHeight =>
      (OnboardingLayoutRatios.controlsOfHeight * availableSize.height).clamp(
        minButtonHeight,
        maxButtonHeight,
      );

  double get indicatorAbove =>
      OnboardingLayoutRatios.indicatorAboveOfHeight * availableSize.height;

  double get indicatorBelow =>
      OnboardingLayoutRatios.indicatorBelowOfHeight * availableSize.height;

  /// The indicator sits in a fixed band so it never moves vertically.
  double get indicatorHeight => minTouchTarget;

  double get bottomPadding =>
      OnboardingLayoutRatios.bottomPaddingOfHeight * availableSize.height;

  double get pagePadding => AppSpacing.lg;

  double get illustrationToTextGap =>
      OnboardingLayoutRatios.illustrationToTextGapOfHeight *
      availableSize.height;

  double get textGap =>
      OnboardingLayoutRatios.textGapOfHeight * availableSize.height;

  double get headlineSlide =>
      OnboardingLayoutRatios.headlineSlideOfHeight * availableSize.height;

  double get bodySlide =>
      OnboardingLayoutRatios.bodySlideOfHeight * availableSize.height;

  double get buttonHeight => controlsHeight;

  double get buttonCornerRadius => AppRadius.md;

  double get backSlotWidth => buttonHeight + AppSpacing.sm;

  double get nextLabelSlide =>
      OnboardingLayoutRatios.nextLabelSlideOfButtonHeight * buttonHeight;

  /// Icon inside the Next / Get started button.
  static double get nextIconSize => Responsive.adapt(20);

  double get dotSize => AppSpacing.sm;

  double get dotSpacing => AppSpacing.xs;

  double get dotPillWidth =>
      dotSize * OnboardingLayoutRatios.dotPillWidthFactor;

  static double get minNextButtonWidth =>
      Responsive.adapt(OnboardingLayoutRatios.minNextButtonBaseWidth);

  /// Illustration side: a square inside the page region, shrunk by text
  /// pressure or short (landscape) screens and capped for tablets.
  double illustrationSide({
    required double maxWidth,
    required double maxHeight,
  }) => math.min(
    math.min(OnboardingLayoutRatios.illustrationOfWidth * maxWidth, maxHeight),
    maxIllustrationSide,
  );

  /// Width factor of the compact Next button inside its available row width.
  static double compactNextWidthFactor(double availableWidth) {
    final fromMin = minNextButtonWidth / availableWidth;
    return math
        .max(OnboardingLayoutRatios.compactNextWidthFraction, fromMin)
        .clamp(0.0, 1.0);
  }
}
