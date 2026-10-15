import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/responsive/responsive.dart';
import 'package:orbit/core/theme/app_spacing.dart';

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

  test('should scale spacing with the smaller-axis factor rather than width when both are available', () {
    // 16 * 0.5 from adapt — the width axis would have given 48.
    expect(AppSpacing.md, closeTo(8, 0.0001));
    expect(AppSpacing.xxxl, closeTo(32, 0.0001));
  });

  test('should build every common padding as a directional inset when a scaler is bound', () {
    expect(AppSpacing.page, isA<EdgeInsetsDirectional>());
    expect(AppSpacing.pageHorizontal, isA<EdgeInsetsDirectional>());
    expect(AppSpacing.card, isA<EdgeInsetsDirectional>());
    expect(AppSpacing.button, isA<EdgeInsetsDirectional>());
  });

  test(
    'should inset the page padding with the md step when a scaler is bound',
    () {
      final insets = AppSpacing.page.resolve(TextDirection.ltr);

      expect(insets.left, closeTo(8, 0.0001));
      expect(insets.top, closeTo(8, 0.0001));
      expect(insets.right, closeTo(8, 0.0001));
      expect(insets.bottom, closeTo(8, 0.0001));
    },
  );

  test('should pad buttons with lg horizontally and sm vertically when a scaler is bound', () {
    final insets = AppSpacing.button.resolve(TextDirection.ltr);

    expect(insets.left, closeTo(12, 0.0001));
    expect(insets.top, closeTo(4, 0.0001));
    expect(insets.right, closeTo(12, 0.0001));
    expect(insets.bottom, closeTo(4, 0.0001));
  });
}
