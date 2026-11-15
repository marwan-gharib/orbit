import 'package:flutter/material.dart';
import 'package:orbit/core/animations/state/animated_counter.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_radius.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';
import 'package:orbit/features/opportunities/presentation/constants/opportunity_layout_constants.dart';

/// Sticky tab bar of the opportunity detail page.
///
/// A sliding pill indicator sits behind the selected label; the label always
/// uses the pill's "on" colour so it stays readable. Count badges count up
/// whenever their value changes.
class OpportunityTabBar extends StatelessWidget {
  const OpportunityTabBar({
    super.key,
    required this.tabController,
    required this.contactsCount,
    required this.interactionsCount,
    required this.notesCount,
    this.onTap,
  });

  final TabController tabController;
  final int contactsCount;
  final int interactionsCount;
  final int notesCount;

  /// Called for every tap, including a tap on the already selected tab.
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.t.crm.crmOpportunities.detail;
    final colors = context.colors;

    return ColoredBox(
      color: colors.surface,
      child: TabBar(
        controller: tabController,
        onTap: onTap,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: EdgeInsetsDirectional.symmetric(
          vertical: AppSpacing.xs,
        ),
        labelPadding: EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.md,
        ),
        padding: EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.sm),
        splashBorderRadius: AppRadius.borderFull,
        indicator: BoxDecoration(
          color: colors.primaryContainer,
          borderRadius: AppRadius.borderFull,
        ),
        labelStyle: context.textStyles.labelLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: context.textStyles.labelLarge,
        labelColor: colors.onPrimaryContainer,
        unselectedLabelColor: colors.textSecondary,
        tabs: [
          Tab(
            height: OpportunityLayoutConstants.tabBarHeight,
            text: t.tabs.overview,
          ),
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
      height: OpportunityLayoutConstants.tabBarHeight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label),
          if (count > 0) ...[
            SizedBox(width: AppSpacing.xs),
            Container(
              height: OpportunityLayoutConstants.tabBadgeSize,
              constraints: BoxConstraints(
                minWidth: OpportunityLayoutConstants.tabBadgeSize,
              ),
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.xs,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: AppRadius.borderFull,
              ),
              child: AnimatedCounter(
                value: count,
                style: context.textStyles.labelSmall.copyWith(
                  color: colors.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
