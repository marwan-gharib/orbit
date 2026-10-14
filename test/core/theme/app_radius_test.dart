import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/responsive/responsive.dart';
import 'package:orbit/core/theme/app_radius.dart';

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

  test('should scale radii with the smaller-axis factor rather than width when both are available', () {
    // 12 * 0.5 from radius — the width axis would have given 36.
    expect(AppRadius.md, closeTo(6, 0.0001));
    expect(AppRadius.xxl, closeTo(16, 0.0001));
  });

  test('should expose every scale step as a matching border radius when a scaler is bound', () {
    expect(AppRadius.borderXs.topLeft.x, closeTo(AppRadius.xs, 0.0001));
    expect(AppRadius.borderLg.bottomRight.x, closeTo(AppRadius.lg, 0.0001));
    expect(AppRadius.borderFull.topLeft.x, closeTo(AppRadius.full, 0.0001));
  });

  test('should keep the full radius larger than any real corner when a scaler is bound', () {
    // Callers of any height get a stadium because Flutter clamps the painted
    // radius to the shorter side.
    expect(AppRadius.full, greaterThan(400));
  });
}
