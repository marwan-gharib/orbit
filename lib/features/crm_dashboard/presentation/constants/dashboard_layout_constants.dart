import 'package:orbit/core/responsive/responsive.dart';
import 'package:orbit/core/theme/app_spacing.dart';

/// Sizes of the CRM dashboard (RESP-2: every value goes through the theme
/// tokens or [Responsive]).
abstract final class DashboardLayoutConstants {
  static double get pageGap => AppSpacing.md;
  static double get cardPadding => AppSpacing.md;
  static double get listBottomPadding => Responsive.adapt(40);

  static double get heroRingSize => Responsive.adapt(96);
  static double get heroRingStroke => Responsive.adapt(10);
  static double get kpiIconBox => Responsive.adapt(36);
  static double get kpiIconSize => Responsive.adapt(20);
  static double get kpiMinHeight => Responsive.adapt(128);

  static double get donutSize => Responsive.adapt(150);
  static double get chartHeight => Responsive.adapt(220);
  static double get legendDot => Responsive.adapt(10);

  static double get funnelBarHeight => Responsive.adapt(14);
  static double get avatarSize => Responsive.adapt(40);
  static double get rankBadge => Responsive.adapt(22);
  static double get teamBarHeight => Responsive.adapt(8);

  /// Delay between two cards of the staggered entrance, as a fraction.
  static const int staggerCap = 8;
}
