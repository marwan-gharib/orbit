import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/theme/app_colors.dart';
import 'package:orbit/core/theme/app_theme.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';

void main() {
  // WCAG 2.x relative luminance / contrast ratio, so the AA claims in the
  // palette comments are enforced, not just asserted in prose.
  double luminanceOf(Color color) {
    double channel(double value) => value <= 0.04045
        ? value / 12.92
        : math.pow((value + 0.055) / 1.055, 2.4).toDouble();

    return 0.2126 * channel(color.r) +
        0.7152 * channel(color.g) +
        0.0722 * channel(color.b);
  }

  double contrastOf(Color foreground, Color background) {
    final fg = luminanceOf(foreground);
    final bg = luminanceOf(background);
    return (math.max(fg, bg) + 0.05) / (math.min(fg, bg) + 0.05);
  }

  test('should give dark mode darker surfaces than light mode when built', () {
    expect(
      luminanceOf(AppColorsExtension.dark.background),
      lessThan(luminanceOf(AppColorsExtension.light.background)),
    );
    expect(
      luminanceOf(AppColorsExtension.dark.surface),
      lessThan(luminanceOf(AppColorsExtension.light.surface)),
    );
    expect(
      luminanceOf(AppColorsExtension.dark.surfaceElevated),
      greaterThan(luminanceOf(AppColorsExtension.dark.background)),
      reason: 'elevated surfaces must sit slightly lighter than the scaffold',
    );
  });

  test('should override only the requested token when copyWith', () {
    const source = AppColorsExtension.light;
    final changed = source.copyWith(hint: Colors.purple);

    expect(changed.hint, Colors.purple);
    expect(changed.background, source.background);
    expect(changed.textPrimary, source.textPrimary);
  });

  test('should land halfway between the palettes when lerped at t 0.5', () {
    final lerped = AppColorsExtension.light.lerp(AppColorsExtension.dark, 0.5);

    expect(
      lerped.background,
      Color.lerp(
        AppColorsExtension.light.background,
        AppColorsExtension.dark.background,
        0.5,
      ),
    );
    expect(
      lerped.primary,
      Color.lerp(
        AppColorsExtension.light.primary,
        AppColorsExtension.dark.primary,
        0.5,
      ),
    );
  });

  test('should keep the source palette when lerped at t 0', () {
    final lerped = AppColorsExtension.light.lerp(AppColorsExtension.dark, 0);

    expect(lerped.background, AppColorsExtension.light.background);
    expect(lerped.primary, AppColorsExtension.light.primary);
  });

  test('should clear WCAG AA for every text pair in light mode', () {
    const c = AppColorsExtension.light;

    expect(
      contrastOf(c.textPrimary, c.background),
      greaterThanOrEqualTo(4.5),
      reason: 'textPrimary on background',
    );
    expect(
      contrastOf(c.textSecondary, c.background),
      greaterThanOrEqualTo(4.5),
      reason: 'textSecondary on background',
    );
    expect(
      contrastOf(c.hint, c.surface),
      greaterThanOrEqualTo(4.5),
      reason: 'hint on surface',
    );
    expect(
      contrastOf(c.primary, c.background),
      greaterThanOrEqualTo(4.5),
      reason: 'primary link on background',
    );
    expect(
      contrastOf(c.onPrimary, c.primary),
      greaterThanOrEqualTo(4.5),
      reason: 'button label on primary',
    );
    expect(
      contrastOf(c.error, c.surface),
      greaterThanOrEqualTo(4.5),
      reason: 'error text on surface',
    );
    expect(
      contrastOf(c.primary, c.primaryContainer),
      greaterThanOrEqualTo(4.5),
      reason: 'selected navigation label on its indicator',
    );
  });

  test('should clear WCAG AA for every text pair in dark mode', () {
    const c = AppColorsExtension.dark;

    expect(
      contrastOf(c.textPrimary, c.background),
      greaterThanOrEqualTo(4.5),
      reason: 'textPrimary on background',
    );
    expect(
      contrastOf(c.textSecondary, c.background),
      greaterThanOrEqualTo(4.5),
      reason: 'textSecondary on background',
    );
    expect(
      contrastOf(c.hint, c.background),
      greaterThanOrEqualTo(4.5),
      reason: 'hint on background',
    );
    expect(
      contrastOf(c.primary, c.background),
      greaterThanOrEqualTo(4.5),
      reason: 'primary link on background',
    );
    expect(
      contrastOf(c.onPrimary, c.primary),
      greaterThanOrEqualTo(4.5),
      reason: 'button label on primary',
    );
    expect(
      contrastOf(c.onPrimaryContainer, c.primaryContainer),
      greaterThanOrEqualTo(4.5),
      reason: 'date-picker header text on its header',
    );
    expect(
      contrastOf(c.textPrimary, c.surfaceElevated),
      greaterThanOrEqualTo(4.5),
      reason: 'dialog text on the elevated dialog surface',
    );
    expect(
      contrastOf(c.error, c.background),
      greaterThanOrEqualTo(4.5),
      reason: 'error text on background',
    );
    expect(
      contrastOf(c.success, c.background),
      greaterThanOrEqualTo(4.5),
      reason: 'success text on background',
    );
    expect(
      contrastOf(c.warning, c.background),
      greaterThanOrEqualTo(4.5),
      reason: 'warning text on background',
    );
  });

  test('should expose the soft accent tokens per mode when built', () {
    expect(AppColorsExtension.light.primarySoft, AppColors.primaryLightActive);
    expect(AppColorsExtension.dark.primarySoft, AppColors.primarySoftDark);
    expect(AppColorsExtension.light.successSoft, AppColors.successLightActive);
    expect(AppColorsExtension.dark.successSoft, AppColors.successSoftDark);
  });

  test('should keep the soft accent fills visible on their dark surfaces', () {
    const dark = AppColorsExtension.dark;

    // Standalone chart bars and card dots sit directly on the card surface.
    expect(
      contrastOf(dark.primarySoft, dark.surface),
      greaterThanOrEqualTo(3),
      reason: 'primarySoft on the dark card surface',
    );
    expect(
      contrastOf(dark.primarySoft, dark.background),
      greaterThanOrEqualTo(3),
      reason: 'primarySoft on the dark scaffold',
    );

    // Deliberately subtle: ~2.9:1 on the dark scaffold (light mode is ~1.3:1
    // on the board); the success pill's inner dot carries the meaning.
    expect(
      contrastOf(dark.successSoft, dark.background),
      greaterThanOrEqualTo(2.5),
      reason: 'successSoft on the dark scaffold',
    );
  });

  test('should clear 3:1 for on-color glyphs on every dark fill', () {
    const dark = AppColorsExtension.dark;

    // A single SVG placeholder color (0xFFFFFF -> onPrimary) draws the check,
    // clock, exclamation, and icon-bar glyphs on the primary, success, and
    // error fills. In dark mode those fills are light, so the glyphs render
    // navy and must stay legible on each of them.
    expect(
      contrastOf(dark.onPrimary, dark.primary),
      greaterThanOrEqualTo(3),
      reason: 'glyph on the primary fill',
    );
    expect(
      contrastOf(dark.onPrimary, dark.success),
      greaterThanOrEqualTo(3),
      reason: 'glyph on the success fill',
    );
    expect(
      contrastOf(dark.onPrimary, dark.error),
      greaterThanOrEqualTo(3),
      reason: 'glyph on the error fill',
    );
  });

  test('should clear 3:1 for essential outlines in both modes', () {
    const light = AppColorsExtension.light;
    const dark = AppColorsExtension.dark;

    expect(
      contrastOf(light.borderStrong, light.background),
      greaterThanOrEqualTo(3),
      reason: 'light input border on the scaffold',
    );
    expect(
      contrastOf(light.borderStrong, light.surfaceVariant),
      greaterThanOrEqualTo(3),
      reason: 'light input border on its own fill',
    );
    expect(
      contrastOf(dark.borderStrong, dark.background),
      greaterThanOrEqualTo(3),
      reason: 'dark input border on the scaffold',
    );
    expect(
      contrastOf(dark.borderStrong, dark.surfaceVariant),
      greaterThanOrEqualTo(3),
      reason: 'dark input border on its own fill',
    );
  });

  testWidgets(
    'should expose the light palette through context.colors when the light theme is active',
    (tester) async {
      late AppColorsExtension resolved;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Builder(
            builder: (context) {
              resolved = context.colors;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(resolved.background, AppColorsExtension.light.background);
      expect(resolved.primary, AppColorsExtension.light.primary);
    },
  );

  testWidgets(
    'should expose the dark palette through context.colors when the dark theme is active',
    (tester) async {
      late AppColorsExtension resolved;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.dark,
          home: Builder(
            builder: (context) {
              resolved = context.colors;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(resolved.background, AppColorsExtension.dark.background);
      expect(resolved.primary, AppColorsExtension.dark.primary);
    },
  );
}
