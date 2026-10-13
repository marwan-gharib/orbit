import 'package:flutter/widgets.dart';

/// Scaling policy shared by every [ResponsiveScaler] implementation.
///
/// Never scale, regardless of backend: durations, opacity, flex factors,
/// hairline border widths, elevation, line counts, aspect ratios,
/// percentages, and anything already derived from constraints or MediaQuery.
abstract class ResponsiveScaler {
  const ResponsiveScaler();

  /// Why clamped: a 768dp tablet would otherwise scale by 2.05x and a 1440dp
  /// desktop window by 3.84x; clamping keeps one sane level of zoom on every
  /// form factor while phones still get their ~15% of size adjustment.
  static const double minScaleFactor = 0.85;
  static const double maxScaleFactor = 1.30;

  /// Cap, never a floor: very large accessibility text settings cannot break
  /// fixed layouts, and scaling can still go down to the system minimum.
  static const double maxTextScale = 1.3;

  double width(double value);

  double height(double value);

  /// Corner radius — the smaller axis, so radii never distort.
  double radius(double value);

  /// Font size — the smaller axis; the system text scale applies on top.
  double font(double value);

  /// Squares and icons — min(width, height), so they stay square-ish.
  double adapt(double value);

  /// True once [configure] has supplied usable metrics; while false every
  /// scale method must return its input unchanged (identity fallback).
  bool get isInitialized;

  void configure(MediaQueryData metrics, {required Size designSize});

  Future<void> ensureInitialized();
}

/// Identity fallback used before the real engine is bound and in tests that
/// never pump the scope — inputs pass through unchanged, never throws.
final class IdentityResponsiveScaler extends ResponsiveScaler {
  const IdentityResponsiveScaler();

  @override
  double width(double value) => value;

  @override
  double height(double value) => value;

  @override
  double radius(double value) => value;

  @override
  double font(double value) => value;

  @override
  double adapt(double value) => value;

  @override
  bool get isInitialized => false;

  @override
  void configure(MediaQueryData metrics, {required Size designSize}) {}

  @override
  Future<void> ensureInitialized() => Future<void>.value();
}
