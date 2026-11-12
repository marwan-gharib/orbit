import 'package:flutter/material.dart';
import 'package:orbit/core/animations/loading/shimmer_box.dart';
import 'package:orbit/core/animations/loading/shimmer_scope.dart';
import 'package:orbit/core/responsive/responsive.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/widgets/app_card.dart';
import 'package:orbit/features/opportunities/presentation/constants/opportunity_layout_constants.dart';

/// Pill-shaped placeholders for the four detail tabs.
class TabBarSkeleton extends StatelessWidget {
  const TabBarSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerScope(
      child: Padding(
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: [
            // Flexible pills: they share the width, so no screen size overflows.
            for (final (i, flex) in const [88, 80, 96, 64].indexed) ...[
              Expanded(
                flex: flex,
                child: ShimmerBox(
                  height: OpportunityLayoutConstants.tabBarHeight * 0.7,
                ),
              ),
              if (i < 3) SizedBox(width: AppSpacing.sm),
            ],
          ],
        ),
      ),
    );
  }
}

/// Skeleton of the customer card in the Overview tab.
class CustomerCardSkeleton extends StatelessWidget {
  const CustomerCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsetsDirectional.all(
        OpportunityLayoutConstants.overviewCardPadding,
      ),
      onTap: null,
      child: ShimmerScope(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ShimmerBox.circle(width: Responsive.adapt(48)),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(width: Responsive.adapt(140), height: Responsive.adapt(18)),
                      SizedBox(height: AppSpacing.xs),
                      ShimmerBox(width: Responsive.adapt(80), height: Responsive.adapt(12)),
                    ],
                  ),
                ),
                ShimmerBox(width: Responsive.adapt(88), height: Responsive.adapt(24)),
              ],
            ),
            SizedBox(height: AppSpacing.lg),
            for (var i = 0; i < 3; i++) ...[
              const ContactRowSkeleton(),
              if (i < 2) SizedBox(height: OpportunityLayoutConstants.overviewRowGap),
            ],
          ],
        ),
      ),
    );
  }
}

/// One icon + text-line placeholder row.
class ContactRowSkeleton extends StatelessWidget {
  const ContactRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ShimmerBox.circle(width: OpportunityLayoutConstants.overviewIconSize),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: ShimmerBox(width: Responsive.adapt(170), height: Responsive.adapt(14)),
          ),
        ),
      ],
    );
  }
}

/// Skeleton of the facts card in the Overview tab.
class DetailsCardSkeleton extends StatelessWidget {
  const DetailsCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsetsDirectional.all(
        OpportunityLayoutConstants.overviewCardPadding,
      ),
      onTap: null,
      child: ShimmerScope(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerBox(width: Responsive.adapt(72), height: Responsive.adapt(14)),
            SizedBox(height: AppSpacing.md),
            for (var i = 0; i < 4; i++) ...[
              const DetailRowSkeleton(),
              if (i < 3) SizedBox(height: OpportunityLayoutConstants.overviewRowGap),
            ],
          ],
        ),
      ),
    );
  }
}

/// One label + value placeholder row.
class DetailRowSkeleton extends StatelessWidget {
  const DetailRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ShimmerBox(width: Responsive.adapt(80), height: Responsive.adapt(12)),
        const Spacer(),
        ShimmerBox(width: Responsive.adapt(110), height: Responsive.adapt(14)),
      ],
    );
  }
}
