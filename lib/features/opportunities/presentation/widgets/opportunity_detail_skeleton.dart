import 'package:flutter/material.dart';
import 'package:orbit/core/animations/loading/shimmer_box.dart';
import 'package:orbit/core/animations/loading/shimmer_scope.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/responsive/responsive.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/widgets/app_card.dart';
import 'package:orbit/features/opportunities/presentation/constants/opportunity_layout_constants.dart';
import 'package:orbit/features/opportunities/presentation/widgets/opportunity_detail_skeleton_overview.dart';

/// Skeleton twin of the opportunity detail page: header, progress card, tab
/// bar and the Overview cards.
///
/// Each section owns a small [ShimmerScope] around its placeholder shapes
/// only; cards and the page background stay outside, so the sweep never
/// washes over whole surfaces.
class OpportunityDetailSkeleton extends StatelessWidget {
  const OpportunityDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      label: context.t.crm.crmOpportunities.loadingOpportunityDetail,
      excludeSemantics: true,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: colors.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary),
            onPressed: () => Navigator.maybePop(context),
          ),
        ),
        body: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsetsDirectional.only(bottom: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _HeaderSkeleton(),
              Padding(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: const _ProgressCardSkeleton(),
              ),
              const TabBarSkeleton(),
              Padding(
                padding: EdgeInsetsDirectional.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const CustomerCardSkeleton(),
                    SizedBox(height: AppSpacing.lg),
                    const DetailsCardSkeleton(),
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

class _HeaderSkeleton extends StatelessWidget {
  const _HeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return ShimmerScope(
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: OpportunityLayoutConstants.headerPadding,
          end: OpportunityLayoutConstants.headerPadding,
          top: AppSpacing.xs,
          bottom: OpportunityLayoutConstants.headerPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FractionallySizedBox(
              widthFactor: 0.85,
              child: ShimmerBox(height: Responsive.adapt(28)),
            ),
            SizedBox(height: AppSpacing.xs),
            FractionallySizedBox(
              widthFactor: 0.55,
              child: ShimmerBox(height: Responsive.adapt(28)),
            ),
            SizedBox(height: OpportunityLayoutConstants.headerRowGap),
            Row(
              children: [
                ShimmerBox(width: Responsive.adapt(72), height: Responsive.adapt(24)),
                SizedBox(width: AppSpacing.sm),
                ShimmerBox(width: Responsive.adapt(88), height: Responsive.adapt(24)),
              ],
            ),
            SizedBox(height: OpportunityLayoutConstants.headerRowGap),
            ShimmerBox(width: Responsive.adapt(160), height: Responsive.adapt(30)),
            SizedBox(height: OpportunityLayoutConstants.headerRowGap),
            ShimmerBox(width: Responsive.adapt(200), height: Responsive.adapt(16)),
          ],
        ),
      ),
    );
  }
}

class _ProgressCardSkeleton extends StatelessWidget {
  const _ProgressCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final nodeSize = OpportunityLayoutConstants.stepperNodeSize;

    return AppCard(
      padding: EdgeInsetsDirectional.all(
        OpportunityLayoutConstants.progressCardPadding,
      ),
      onTap: null,
      child: ShimmerScope(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(width: Responsive.adapt(48), height: Responsive.adapt(12)),
                      SizedBox(height: AppSpacing.xs),
                      ShimmerBox(width: Responsive.adapt(110), height: Responsive.adapt(22)),
                    ],
                  ),
                ),
                ShimmerBox.circle(
                  width: OpportunityLayoutConstants.progressRingSizeLarge,
                ),
              ],
            ),
            SizedBox(height: OpportunityLayoutConstants.progressCardPadding),
            Row(
              children: [
                for (var i = 0; i < 5; i++)
                  Expanded(child: Center(child: ShimmerBox.circle(width: nodeSize))),
              ],
            ),
            SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                for (var i = 0; i < 5; i++)
                  Expanded(
                    child: Center(
                      child: ShimmerBox(
                        width: Responsive.adapt(36),
                        height: Responsive.adapt(10),
                      ),
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
