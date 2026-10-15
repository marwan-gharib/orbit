import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/theme/app_theme.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';

void main() {
  const colors = AppColorsExtension.light;

  test('should register both theme extensions when built', () {
    final lightStyles = AppTheme.light.extension<AppTextStylesExtension>();
    final darkStyles = AppTheme.dark.extension<AppTextStylesExtension>();

    expect(AppTheme.light.extension<AppColorsExtension>(), same(colors));
    expect(lightStyles, isNotNull);
    expect(
      AppTheme.dark.extension<AppColorsExtension>(),
      same(AppColorsExtension.dark),
    );
    expect(darkStyles, isNotNull);
    expect(darkStyles?.bodyLarge.color, AppColorsExtension.dark.textPrimary);
  });

  test('should map the color scheme from the palette when built', () {
    final lightScheme = AppTheme.light.colorScheme;

    expect(lightScheme.brightness, Brightness.light);
    expect(lightScheme.primary, colors.primary);
    expect(lightScheme.onPrimary, colors.onPrimary);
    expect(lightScheme.surface, colors.surface);
    expect(lightScheme.onSurface, colors.textPrimary);
    expect(lightScheme.scrim, colors.scrim);
    expect(lightScheme.inversePrimary, colors.inversePrimary);
    expect(AppTheme.dark.colorScheme.brightness, Brightness.dark);
    expect(
      AppTheme.dark.scaffoldBackgroundColor,
      AppColorsExtension.dark.background,
    );
  });

  test('should style the button families and inputs when built', () {
    final theme = AppTheme.light;

    expect(theme.filledButtonTheme.style?.backgroundColor, isNotNull);
    expect(theme.elevatedButtonTheme.style?.elevation, isNotNull);
    expect(theme.outlinedButtonTheme.style?.side, isNotNull);
    expect(theme.textButtonTheme.style?.foregroundColor, isNotNull);
    expect(theme.iconButtonTheme.style?.minimumSize, isNotNull);
    expect(theme.inputDecorationTheme.filled, isTrue);
    expect(theme.inputDecorationTheme.enabledBorder, isA<OutlineInputBorder>());
    expect(
      theme.inputDecorationTheme.focusedBorder?.borderSide.color,
      colors.primary,
    );
    expect(
      theme.inputDecorationTheme.errorBorder?.borderSide.color,
      colors.error,
    );
  });

  test('should style the surfaces, feedback and pickers when built', () {
    final theme = AppTheme.light;

    expect(theme.cardTheme.color, colors.surface);
    expect(theme.dialogTheme.backgroundColor, colors.surfaceElevated);
    expect(theme.bottomSheetTheme.showDragHandle, isTrue);
    expect(theme.snackBarTheme.backgroundColor, colors.textPrimary);
    expect(theme.snackBarTheme.contentTextStyle?.color, colors.background);
    expect(theme.dividerTheme.color, colors.border);
    expect(theme.progressIndicatorTheme.color, colors.primary);
    expect(theme.floatingActionButtonTheme.backgroundColor, colors.primary);
    expect(
      theme.datePickerTheme.headerBackgroundColor,
      colors.primaryContainer,
    );
    expect(theme.timePickerTheme.backgroundColor, colors.surfaceElevated);
  });

  test('should style the navigation surfaces when built', () {
    final theme = AppTheme.light;

    expect(theme.appBarTheme.backgroundColor, colors.background);
    expect(theme.appBarTheme.titleTextStyle?.color, colors.textPrimary);
    expect(theme.navigationBarTheme.indicatorColor, colors.primaryContainer);
    expect(theme.bottomNavigationBarTheme.selectedItemColor, colors.primary);
    expect(theme.tabBarTheme.indicatorColor, colors.primary);
    expect(theme.listTileTheme.contentPadding, isA<EdgeInsetsDirectional>());
  });

  test('should style the selection controls when built', () {
    final theme = AppTheme.light;

    expect(theme.chipTheme.backgroundColor, colors.surfaceVariant);
    expect(theme.switchTheme.trackColor, isNotNull);
    expect(theme.checkboxTheme.fillColor, isNotNull);
    expect(theme.radioTheme.fillColor, isNotNull);
  });

  test('should install the palette-colored text theme when built', () {
    expect(AppTheme.light.textTheme.bodyLarge?.color, colors.textPrimary);
    expect(
      AppTheme.dark.textTheme.bodyLarge?.color,
      AppColorsExtension.dark.textPrimary,
    );
  });

  test('should give light mode dark system overlay icons when built', () {
    final style = AppTheme.overlayStyle(Brightness.light);

    expect(style.statusBarIconBrightness, Brightness.dark);
    expect(style.systemNavigationBarIconBrightness, Brightness.dark);
    expect(style.statusBarColor, Colors.transparent);
  });

  test('should give dark mode light system overlay icons when built', () {
    final style = AppTheme.overlayStyle(Brightness.dark);

    expect(style.statusBarIconBrightness, Brightness.light);
    expect(style.systemNavigationBarIconBrightness, Brightness.light);
    expect(style.systemNavigationBarColor, Colors.transparent);
  });
}
