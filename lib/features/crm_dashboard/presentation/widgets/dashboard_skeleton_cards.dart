import 'package:flutter/material.dart';
import 'package:orbit/core/animations/loading/shimmer_box.dart';
import 'package:orbit/core/animations/loading/shimmer_scope.dart';
import 'package:orbit/core/responsive/responsive.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/widgets/app_card.dart';

import '../constants/dashboard_layout_constants.dart';

/// Title + subtitle placeholder of a card header.
class DashboardSkeletonHeaderLines extends StatelessWidget {
  const DashboardSkeletonHeaderLines({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerBox(width: Responsive.adapt(140), height: Responsive.adapt(18)),
        SizedBox(height: AppSpacing.xs),
        ShimmerBox(width: Responsive.adapt(200), height: Responsive.adapt(12)),
      ],
    );
  }
}

class DashboardDonutCardSkeleton extends StatelessWidget {
  const DashboardDonutCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsetsDirectional.all(DashboardLayoutConstants.cardPadding),
      child: ShimmerScope(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const DashboardSkeletonHeaderLines(),
            SizedBox(height: AppSpacing.md),
            Row(
              children: [
                ShimmerBox.circle(width: DashboardLayoutConstants.donutSize),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    children: [
                      for (var i = 0; i < 3; i++) ...[
                        ShimmerBox(height: Responsive.adapt(14)),
                        SizedBox(height: AppSpacing.md),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardBarsCardSkeleton extends StatelessWidget {
  const DashboardBarsCardSkeleton({super.key});

  /// Relative heights of the placeholder bars.
  static const List<double> _bars = [0.45, 0.7, 0.35, 0.9, 0.6, 0.5];

  @override
  Widget build(BuildContext context) {
    final chartHeight = DashboardLayoutConstants.chartHeight;

    return AppCard(
      padding: EdgeInsetsDirectional.all(DashboardLayoutConstants.cardPadding),
      child: ShimmerScope(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const DashboardSkeletonHeaderLines(),
            SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(child: ShimmerBox(height: Responsive.adapt(36))),
                SizedBox(width: AppSpacing.sm),
                Expanded(child: ShimmerBox(height: Responsive.adapt(36))),
                SizedBox(width: AppSpacing.sm),
                Expanded(child: ShimmerBox(height: Responsive.adapt(36))),
              ],
            ),
            SizedBox(height: AppSpacing.lg),
            SizedBox(
              height: chartHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final (i, factor) in _bars.indexed) ...[
                    if (i > 0) SizedBox(width: AppSpacing.md),
                    Expanded(child: ShimmerBox(height: chartHeight * factor)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardTeamCardSkeleton extends StatelessWidget {
  const DashboardTeamCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsetsDirectional.all(DashboardLayoutConstants.cardPadding),
      child: ShimmerScope(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const DashboardSkeletonHeaderLines(),
            SizedBox(height: AppSpacing.md),
            for (var i = 0; i < 3; i++)
              Padding(
                padding: EdgeInsetsDirectional.only(bottom: AppSpacing.md),
                child: Row(
                  children: [
                    ShimmerBox.circle(
                      width: DashboardLayoutConstants.avatarSize,
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerBox(
                            width: Responsive.adapt(120),
                            height: Responsive.adapt(14),
                          ),
                          SizedBox(height: AppSpacing.xs),
                          ShimmerBox(height: Responsive.adapt(8)),
                        ],
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    ShimmerBox(
                      width: Responsive.adapt(48),
                      height: Responsive.adapt(18),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
