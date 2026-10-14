import 'package:flutter/material.dart';

import 'package:orbit/core/responsive/responsive.dart';

abstract final class AppRadius {
  static double get xs => Responsive.radius(4);
  static double get sm => Responsive.radius(8);
  static double get md => Responsive.radius(12);
  static double get lg => Responsive.radius(16);
  static double get xl => Responsive.radius(24);
  static double get xxl => Responsive.radius(32);

  /// Fully rounded pill. Oversized on purpose: callers of any height get a
  /// stadium because Flutter clamps the painted radius to the shorter side.
  static double get full => Responsive.radius(999);

  static BorderRadius get borderXs => BorderRadius.circular(xs);
  static BorderRadius get borderSm => BorderRadius.circular(sm);
  static BorderRadius get borderMd => BorderRadius.circular(md);
  static BorderRadius get borderLg => BorderRadius.circular(lg);
  static BorderRadius get borderXl => BorderRadius.circular(xl);
  static BorderRadius get borderXxl => BorderRadius.circular(xxl);
  static BorderRadius get borderFull => BorderRadius.circular(full);
}
