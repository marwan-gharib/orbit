import 'package:flutter/material.dart';
import 'package:orbit/core/animations/loading/shimmer_box.dart';
import 'package:orbit/core/animations/loading/shimmer_scope.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/responsive/responsive.dart';
import 'package:orbit/core/theme/app_radius.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/widgets/app_card.dart';

import '../constants/dashboard_layout_constants.dart';
import 'dashboard_skeleton_cards.dart';

/// Skeleton twin of the dashboard: hero card, 2 × 2 KPI grid, win-ratio
/// donut, pipeline, expected closings bars and the team leaderboard.
///
/// Card surfaces stay outside the shimmer; only the placeholder shapes
/// shimmer, so the layout stays readable while loading.
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final gap = SizedBox(height: DashboardLayoutConstants.pageGap);

    return Semantics(
      label: context.t.crm.dashboard.subtitle,
      excludeSemantics: true,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsetsDirectional.only(
          start: DashboardLayoutConstants.pageGap,
          end: DashboardLayoutConstants.pageGap,
          top: AppSpacing.sm,
          bottom: DashboardLayoutConstants.listBottomPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _HeroSkeleton(),
            gap,
            const _KpiGridSkeleton(),
            gap,
            const DashboardDonutCardSkeleton(),
            gap,
            const DashboardBarsCardSkeleton(),
            gap,
            const DashboardTeamCardSkeleton(),
          ],
        ),
      ),
    );
  }
}

class _HeroSkeleton extends StatelessWidget {
  const _HeroSkeleton();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.primaryContainer,
        borderRadius: AppRadius.borderXl,
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.all(
          DashboardLayoutConstants.cardPadding,
        ),
        child: ShimmerScope(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(
                      width: Responsive.adapt(96),
                      height: Responsive.adapt(14),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    ShimmerBox(
                      width: Responsive.adapt(170),
                      height: Responsive.adapt(28),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    ShimmerBox(
                      width: Responsive.adapt(120),
                      height: Responsive.adapt(12),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShimmerBox.circle(
                    width: DashboardLayoutConstants.heroRingSize,
                  ),
                  SizedBox(height: AppSpacing.xs),
                  ShimmerBox(
                    width: Responsive.adapt(72),
                    height: Responsive.adapt(10),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KpiGridSkeleton extends StatelessWidget {
  const _KpiGridSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget row() => Row(
      children: [
        const Expanded(child: _KpiSkeleton()),
        SizedBox(width: DashboardLayoutConstants.pageGap),
        const Expanded(child: _KpiSkeleton()),
      ],
    );

    return Column(
      children: [
        row(),
        SizedBox(height: DashboardLayoutConstants.pageGap),
        row(),
      ],
    );
  }
}

class _KpiSkeleton extends StatelessWidget {
  const _KpiSkeleton();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: DashboardLayoutConstants.kpiMinHeight,
      ),
      child: AppCard(
        padding: EdgeInsetsDirectional.all(AppSpacing.md),
        child: ShimmerScope(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  ShimmerBox(
                    width: DashboardLayoutConstants.kpiIconBox,
                    height: DashboardLayoutConstants.kpiIconBox,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(child: ShimmerBox(height: Responsive.adapt(12))),
                ],
              ),
              SizedBox(height: AppSpacing.md),
              ShimmerBox(
                width: Responsive.adapt(90),
                height: Responsive.adapt(22),
              ),
              SizedBox(height: AppSpacing.xs),
              ShimmerBox(
                width: Responsive.adapt(110),
                height: Responsive.adapt(12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
