import 'package:flutter/material.dart';
import 'package:orbit/core/animations/loading/shimmer_box.dart';
import 'package:orbit/core/animations/loading/shimmer_scope.dart';
import 'package:orbit/core/responsive/responsive.dart';
import 'package:orbit/core/theme/app_radius.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';

import '../constants/interaction_layout_constants.dart';

/// Skeleton twin of an interaction card: type badge, subject, two
/// description lines and a chip. The card surface stays outside the shimmer so
/// only the placeholder shapes animate.
class InteractionTileSkeleton extends StatelessWidget {
  const InteractionTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: InteractionLayoutConstants.tileBorderRadius,
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.all(AppSpacing.md),
        child: ShimmerScope(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(
                width: Responsive.adapt(44),
                height: Responsive.adapt(44),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FractionallySizedBox(
                      widthFactor: 0.7,
                      child: ShimmerBox(height: Responsive.adapt(16)),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    ShimmerBox(height: Responsive.adapt(12)),
                    SizedBox(height: AppSpacing.xs),
                    FractionallySizedBox(
                      widthFactor: 0.55,
                      child: ShimmerBox(height: Responsive.adapt(12)),
                    ),
                    SizedBox(height: AppSpacing.md),
                    Container(
                      width: Responsive.adapt(96),
                      height: Responsive.adapt(28),
                      decoration: BoxDecoration(
                        borderRadius: AppRadius.borderFull,
                      ),
                      child: ShimmerBox(
                        width: Responsive.adapt(96),
                        height: Responsive.adapt(28),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A few [InteractionTileSkeleton]s with the gap the real list uses.
class InteractionTileSkeletonList extends StatelessWidget {
  const InteractionTileSkeletonList({super.key, this.count = 3});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < count; i++) ...[
          const InteractionTileSkeleton(),
          if (i < count - 1)
            SizedBox(height: InteractionLayoutConstants.tileVerticalPadding),
        ],
      ],
    );
  }
}

/// Skeleton of a pinned date header (pill + rule).
class InteractionGroupHeaderSkeleton extends StatelessWidget {
  const InteractionGroupHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: InteractionLayoutConstants.groupHeaderHeight,
      child: Padding(
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: InteractionLayoutConstants.tileHorizontalPadding,
          vertical: AppSpacing.sm,
        ),
        child: ShimmerScope(
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: ShimmerBox(
              width: Responsive.adapt(120),
              height: Responsive.adapt(28),
            ),
          ),
        ),
      ),
    );
  }
}
