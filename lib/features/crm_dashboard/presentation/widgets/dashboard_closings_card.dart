import 'package:flutter/material.dart';
import 'package:orbit/core/animations/selection/selection.dart';
import 'package:orbit/core/animations/state/animated_counter.dart';
import 'package:orbit/core/animations/state/app_animated_switcher.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_radius.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';
import 'package:orbit/core/utils/formatters.dart';
import 'package:orbit/core/widgets/app_card.dart';
import 'package:orbit/core/widgets/charts/charts.dart';

import '../../domain/entities/dashboard_month_point_entity.dart';
import '../constants/dashboard_layout_constants.dart';
import '../pure/dashboard_insights.dart';
import 'dashboard_card_header.dart';

enum _ClosingsView { bars, line }

/// Expected closings by month: deal value vs weighted value as grouped bars
/// or as a trend line, with the best month and the totals underneath.
class DashboardClosingsCard extends StatefulWidget {
  const DashboardClosingsCard({
    super.key,
    required this.months,
    required this.currency,
  });

  final List<DashboardMonthPoint> months;
  final String currency;

  @override
  State<DashboardClosingsCard> createState() => _DashboardClosingsCardState();
}

class _DashboardClosingsCardState extends State<DashboardClosingsCard> {
  _ClosingsView _view = _ClosingsView.bars;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final t = context.t.crm.dashboard.closings;
    final months = widget.months;

    final series = [
      ChartSeries(name: t.deal, color: colors.primary),
      ChartSeries(name: t.weighted, color: colors.success),
    ];
    final best = bestMonthIndex(months);
    final totalDeal = months.fold<double>(0, (s, m) => s + m.dealValue);
    final totalWeighted = months.fold<double>(0, (s, m) => s + m.weightedValue);

    return AppCard(
      padding: EdgeInsetsDirectional.all(DashboardLayoutConstants.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DashboardCardHeader(
            title: t.title,
            subtitle: t.subtitle,
            trailing: Text(
              widget.currency,
              style: textStyles.labelMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          AnimatedChipSelector<_ClosingsView>(
            selectedValue: _view,
            onChanged: (v) => setState(() => _view = v),
            items: [
              ChipItem(
                value: _ClosingsView.bars,
                label: t.viewBars,
                icon: Icons.bar_chart_rounded,
              ),
              ChipItem(
                value: _ClosingsView.line,
                label: t.viewLine,
                icon: Icons.show_chart_rounded,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          if (months.isEmpty)
            Padding(
              padding: EdgeInsetsDirectional.symmetric(
                vertical: AppSpacing.lg,
              ),
              child: Center(
                child: Text(
                  t.empty,
                  style: textStyles.bodyMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
            )
          else ...[
            AppAnimatedSwitcher(
              child: KeyedSubtree(
                key: ValueKey(_view),
                child: switch (_view) {
                  _ClosingsView.bars => AppBarChart(
                    height: DashboardLayoutConstants.chartHeight,
                    series: series,
                    valueFormatter: Formatters.compact,
                    groups: [
                      for (final m in months)
                        ChartBarGroup(
                          label: m.label,
                          values: [m.dealValue, m.weightedValue],
                        ),
                    ],
                  ),
                  _ClosingsView.line => AppLineChart(
                    height: DashboardLayoutConstants.chartHeight,
                    series: series,
                    valueFormatter: Formatters.compact,
                    labels: [for (final m in months) m.label],
                    values: [
                      [for (final m in months) m.dealValue],
                      [for (final m in months) m.weightedValue],
                    ],
                  ),
                },
              ),
            ),
            SizedBox(height: AppSpacing.md),
            _LegendRow(series: series),
            SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _Stat(label: t.deal, value: totalDeal),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _Stat(label: t.weighted, value: totalWeighted),
                ),
              ],
            ),
            if (best != null) ...[
              SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(
                    Icons.workspace_premium_rounded,
                    size: DashboardLayoutConstants.kpiIconSize,
                    color: colors.warning,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      '${t.bestMonth}: ${months[best].label} '
                      '\u00b7 ${Formatters.compact(months[best].dealValue)}',
                      style: textStyles.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.series});

  final List<ChartSeries> series;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.xs,
      children: [
        for (final s in series)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: DashboardLayoutConstants.legendDot,
                height: DashboardLayoutConstants.legendDot,
                decoration: BoxDecoration(
                  color: s.color,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: AppSpacing.xs),
              Text(s.name, style: context.textStyles.labelMedium),
            ],
          ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: AppRadius.borderMd,
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: textStyles.labelSmall.copyWith(
                color: colors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            AnimatedCounter(
              value: value,
              formatter: (n) => Formatters.compact(n),
              style: textStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
