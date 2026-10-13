import 'package:flutter/material.dart';

import 'package:orbit/core/theme/extensions/colors_extension.dart';

/// Single source of the app's [ThemeData]. Widgets read colors and text from
/// the theme (UI-1); none of them builds a `ThemeData` inline.
abstract final class AppTheme {
  static ThemeData get light =>
      _base(brightness: Brightness.light, colors: AppColorsExtension.light);

  static ThemeData get dark =>
      _base(brightness: Brightness.dark, colors: AppColorsExtension.dark);

  static ThemeData _base({
    required Brightness brightness,
    required AppColorsExtension colors,
  }) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: colors.primary,
      onPrimary: colors.onPrimary,
      secondary: colors.secondary,
      onSecondary: colors.onSecondary,
      error: colors.error,
      onError: colors.onError,
      surface: colors.surface,
      onSurface: colors.onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: colors.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      extensions: <ThemeExtension<dynamic>>[colors],
    );
  }
}
