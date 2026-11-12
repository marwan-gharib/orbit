import 'package:flutter/material.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_radius.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';

import '../constants/interaction_layout_constants.dart';

/// Pinned date header of one feed group ("Today", "Yesterday", a date).
///
/// Group labels coming from `groupInteractionsByDate` may be slang keys for
/// today / yesterday; they are resolved here.
class InteractionsGroupHeaderDelegate extends SliverPersistentHeaderDelegate {
  const InteractionsGroupHeaderDelegate({
    required this.label,
    required this.count,
  });

  final String label;

  /// Number of interactions in the group.
  final int count;

  @override
  double get minExtent => InteractionLayoutConstants.groupHeaderHeight;

  @override
  double get maxExtent => InteractionLayoutConstants.groupHeaderHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final colors = context.colors;
    final common = context.t.crm.common;
    final text = switch (label) {
      'crm.common.today' => common.today,
      'crm.common.yesterday' => common.yesterday,
      _ => label,
    };

    return DecoratedBox(
      decoration: BoxDecoration(color: colors.background),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            top: AppSpacing.sm,
            bottom: AppSpacing.sm,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: overlapsContent
                  ? colors.primaryContainer
                  : colors.surfaceVariant,
              borderRadius: AppRadius.borderFull,
              border: Border.all(color: colors.border),
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: InteractionLayoutConstants.groupHeaderIconSize,
                    color: colors.primary,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    text,
                    style: context.textStyles.labelLarge.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(child: Divider(height: 1, color: colors.border)),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    '$count',
                    style: context.textStyles.labelMedium.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant InteractionsGroupHeaderDelegate oldDelegate) =>
      oldDelegate.label != label || oldDelegate.count != count;
}
