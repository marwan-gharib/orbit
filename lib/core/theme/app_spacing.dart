import 'package:flutter/material.dart';

import 'package:orbit/core/responsive/responsive.dart';

/// Spacing scale and common paddings. Values run through `Responsive.adapt`
/// (the smaller-axis scale) so spacing never over-inflates in landscape, where
/// the width scale clamps to 1.30 while the height scale drops to 0.85.
///
/// Getters, not constants: the scale depends on the current screen metrics.
/// Paddings are directional so mirrored layouts stay correct (UI-5).
abstract final class AppSpacing {
  static double get xxs => Responsive.adapt(2);
  static double get xs => Responsive.adapt(4);
  static double get sm => Responsive.adapt(8);
  static double get md => Responsive.adapt(16);
  static double get lg => Responsive.adapt(24);
  static double get xl => Responsive.adapt(32);
  static double get xxl => Responsive.adapt(48);
  static double get xxxl => Responsive.adapt(64);

  /// Page inset around a screen's content.
  static EdgeInsetsGeometry get page => EdgeInsetsDirectional.all(md);

  /// Horizontal-only page inset, for screens with their own vertical rhythm.
  static EdgeInsetsGeometry get pageHorizontal =>
      EdgeInsetsDirectional.symmetric(horizontal: md);

  /// Card / grouped-content inset.
  static EdgeInsetsGeometry get card => EdgeInsetsDirectional.all(md);

  /// Default horizontal/vertical padding of a button label.
  static EdgeInsetsGeometry get button =>
      EdgeInsetsDirectional.only(start: lg, end: lg, top: sm, bottom: sm);
}
