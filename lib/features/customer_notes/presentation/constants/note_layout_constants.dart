import 'package:flutter/material.dart';

import 'package:orbit/core/responsive/responsive.dart';
import 'package:orbit/core/theme/app_radius.dart';
import 'package:orbit/core/theme/app_spacing.dart';

/// Layout numbers shared by the note row, its skeleton twin and the composer,
/// so the loading state occupies exactly the row's geometry (Q2).
abstract final class NoteLayoutConstants {
  /// Avatar diameter; the skeleton circle uses the same value.
  static double get avatarSize => Responsive.adapt(40);

  /// Gap between the avatar and the note column.
  static double get avatarGap => AppSpacing.sm;

  /// Gap between two notes in the thread.
  static double get noteGap => AppSpacing.md;

  /// Vertical gap inside a note column.
  static double get contentGap => AppSpacing.xs;

  /// Lines shown before the "Show more" action appears.
  static const int collapsedLines = 6;

  /// Composer field bounds: one line at rest, five at most.
  static const int composerMinLines = 1;
  static const int composerMaxLines = 5;

  /// Rows rendered by the loading twin.
  static const int skeletonRows = 3;

  /// Vertical gap between skeleton rows.
  static double get skeletonRowGap => AppSpacing.lg;

  /// Departing rows kept mounted for their collapse; older ones are dropped
  /// so a long session cannot grow the thread's shadow list forever.
  static const int maxDepartingRows = 10;

  /// Author placeholder width, as a fraction of the skeleton row width.
  static const double skeletonAuthorWidth = 0.45;

  /// Timestamp placeholder width, as a fraction of the skeleton row width.
  static const double skeletonTimestampWidth = 0.18;

  /// Corner radius of the arrival highlight wash.
  static BorderRadius get highlightRadius => AppRadius.borderMd;

  /// Minimum tap target for text actions inside a note (UI-7).
  static const double minTapTarget = kMinInteractiveDimension;

  /// Square side of the composer's send button.
  static const double sendButtonSize = kMinInteractiveDimension;
}
