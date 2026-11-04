import 'package:flutter/material.dart';

import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';
import 'package:orbit/features/opportunities/presentation/constants/opportunity_layout_constants.dart';

/// Sticky tab bar for opportunity detail with count badges.
class OpportunityTabBar extends StatelessWidget {
  const OpportunityTabBar({
    super.key,
    required this.tabController,
    required this.contactsCount,
    required this.interactionsCount,
    required this.notesCount,
  });

  final TabController tabController;
  final int contactsCount;
  final int interactionsCount;
  final int notesCount;

  @override
  Widget build(BuildContext context) {
    final t = context.t.crm.crmOpportunities.detail;

    return Container(
      height: OpportunityLayoutConstants.tabBarHeight,
      color: context.colors.surface,
      child: TabBar(
        controller: tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicator: BoxDecoration(
          color: context.colors.primary,
          borderRadius: BorderRadius.circular(OpportunityLayoutConstants.tabIndicatorHeight / 2),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: context.textStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: context.textStyles.labelLarge,
        labelColor: context.colors.primary,
        unselectedLabelColor: context.colors.textSecondary,
        padding: EdgeInsets.zero,
        tabs: [
          Tab(text: t.tabs.overview),
          _BadgeTab(label: t.tabs.contacts, count: contactsCount),
          _BadgeTab(label: t.tabs.interactions, count: interactionsCount),
          _BadgeTab(label: t.tabs.notes, count: notesCount),
        ],
      ),
    );
  }
}

class _BadgeTab extends StatelessWidget {
  const _BadgeTab({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          count > 0
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(width: AppSpacing.xs),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: BorderRadius.circular(OpportunityLayoutConstants.tabBadgeSize / 2),
                      ),
                      child: Text(
                        '$count',
                        style: context.textStyles.labelSmall.copyWith(
                          color: colors.onPrimaryContainer,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}