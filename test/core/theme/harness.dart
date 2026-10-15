import 'package:flutter/widgets.dart';

import 'package:orbit/core/responsive/responsive_scaler.dart';

/// Binds a scaler whose axes differ per direction, so tests can prove which
/// axis a value reads: [widthFactor]/[heightFactor] apply to width/height
/// while [adaptiveFactor] applies to `radius`/`font`/`adapt`.
class AxisTestScaler extends ResponsiveScaler {
  const AxisTestScaler({
    this.widthFactor = 1,
    this.heightFactor = 1,
    this.adaptiveFactor = 1,
  });

  final double widthFactor;
  final double heightFactor;
  final double adaptiveFactor;

  @override
  double width(double value) => value * widthFactor;

  @override
  double height(double value) => value * heightFactor;

  @override
  double radius(double value) => value * adaptiveFactor;

  @override
  double font(double value) => value * adaptiveFactor;

  @override
  double adapt(double value) => value * adaptiveFactor;

  @override
  bool get isInitialized => true;

  @override
  void configure(MediaQueryData metrics, {required Size designSize}) {}

  @override
  Future<void> ensureInitialized() async {}
}
