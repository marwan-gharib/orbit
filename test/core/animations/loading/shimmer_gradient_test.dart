import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/animations/loading/shimmer_scope.dart';
import 'package:orbit/core/animations/tokens/app_animation_constants.dart';

void main() {
  const base = Color(0x14000000);
  const highlight = Color(0x33000000);

  LinearGradient build({required double sweep, required bool mirrored}) =>
      ShimmerGradient.build(
        sweep: sweep,
        base: base,
        highlight: highlight,
        band: AppAnimationConstants.shimmerSweepBand,
        mirrored: mirrored,
      );

  double beginX(LinearGradient gradient) => (gradient.begin as Alignment).x;
  double endX(LinearGradient gradient) => (gradient.end as Alignment).x;

  test('should place the band fully outside the leading edge when the sweep is zero', () {
    final gradient = build(sweep: 0, mirrored: false);

    expect(beginX(gradient), closeTo(-2.2, 0.0001));
    expect(endX(gradient), closeTo(-0.2, 0.0001));
  });

  test('should place the band fully outside the trailing edge when the sweep is one', () {
    final gradient = build(sweep: 1, mirrored: false);

    expect(beginX(gradient), closeTo(0.2, 0.0001));
    expect(endX(gradient), closeTo(2.2, 0.0001));
  });

  test('should reverse the travel when the sweep is mirrored for RTL', () {
    final atStart = build(sweep: 0, mirrored: true);
    final atEnd = build(sweep: 1, mirrored: true);

    expect(beginX(atStart), closeTo(0.2, 0.0001));
    expect(beginX(atEnd), closeTo(-2.2, 0.0001));
  });

  test('should paint base-highlight-base with the band centered when the sweep is 0.5', () {
    final gradient = build(sweep: 0.5, mirrored: false);

    expect(gradient.colors, <Color>[base, highlight, base]);
    expect(gradient.stops!, <Matcher>[
      closeTo(0.3, 0.0001),
      closeTo(0.5, 0.0001),
      closeTo(0.7, 0.0001),
    ]);
  });

  test('should span exactly one box width when the sweep is 0.5', () {
    final gradient = build(sweep: 0.5, mirrored: false);

    expect(beginX(gradient), closeTo(-1.0, 0.0001));
    expect(endX(gradient), closeTo(1.0, 0.0001));
  });
}
