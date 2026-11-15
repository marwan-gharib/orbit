import 'package:flutter/material.dart';
import 'package:orbit/core/widgets/charts/charts.dart';

import '../../domain/entities/dashboard_stage_slice_entity.dart';
import '../constants/dashboard_layout_constants.dart';
import '../pure/dashboard_insights.dart';
import '../pure/dashboard_palette.dart';

/// One bar per stage (stage colours), growing in one after another. Tap a
/// bar for its figure.
class PipelineBarsView extends StatelessWidget {
  const PipelineBarsView({
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
    return AppBarChart(
      height: DashboardLayoutConstants.chartHeight,
      valueFormatter: format,
      series: [
        ChartSeries(
          name: '',
          color: dashboardStageColor(context, stages.first.stage),
        ),
      ],
      groups: [
        for (final s in stages)
          ChartBarGroup(
            label: s.label,
            values: [stageMetric(s, byValue: byValue)],
            color: dashboardStageColor(context, s.stage),
          ),
      ],
    );
  }
}
