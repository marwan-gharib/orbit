import 'package:flutter/material.dart';
import 'package:orbit/core/animations/loading/shimmer_box.dart';
import 'package:orbit/core/animations/loading/shimmer_scope.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/widgets/app_card.dart';
import 'package:orbit/features/opportunities/presentation/constants/opportunity_layout_constants.dart';

/// Skeleton twin of the full opportunity detail page — same geometry, shimmer placeholders (Q3).
class OpportunityDetailSkeleton extends StatelessWidget {
  const OpportunityDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ShimmerScope(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            // SliverAppBar skeleton (back button only, no title)
            SliverAppBar(
              pinned: true,
              elevation: 0,
              backgroundColor: colors.surface,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary),
                onPressed: () {},
              ),
              expandedHeight: 320,
            ),

            // Header skeleton
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(
                  OpportunityLayoutConstants.headerPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    ShimmerBox(width: 250, height: 32),
                    SizedBox(height: OpportunityLayoutConstants.headerTitleGap),
                    // Status + Stage
                    Row(
                      children: [
                        ShimmerBox(width: 80, height: 28),
                        SizedBox(width: AppSpacing.sm),
                        ShimmerBox(width: 100, height: 28),
                      ],
                    ),
                    SizedBox(height: OpportunityLayoutConstants.headerRowGap),
                    // Value
                    ShimmerBox(width: 180, height: 28),
                    SizedBox(height: OpportunityLayoutConstants.headerRowGap),
                    // Dates
                    Row(
                      children: [
                        Expanded(child: _DateSkeleton()),
                        SizedBox(width: AppSpacing.md),
                        Expanded(child: _DateSkeleton()),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Status banner skeleton
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: ShimmerBox(width: double.infinity, height: 80),
              ),
            ),

            // Progress card skeleton
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stage label + name
                    Row(
                      children: [
                        ShimmerBox(width: 80, height: 20),
                        SizedBox(width: AppSpacing.sm),
                        ShimmerBox(width: 120, height: 24),
                        const Spacer(),
                        // Probability ring
                        ShimmerBox.circle(
                          width:
                              OpportunityLayoutConstants.progressRingSizeLarge,
                          height:
                              OpportunityLayoutConstants.progressRingSizeLarge,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: OpportunityLayoutConstants.progressCardPadding,
                    ),
                    // Stepper nodes
                    Row(
                      children: List.generate(5, (index) {
                        if (index > 0) {
                          return Expanded(
                            child: Container(
                              height: OpportunityLayoutConstants
                                  .stepperConnectorHeight,
                              margin: EdgeInsets.symmetric(
                                vertical:
                                    OpportunityLayoutConstants
                                        .stepperNodeSizeCurrent /
                                    2,
                              ),
                              decoration: BoxDecoration(
                                color: context.colors.border,
                                borderRadius: BorderRadius.circular(
                                  OpportunityLayoutConstants
                                          .stepperConnectorHeight /
                                      2,
                                ),
                              ),
                            ),
                          );
                        }
                        return _NodeSkeleton(isCurrent: index == 1);
                      }),
                    ),
                  ],
                ),
              ),
            ),

            // Tab bar skeleton
            SliverPersistentHeader(
              pinned: true,
              delegate: _SkeletonTabBarDelegate(),
            ),

            // Overview skeleton
            SliverFillRemaining(
              hasScrollBody: false,
              child: ListView(
                padding: EdgeInsets.all(AppSpacing.md),
                children: [
                  _CardSkeleton(),
                  SizedBox(height: AppSpacing.lg),
                  _CardSkeleton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateSkeleton extends StatelessWidget {
  const _DateSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerBox(width: 60, height: 14),
        SizedBox(height: AppSpacing.xxs),
        Row(
          children: [
            ShimmerBox(width: 16, height: 16),
            SizedBox(width: AppSpacing.xs),
            ShimmerBox(width: 100, height: 16),
          ],
        ),
      ],
    );
  }
}

class _NodeSkeleton extends StatelessWidget {
  const _NodeSkeleton({this.isCurrent = false});

  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final size = isCurrent
        ? OpportunityLayoutConstants.stepperNodeSizeCurrent
        : OpportunityLayoutConstants.stepperNodeSize;

    return Expanded(
      child: Column(
        children: [
          ShimmerBox.circle(width: size, height: size),
          SizedBox(height: AppSpacing.xs),
          ShimmerBox(width: 30, height: 10),
        ],
      ),
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();

  @override
  Widget build(BuildContext context) {
    return ShimmerScope(
      child: AppCard(
        padding: EdgeInsets.all(OpportunityLayoutConstants.overviewCardPadding),
        onTap: null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ShimmerBox.circle(
                  width: OpportunityLayoutConstants.contactAvatarSize,
                  height: OpportunityLayoutConstants.contactAvatarSize,
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(width: 150, height: 20),
                      SizedBox(height: AppSpacing.xxs),
                      ShimmerBox(width: 120, height: 14),
                    ],
                  ),
                ),
                ShimmerBox(width: 80, height: 24),
              ],
            ),
            SizedBox(height: AppSpacing.lg),
            _ContactRowSkeleton(),
            SizedBox(height: AppSpacing.md),
            _ContactRowSkeleton(),
            SizedBox(height: AppSpacing.md),
            _ContactRowSkeleton(),
          ],
        ),
      ),
    );
  }
}

class _ContactRowSkeleton extends StatelessWidget {
  const _ContactRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ShimmerBox(width: 24, height: 24),
        SizedBox(width: AppSpacing.sm),
        Expanded(child: ShimmerBox(width: 150, height: 16)),
      ],
    );
  }
}

class _SkeletonTabBarDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final colors = context.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          bottom: BorderSide(
            color: colors.border,
            width: shrinkOffset > 0 ? 1 : 0,
          ),
        ),
      ),
      child: Container(
        height: 48,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          children: [
            ShimmerBox(width: 80, height: 20),
            SizedBox(width: AppSpacing.md),
            ShimmerBox(width: 80, height: 20),
            SizedBox(width: AppSpacing.md),
            ShimmerBox(width: 90, height: 20),
            SizedBox(width: AppSpacing.md),
            ShimmerBox(width: 60, height: 20),
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(covariant _SkeletonTabBarDelegate oldDelegate) => false;
}
