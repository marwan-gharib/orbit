import 'package:flutter/material.dart';
import 'package:orbit/core/animations/state/progress_driver.dart';
import 'package:orbit/core/animations/tokens/app_curves.dart';
import 'package:orbit/core/animations/tokens/app_durations.dart';
import 'package:orbit/core/responsive/responsive.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';

import 'chart_data.dart';
import 'chart_painting.dart';
import 'chart_scale.dart';

/// Grouped vertical bar chart: bars grow in one after another on first
/// display, tapping a group shows a value bubble.
///
/// ```dart
/// AppBarChart(
///   groups: [ChartBarGroup(label: 'Jan', values: [10, 6])],
///   series: [
///     ChartSeries(name: 'Deal', color: colors.primary),
///     ChartSeries(name: 'Weighted', color: colors.success),
///   ],
///   valueFormatter: Formatters.compact,
/// )
/// ```
class AppBarChart extends StatefulWidget {
  const AppBarChart({
    super.key,
    required this.groups,
    required this.series,
    required this.valueFormatter,
    this.height,
  });

  final List<ChartBarGroup> groups;

  /// One entry per value of each group (names and colours).
  final List<ChartSeries> series;
  final String Function(double value) valueFormatter;

  /// Total height; defaults to a responsive chart height.
  final double? height;

  @override
  State<AppBarChart> createState() => _AppBarChartState();
}

class _AppBarChartState extends State<AppBarChart> {
  int? _selected;

  double get _axisWidth => Responsive.adapt(44);

  void _onTap(TapDownDetails details, double width) {
    final count = widget.groups.length;
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
                painter: _BarChartPainter(
                  groups: widget.groups,
                  series: widget.series,
                  valueFormatter: widget.valueFormatter,
                  progress: progress,
                  selected: _selected,
                  axisWidth: _axisWidth,
                  labelHeight: Responsive.adapt(28),
                  topPadding: Responsive.adapt(8),
                  barRadius: Responsive.adapt(6),
                  barGap: Responsive.adapt(3),
                  bubblePadding: AppSpacing.sm,
                  bubbleRadius: AppSpacing.sm,
                  bubbleGap: AppSpacing.xs,
                  gridColor: colors.border,
                  selectionColor: colors.primary.withValues(alpha: 0.08),
                  bubbleColor: colors.surfaceElevated,
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

class _BarChartPainter extends CustomPainter {
  _BarChartPainter({
    required this.groups,
    required this.series,
    required this.valueFormatter,
    required this.progress,
    required this.selected,
    required this.axisWidth,
    required this.labelHeight,
    required this.topPadding,
    required this.barRadius,
    required this.barGap,
    required this.bubblePadding,
    required this.bubbleRadius,
    required this.bubbleGap,
    required this.gridColor,
    required this.selectionColor,
    required this.bubbleColor,
    required this.labelStyle,
    required this.bubbleStyle,
  });

  final List<ChartBarGroup> groups;
  final List<ChartSeries> series;
  final String Function(double) valueFormatter;
  final double progress;
  final int? selected;
  final double axisWidth;
  final double labelHeight;
  final double topPadding;
  final double barRadius;
  final double barGap;
  final double bubblePadding;
  final double bubbleRadius;
  final double bubbleGap;
  final Color gridColor;
  final Color selectionColor;
  final Color bubbleColor;
  final TextStyle labelStyle;
  final TextStyle bubbleStyle;

  static const double _groupFill = 0.7;
  static const double _stagger = 0.08;

  @override
  void paint(Canvas canvas, Size size) {
    final plot = Rect.fromLTRB(
      axisWidth,
      topPadding,
      size.width,
      size.height - labelHeight,
    );
    final max = ChartScale.niceMax(
      ChartScale.maxOf(groups.map((g) => g.values)),
    );

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (final value in ChartScale.gridValues(max)) {
      final y = plot.bottom - value / max * plot.height;
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), gridPaint);
      ChartPainting.textEndingAt(
        canvas,
        valueFormatter(value),
        labelStyle,
        Offset(plot.left - bubbleGap, y),
      );
    }

    if (groups.isEmpty) return;
    final slot = plot.width / groups.length;
    final seriesCount = series.isEmpty ? 1 : series.length;

    for (final (i, group) in groups.indexed) {
      final slotLeft = plot.left + slot * i;
      if (selected == i) {
        canvas.drawRect(
          Rect.fromLTWH(slotLeft, plot.top, slot, plot.height),
          Paint()..color = selectionColor,
        );
      }

      final groupWidth = slot * _groupFill;
      final barWidth = (groupWidth - barGap * (seriesCount - 1)) / seriesCount;
      final start = slotLeft + (slot - groupWidth) / 2;
      final local = ((progress - _stagger * i) / (1 - _stagger * groups.length))
          .clamp(0.0, 1.0);
      final eased = AppCurves.enter.transform(local);

      for (final (k, value) in group.values.indexed) {
        final barHeight = value / max * plot.height * eased;
        if (barHeight <= 0) continue;
        final left = start + k * (barWidth + barGap);
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTWH(left, plot.bottom - barHeight, barWidth, barHeight),
            topLeft: Radius.circular(barRadius),
            topRight: Radius.circular(barRadius),
          ),
          Paint()..color = group.color ?? series[k % series.length].color,
        );
      }

      ChartPainting.textCenteredAt(
        canvas,
        group.label,
        labelStyle,
        Offset(slotLeft + slot / 2, plot.bottom + bubbleGap),
        maxWidth: slot,
      );
    }

    final index = selected;
    if (index != null && progress >= 1 && index < groups.length) {
      final group = groups[index];
      final top = group.values.isEmpty
          ? 0.0
          : group.values.reduce((a, b) => a > b ? a : b);
      ChartPainting.bubble(
        canvas,
        size,
        Offset(
          plot.left + slot * index + slot / 2,
          plot.bottom - top / max * plot.height,
        ),
        [
          group.label,
          for (final (k, value) in group.values.indexed)
            chartTooltipLine(series[k % series.length].name, valueFormatter(value)),
        ],
        background: bubbleColor,
        style: bubbleStyle,
        padding: bubblePadding,
        radius: bubbleRadius,
        gap: bubbleGap,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter old) =>
      old.progress != progress ||
      old.selected != selected ||
      old.groups != groups ||
      old.series != series ||
      old.gridColor != gridColor ||
      old.labelStyle != labelStyle;
}
