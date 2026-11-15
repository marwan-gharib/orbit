import 'package:flutter/material.dart';
import 'package:orbit/core/animations/state/animated_counter.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';
import 'package:orbit/core/widgets/app_card.dart';
import 'package:orbit/core/widgets/charts/charts.dart';

import '../../domain/entities/dashboard_win_ratio_entity.dart';
import '../constants/dashboard_layout_constants.dart';
import 'dashboard_card_header.dart';
import 'dashboard_legend_item.dart';

/// Won vs lost as a donut with the win percentage counting up in its hole,
/// plus a legend with the two counts. Tap a slice to see its count.
class DashboardWinRatioCard extends StatelessWidget {
  const DashboardWinRatioCard({super.key, required this.winRatio});

  final DashboardWinRatio winRatio;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final t = context.t.crm.dashboard.winRatio;
    final closed = winRatio.wonCount + winRatio.lostCount;

    final slices = [
      ChartSlice(
        label: t.won,
        value: winRatio.wonCount.toDouble(),
        color: colors.success,
      ),
      ChartSlice(
        label: t.lost,
        value: winRatio.lostCount.toDouble(),
        color: colors.error,
      ),
    ];

    return AppCard(
      padding: EdgeInsetsDirectional.all(DashboardLayoutConstants.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DashboardCardHeader(title: t.title, subtitle: t.subtitle),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              AppDonutChart(
                slices: slices,
                size: DashboardLayoutConstants.donutSize,
                centerBuilder: (context, selected) {
                  if (selected != null) {
                    final slice = slices[selected];
                    return _Center(
                      value: slice.value,
                      suffix: '',
                      caption: slice.label,
                      color: slice.color,
                    );
                  }
                  return _Center(
                    value: winRatio.percentage,
                    suffix: '%',
                    caption: t.won,
                    color: colors.success,
                  );
                },
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DashboardLegendItem(
                      color: colors.success,
                      label: t.won,
                      value: '${winRatio.wonCount}',
                    ),
                    DashboardLegendItem(
                      color: colors.error,
                      label: t.lost,
                      value: '${winRatio.lostCount}',
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      closed == 0
                          ? t.noClosed
                          : t.closedDeals(count: closed),
                      style: textStyles.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Center extends StatelessWidget {
  const _Center({
    required this.value,
    required this.suffix,
    required this.caption,
    required this.color,
  });

  final double value;
  final String suffix;
  final String caption;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedCounter(
          value: value,
          formatter: (n) => '${n.round()}$suffix',
          style: textStyles.titleLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          caption,
          style: textStyles.labelSmall.copyWith(
            color: context.colors.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
