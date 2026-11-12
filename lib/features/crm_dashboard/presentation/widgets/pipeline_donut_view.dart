import 'package:flutter/material.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';
import 'package:orbit/core/widgets/charts/charts.dart';

import '../../domain/entities/dashboard_stage_slice_entity.dart';
import '../constants/dashboard_layout_constants.dart';
import '../pure/dashboard_insights.dart';
import '../pure/dashboard_palette.dart';
import 'dashboard_legend_item.dart';

/// Stage mix as a donut (tap a slice for its figure) with a legend that
/// shows each stage's share of the total.
class PipelineDonutView extends StatelessWidget {
  const PipelineDonutView({
    super.key,
    required this.stages,
    required this.byValue,
    required this.format,
  });

  final List<DashboardStageSlice> stages;
  final bool byValue;
  final String Function(double value) format;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final t = context.t.crm.dashboard.pipeline;
    final metrics = [for (final s in stages) stageMetric(s, byValue: byValue)];
    final total = metrics.fold<double>(0, (sum, v) => sum + v);

    final slices = [
      for (final (i, s) in stages.indexed)
        ChartSlice(
          label: s.label,
          value: metrics[i],
          color: dashboardStageColor(context, s.stage),
        ),
    ];

    return Column(
      children: [
        AppDonutChart(
          slices: slices,
          size: DashboardLayoutConstants.donutSize,
          centerBuilder: (context, selected) => Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                format(selected == null ? total : metrics[selected]),
                style: textStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                selected == null ? t.total : stages[selected].label,
                style: textStyles.labelSmall.copyWith(
                  color: colors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.md),
        for (final (i, s) in stages.indexed)
          DashboardLegendItem(
            color: dashboardStageColor(context, s.stage),
            label: s.label,
            value: format(metrics[i]),
            caption: '${(shareOf(metrics[i], total) * 100).round()}%',
          ),
      ],
    );
  }
}
