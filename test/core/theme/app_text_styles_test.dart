import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/constants/fonts.dart';
import 'package:orbit/core/responsive/responsive.dart';
import 'package:orbit/core/theme/app_text_styles.dart';

import 'harness.dart';

void main() {
  setUp(() {
    Responsive.bind(
      const AxisTestScaler(
        widthFactor: 3,
        heightFactor: 4,
        adaptiveFactor: 0.5,
      ),
    );
  });

  tearDown(Responsive.unbind);

  test(
    'should scale every size with the adaptive factor when a scaler is bound',
    () {
      expect(AppTextStyles.displayLarge.fontSize, closeTo(57 * 0.5, 0.0001));
      expect(AppTextStyles.bodyMedium.fontSize, closeTo(14 * 0.5, 0.0001));
      expect(AppTextStyles.labelSmall.fontSize, closeTo(11 * 0.5, 0.0001));
    },
  );

  test('should scale letter spacing with the adaptive factor when a scaler is bound', () {
    expect(AppTextStyles.bodyMedium.letterSpacing, closeTo(0.25 * 0.5, 0.0001));
    expect(
      AppTextStyles.displayLarge.letterSpacing,
      closeTo(-0.25 * 0.5, 0.0001),
    );
  });

  test('should keep the design line-height ratio when font sizes scale', () {
    expect(AppTextStyles.bodyMedium.height, closeTo(20 / 14, 0.0001));
    expect(AppTextStyles.displayLarge.height, closeTo(64 / 57, 0.0001));
  });

  test(
    'should keep the planned weight of every role when styles are built',
    () {
      expect(AppTextStyles.headlineSmall.fontWeight, FontWeight.w700);
      expect(AppTextStyles.titleLarge.fontWeight, FontWeight.w600);
      expect(AppTextStyles.bodyLarge.fontWeight, FontWeight.w400);
      expect(AppTextStyles.labelMedium.fontWeight, FontWeight.w500);
    },
  );

  test('should take the family from the single Fonts constant when styles are built', () {
    expect(AppTextStyles.bodyLarge.fontFamily, Fonts.family);
    expect(AppTextStyles.labelSmall.fontFamily, Fonts.family);
  });

  group('while no scaler is bound', () {
    setUp(Responsive.unbind);

    test(
      'should pass design values through unchanged when a scaler is not bound',
      () {
        expect(AppTextStyles.bodyLarge.fontSize, 16);
        expect(AppTextStyles.bodyLarge.letterSpacing, 0.5);
      },
    );
  });
}
