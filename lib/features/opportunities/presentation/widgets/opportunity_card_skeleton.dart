import 'package:flutter/material.dart';

import 'package:orbit/core/animations/loading/shimmer_box.dart';
import 'package:orbit/core/animations/loading/shimmer_scope.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/responsive/responsive.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/widgets/app_card.dart';
import 'package:orbit/features/opportunities/presentation/constants/opportunity_layout_constants.dart';

/// Skeleton twin of [OpportunityCard] — same geometry, shimmer placeholders (Q3).
/// The card surface stays outside the [ShimmerScope]; only the placeholder
/// shapes shimmer, so the card's structure stays readable while loading.
class OpportunityCardSkeleton extends StatelessWidget {
  const OpportunityCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      padding: EdgeInsetsDirectional.all(OpportunityLayoutConstants.cardPadding),
      onTap: null,
      child: ShimmerScope(
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row A: Title placeholder + Status badge pill placeholder
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ShimmerBox(
                  width: Responsive.adapt(150),
                  height: Responsive.adapt(20),
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              ShimmerBox(
                width: Responsive.adapt(72),
                height: Responsive.adapt(24),
              ),
            ],
          ),
          SizedBox(height: OpportunityLayoutConstants.cardRowGap),

          // Row B: Customer name + company placeholder
          Row(
            children: [
              ShimmerBox.circle(
                width: OpportunityLayoutConstants.overviewIconSize,
                height: OpportunityLayoutConstants.overviewIconSize,
              ),
              SizedBox(width: AppSpacing.xs),
              Expanded(
                child: ShimmerBox(
                  width: Responsive.adapt(200),
                  height: Responsive.adapt(14),
                ),
              ),
            ],
          ),
          SizedBox(height: OpportunityLayoutConstants.cardDividerGap),
          Divider(height: 1, color: colors.border),
          SizedBox(height: OpportunityLayoutConstants.cardDividerGap),

          // Row C: Value placeholder + Probability ring placeholder + percent bar
          Row(
            children: [
              Expanded(
                child: ShimmerBox(
                  width: Responsive.adapt(120),
                  height: Responsive.adapt(20),
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              ShimmerBox.circle(
                width: OpportunityLayoutConstants.cardRingSizeSmall,
                height: OpportunityLayoutConstants.cardRingSizeSmall,
              ),
              SizedBox(width: AppSpacing.xs),
              ShimmerBox(
                width: Responsive.adapt(32),
                height: Responsive.adapt(14),
              ),
            ],
          ),
          SizedBox(height: OpportunityLayoutConstants.cardRowGap),

          // Row D: Stage chip placeholder + Date placeholder
          Row(
            children: [
              ShimmerBox(
                width: Responsive.adapt(100),
                height: Responsive.adapt(24),
              ),
              const Spacer(),
              ShimmerBox(
                width: Responsive.adapt(100),
                height: Responsive.adapt(14),
              ),
            ],
          ),
        ],
        ),
      ),
    );
  }
}

/// List skeleton: [OpportunityLayoutConstants.cardSkeletonCount] card
/// skeletons with the same gaps as the real list.
class OpportunitiesListSkeleton extends StatelessWidget {
  const OpportunitiesListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.t.crm.crmOpportunities.loadingOpportunities,
      excludeSemantics: true,
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: AppSpacing.md,
          end: AppSpacing.md,
          top: AppSpacing.sm,
          bottom: AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < OpportunityLayoutConstants.cardSkeletonCount; i++)
              Padding(
                padding: EdgeInsetsDirectional.only(
                  bottom: OpportunityLayoutConstants.cardListItemGap,
                ),
                child: const OpportunityCardSkeleton(),
              ),
          ],
        ),
      ),
    );
  }
}
