import 'package:flutter/material.dart';
import 'package:orbit/core/animations/feedback/pulse_widget.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/utils/formatters.dart';

import '../../domain/entities/dashboard_overview_entity.dart';
import '../pure/dashboard_insights.dart';
import 'dashboard_kpi_card.dart';

/// 2 × 2 grid: won revenue, weighted forecast, average open deal and the
/// number of deals past their expected close date (pulses when not zero).
class DashboardKpiGrid extends StatelessWidget {
  const DashboardKpiGrid({super.key, required this.overview});

  final DashboardOverview overview;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final t = context.t.crm.dashboard.kpi;
    final currency = overview.currency;
    String money(num n) => Formatters.money(n.round(), currency);
    final pastDue = overview.pastExpectedCloseCount;

    final cards = [
      DashboardKpiCard(
        icon: Icons.emoji_events_rounded,
        accent: colors.success,
        label: t.won,
        value: overview.won.value,
        formatter: money,
        caption: t.wonDeals(count: overview.won.count),
      ),
      DashboardKpiCard(
        icon: Icons.insights_rounded,
        accent: colors.primary,
        label: t.weighted,
        value: overview.weightedForecast,
        formatter: money,
        caption: t.weightedHint,
      ),
      DashboardKpiCard(
        icon: Icons.paid_rounded,
        accent: colors.secondary,
        label: t.avgDeal,
        value: averageOpenDeal(overview),
        formatter: money,
        caption: t.avgDealHint,
      ),
      PulseWidget(
        active: pastDue > 0,
        child: DashboardKpiCard(
          icon: pastDue > 0
              ? Icons.alarm_on_rounded
              : Icons.event_available_rounded,
          accent: pastDue > 0 ? colors.error : colors.success,
          label: t.pastDue,
          value: pastDue,
          formatter: (n) => '${n.round()}',
          caption: pastDue > 0 ? t.pastDueHint : t.pastDueClear,
        ),
      ),
    ];

    return Column(
      children: [
        for (var row = 0; row < cards.length; row += 2) ...[
          if (row > 0) SizedBox(height: AppSpacing.md),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: cards[row]),
                SizedBox(width: AppSpacing.md),
                Expanded(child: cards[row + 1]),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
