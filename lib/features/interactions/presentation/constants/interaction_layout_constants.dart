import 'package:flutter/material.dart';

import 'package:orbit/core/responsive/responsive.dart';
import 'package:orbit/core/theme/app_radius.dart';
import 'package:orbit/core/theme/app_spacing.dart';

/// Layout numbers shared by the interaction tile, its skeleton twin and the
/// timeline, so the loading state occupies exactly the row's geometry (Q3).
abstract final class InteractionLayoutConstants {
  /// Diameter of the type icon circle.
  static double get typeIconSize => Responsive.adapt(36);

  /// Gap between the type icon and the text column.
  static double get typeIconGap => AppSpacing.sm;

  /// Vertical gap between subject and description.
  static double get contentGap => AppSpacing.xs;

  /// Tile vertical padding (top/bottom).
  static double get tileVerticalPadding => AppSpacing.md;

  /// Tile horizontal padding (left/right).
  static double get tileHorizontalPadding => AppSpacing.md;

  /// Height of the "Open opportunity" chip.
  static double get chipHeight => Responsive.adapt(28);

  /// Horizontal padding inside the "Open opportunity" chip.
  static double get chipHorizontalPadding => AppSpacing.sm;

  /// Swipe action background width (edit/delete).
  static double get swipeActionWidth => Responsive.adapt(80);

  /// Icon size inside swipe action backgrounds.
  static double get swipeIconSize => Responsive.adapt(24);

  /// Group header vertical padding.
  static double get groupHeaderPadding => AppSpacing.md;

  /// Gap above a group header.
  static double get groupHeaderTopGap => AppSpacing.lg;

  /// Number of skeleton rows rendered.
  static const int skeletonRows = 3;

  /// Vertical gap between skeleton rows.
  static double get skeletonRowGap => AppSpacing.lg;

  /// Type icon placeholder width as fraction of row width.
  static const double skeletonTypeIconWidth = 0.12;

  /// Subject placeholder width as fraction of row width.
  static const double skeletonSubjectWidth = 0.55;

  /// Description placeholder width as fraction of row width.
  static const double skeletonDescriptionWidth = 0.75;

  /// Date placeholder width as fraction of row width.
  static const double skeletonDateWidth = 0.25;

  /// Timeline connector line width.
  static double get timelineConnectorWidth => Responsive.adapt(2);

  /// Timeline node diameter.
  static double get timelineNodeSize => Responsive.adapt(12);

  /// Vertical gap between timeline items.
  static double get timelineGap => AppSpacing.md;

  /// Gap between fields in the add/edit sheet.
  static double get sheetFieldGap => AppSpacing.md;

  /// Minimum lines for description field in sheet.
  static const int sheetMinLines = 1;

  /// Maximum lines for description field in sheet.
  static const int sheetMaxLines = 4;

  /// Minimum tap target for interactive elements (UI-7).
  static const double minTapTarget = kMinInteractiveDimension;

  /// Maximum departing rows kept mounted for collapse animation.
  static const int maxDepartingRows = 10;

  /// Corner radius for tile highlight and ripple.
  static BorderRadius get tileBorderRadius => AppRadius.borderMd;
}
