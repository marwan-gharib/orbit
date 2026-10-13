import 'package:flutter/material.dart';

/// Raw palette. Widgets never read these directly (UI-1) — they go through
/// `AppColorsExtension` on the theme. The theme in `app_theme.dart` is the
/// only consumer.
abstract final class AppColors {
  // Light
  static const Color lightPrimary = Color(0xFF4A5BD4);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightSecondary = Color(0xFF585B72);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFFCF8FF);
  static const Color lightOnSurface = Color(0xFF1B1B21);
  static const Color lightError = Color(0xFFBA1A1A);
  static const Color lightOnError = Color(0xFFFFFFFF);

  // Dark
  static const Color darkPrimary = Color(0xFFBAC3FF);
  static const Color darkOnPrimary = Color(0xFF122A8C);
  static const Color darkSecondary = Color(0xFFC1C5DD);
  static const Color darkOnSecondary = Color(0xFF2A2E42);
  static const Color darkSurface = Color(0xFF131318);
  static const Color darkOnSurface = Color(0xFFE4E1E9);
  static const Color darkError = Color(0xFFFFB4AB);
  static const Color darkOnError = Color(0xFF690005);
}
