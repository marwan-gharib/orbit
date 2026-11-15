import 'package:flutter/material.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/features/opportunities/presentation/constants/opportunity_layout_constants.dart';
import 'package:orbit/features/opportunities/presentation/widgets/opportunity_tab_bar.dart';

/// Pins the detail tab bar under the app bar.
class OpportunityTabBarDelegate extends SliverPersistentHeaderDelegate {
  const OpportunityTabBarDelegate({required this.tabBar});

  final OpportunityTabBar tabBar;

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
      child: tabBar,
    );
  }

  @override
  double get maxExtent => OpportunityLayoutConstants.tabBarHeight;

  @override
  double get minExtent => OpportunityLayoutConstants.tabBarHeight;

  @override
  bool shouldRebuild(covariant OpportunityTabBarDelegate oldDelegate) =>
      oldDelegate.tabBar.contactsCount != tabBar.contactsCount ||
      oldDelegate.tabBar.interactionsCount != tabBar.interactionsCount ||
      oldDelegate.tabBar.notesCount != tabBar.notesCount;
}
