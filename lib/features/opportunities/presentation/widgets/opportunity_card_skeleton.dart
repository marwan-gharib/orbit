import 'package:flutter/material.dart';

import 'package:orbit/core/animations/loading/shimmer_box.dart';
import 'package:orbit/core/animations/loading/shimmer_scope.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/widgets/app_card.dart';
import 'package:orbit/features/opportunities/presentation/constants/opportunity_layout_constants.dart';

/// Skeleton twin of [OpportunityCard] — same geometry, shimmer placeholders (Q3).
class OpportunityCardSkeleton extends StatelessWidget {
  const OpportunityCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ShimmerScope(
      child: AppCard(
        padding: EdgeInsets.all(OpportunityLayoutConstants.cardPadding),
        onTap: null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row A: Title placeholder + Status badge placeholder
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ShimmerBox(width: 150, height: 20),
                ),
                SizedBox(width: AppSpacing.sm),
                ShimmerBox.circle(width: 24, height: 24),
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
                  child: ShimmerBox(width: 200, height: 14),
                ),
              ],
            ),
            SizedBox(height: OpportunityLayoutConstants.cardDividerGap),
            Divider(height: 1, color: colors.border),
            SizedBox(height: OpportunityLayoutConstants.cardDividerGap),

            // Row C: Value placeholder + Probability ring placeholder
            Row(
              children: [
                Expanded(
                  child: ShimmerBox(width: 120, height: 20),
                ),
                SizedBox(width: AppSpacing.sm),
                ShimmerBox.circle(
                  width: OpportunityLayoutConstants.cardRingSizeSmall,
                  height: OpportunityLayoutConstants.cardRingSizeSmall,
                ),
              ],
            ),
            SizedBox(height: OpportunityLayoutConstants.cardRowGap),

            // Row D: Stage chip placeholder + Date placeholder
            Row(
              children: [
                ShimmerBox(width: 100, height: 24),
                const Spacer(),
                ShimmerBox(width: 100, height: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }
}