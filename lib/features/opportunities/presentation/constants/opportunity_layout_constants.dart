import 'package:flutter/material.dart';

import 'package:orbit/core/responsive/responsive.dart';
import 'package:orbit/core/theme/app_radius.dart';
import 'package:orbit/core/theme/app_spacing.dart';

/// Layout numbers shared by the opportunity card, its skeleton twin, the
/// detail page sections, and the progress stepper — so loading states occupy
/// exactly the same geometry (Q3).
abstract final class OpportunityLayoutConstants {
  // ---------------------------------------------------------------------------
  // Card (list item)
  // ---------------------------------------------------------------------------
  static double get cardPadding => AppSpacing.md;
  static BorderRadius get cardRadius => AppRadius.borderLg;
  static double get cardRowGap => AppSpacing.sm;
  static double get cardDividerGap => AppSpacing.sm;
  static double get cardRingSizeSmall => Responsive.adapt(28);
  static double get cardRingStrokeWidth => Responsive.adapt(3);

  // ---------------------------------------------------------------------------
  // Detail header (collapsing parallax)
  // ---------------------------------------------------------------------------
  static double get headerPadding => AppSpacing.lg;
  static double get headerTitleGap => AppSpacing.xs;
  static double get headerRowGap => AppSpacing.sm;

  // ---------------------------------------------------------------------------
  // Progress card
  // ---------------------------------------------------------------------------
  static double get progressCardPadding => AppSpacing.lg;
  static double get progressRingSizeLarge => Responsive.adapt(72);
  static double get progressRingStrokeWidth => Responsive.adapt(6);
  static double get stepperNodeSize => Responsive.adapt(20);
  static double get stepperNodeSizeCurrent => Responsive.adapt(28);
  static double get stepperConnectorHeight => Responsive.adapt(2);
  static double get stepperLabelMaxWidth => Responsive.width(0.16); // ~1/5 minus gaps

  // ---------------------------------------------------------------------------
  // Sticky tab bar
  // ---------------------------------------------------------------------------
  static double get tabBarHeight => Responsive.adapt(48);
  static double get tabIndicatorHeight => Responsive.adapt(3);
  static double get tabBadgeSize => Responsive.adapt(16);

  // ---------------------------------------------------------------------------
  // Overview cards
  // ---------------------------------------------------------------------------
  static double get overviewCardPadding => AppSpacing.md;
  static double get overviewRowGap => AppSpacing.xs;
  static double get overviewIconSize => Responsive.adapt(20);

  // ---------------------------------------------------------------------------
  // Contact card
  // ---------------------------------------------------------------------------
  static double get contactCardPadding => AppSpacing.md;
  static double get contactAvatarSize => Responsive.adapt(44);
  static double get contactButtonSize => kMinInteractiveDimension;

  // ---------------------------------------------------------------------------
  // Skeleton structure
  // ---------------------------------------------------------------------------
  static const int cardSkeletonRows = 1;
  static const int detailSkeletonSections = 5; // header, banner, progress, tabs, overview
}