import 'package:flutter/material.dart';

import 'package:orbit/core/constants/fonts.dart';
import 'package:orbit/core/responsive/responsive.dart';

/// The type scale (display, headline, title, body, label — L/M/S). Sizes run
/// through `Responsive.font` so they track the screen; line heights are design
/// ratios, so they follow automatically. Weights are app-tuned M3: bold
/// display/headline, semibold titles, regular body, medium labels.
///
/// Colors never live here — `AppTextStylesExtension` attaches them so the
/// same styles adapt to light/dark (UI-1).
abstract final class AppTextStyles {
  static TextStyle get displayLarge => _style(
    size: 57,
    lineHeight: 64,
    weight: FontWeight.w700,
    tracking: -0.25,
  );
  static TextStyle get displayMedium =>
      _style(size: 45, lineHeight: 52, weight: FontWeight.w700);
  static TextStyle get displaySmall =>
      _style(size: 36, lineHeight: 44, weight: FontWeight.w700);

  static TextStyle get headlineLarge =>
      _style(size: 32, lineHeight: 40, weight: FontWeight.w700);
  static TextStyle get headlineMedium =>
      _style(size: 28, lineHeight: 36, weight: FontWeight.w700);
  static TextStyle get headlineSmall =>
      _style(size: 24, lineHeight: 32, weight: FontWeight.w700);

  static TextStyle get titleLarge =>
      _style(size: 22, lineHeight: 28, weight: FontWeight.w600);
  static TextStyle get titleMedium =>
      _style(size: 16, lineHeight: 24, weight: FontWeight.w600, tracking: 0.15);
  static TextStyle get titleSmall =>
      _style(size: 14, lineHeight: 20, weight: FontWeight.w600, tracking: 0.1);

  static TextStyle get bodyLarge =>
      _style(size: 16, lineHeight: 24, weight: FontWeight.w400, tracking: 0.5);
  static TextStyle get bodyMedium =>
      _style(size: 14, lineHeight: 20, weight: FontWeight.w400, tracking: 0.25);
  static TextStyle get bodySmall =>
      _style(size: 12, lineHeight: 16, weight: FontWeight.w400, tracking: 0.4);

  static TextStyle get labelLarge =>
      _style(size: 14, lineHeight: 20, weight: FontWeight.w500, tracking: 0.1);
  static TextStyle get labelMedium =>
      _style(size: 12, lineHeight: 16, weight: FontWeight.w500, tracking: 0.5);
  static TextStyle get labelSmall =>
      _style(size: 11, lineHeight: 16, weight: FontWeight.w500, tracking: 0.5);

  /// [lineHeight] and [tracking] are design-px values at [size].
  static TextStyle _style({
    required double size,
    required double lineHeight,
    required FontWeight weight,
    double tracking = 0,
  }) {
    return TextStyle(
      fontFamily: Fonts.family,
      fontSize: Responsive.font(size),
      height: lineHeight / size,
      fontWeight: weight,
      letterSpacing: Responsive.font(tracking),
    );
  }
}
