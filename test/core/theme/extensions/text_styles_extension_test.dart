import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/theme/app_theme.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';

void main() {
  test('should color every role from the palette when built for colors', () {
    final styles = AppTextStylesExtension.forColors(AppColorsExtension.light);
    final expected = AppColorsExtension.light.textPrimary;

    expect(styles.displayLarge.color, expected);
    expect(styles.bodyMedium.color, expected);
    expect(styles.labelSmall.color, expected);
  });

  test('should override only the requested role when copyWith', () {
    final source = AppTextStylesExtension.forColors(AppColorsExtension.light);
    final changed = source.copyWith(
      bodyMedium: const TextStyle(color: Colors.purple),
    );

    expect(changed.bodyMedium.color, Colors.purple);
    expect(changed.bodyLarge.color, source.bodyLarge.color);
    expect(changed.labelLarge, source.labelLarge);
  });

  test('should keep the source style when lerped at t 0', () {
    final light = AppTextStylesExtension.forColors(AppColorsExtension.light);
    final dark = AppTextStylesExtension.forColors(AppColorsExtension.dark);
    final lerped = light.lerp(dark, 0);

    expect(lerped.bodyMedium.color, light.bodyMedium.color);
    expect(lerped.bodyMedium.fontSize, light.bodyMedium.fontSize);
  });

  testWidgets(
    'should expose the dark scale through context.textStyles when the dark theme is active',
    (tester) async {
      late AppTextStylesExtension resolved;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.dark,
          home: Builder(
            builder: (context) {
              resolved = context.textStyles;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(resolved.bodyLarge.color, AppColorsExtension.dark.textPrimary);
      expect(
        resolved.bodyLarge.fontSize,
        AppTheme.dark.textTheme.bodyLarge?.fontSize,
      );
    },
  );
}
