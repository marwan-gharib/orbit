import 'package:flutter/material.dart';
import 'package:orbit/core/animations/state/progress_driver.dart';
import 'package:orbit/core/animations/tokens/app_durations.dart';
import 'package:orbit/core/responsive/responsive.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';

import 'chart_data.dart';
import 'line_chart_painter.dart';

/// Smooth multi-series line chart with a soft area under each line. The lines
/// are drawn from start to end on first display; tapping a point shows a
/// guide line and a value bubble.
///
/// [values] holds one list per entry of [series]; each list has one value per
/// entry of [labels].
class AppLineChart extends StatefulWidget {
  const AppLineChart({
    super.key,
    required this.labels,
    required this.series,
    required this.values,
    required this.valueFormatter,
    this.height,
  });

  final List<String> labels;
  final List<ChartSeries> series;
  final List<List<double>> values;
  final String Function(double value) valueFormatter;
  final double? height;

  @override
  State<AppLineChart> createState() => _AppLineChartState();
}

class _AppLineChartState extends State<AppLineChart> {
  int? _selected;

  double get _axisWidth => Responsive.adapt(44);

  void _onTap(TapDownDetails details, double width) {
    final count = widget.labels.length;
    if (count == 0) return;
    final slot = (width - _axisWidth) / count;
    final index = ((details.localPosition.dx - _axisWidth) / slot).floor();
    setState(() {
      _selected = (index < 0 || index >= count || index == _selected)
          ? null
          : index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final height = widget.height ?? Responsive.adapt(220);

    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) => _onTap(details, constraints.maxWidth),
          child: ProgressDriver(
            duration: AppDurations.extraSlow,
            active: true,
            builder: (context, progress, _) => RepaintBoundary(
              child: CustomPaint(
                size: Size(constraints.maxWidth, height),
                painter: LineChartPainter(
                  labels: widget.labels,
                  series: widget.series,
                  values: widget.values,
                  valueFormatter: widget.valueFormatter,
                  progress: progress,
                  selected: _selected,
                  axisWidth: _axisWidth,
                  labelHeight: Responsive.adapt(28),
                  topPadding: Responsive.adapt(12),
                  lineWidth: Responsive.adapt(3),
                  dotRadius: Responsive.adapt(4),
                  bubblePadding: AppSpacing.sm,
                  bubbleRadius: AppSpacing.sm,
                  bubbleGap: AppSpacing.xs,
                  gridColor: colors.border,
                  bubbleColor: colors.surfaceElevated,
                  dotFill: colors.surface,
                  labelStyle: textStyles.labelSmall.copyWith(
                    color: colors.textSecondary,
                  ),
                  bubbleStyle: textStyles.labelSmall.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ),
            child: const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
