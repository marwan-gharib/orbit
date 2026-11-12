import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:orbit/core/animations/tokens/app_curves.dart';

import 'chart_data.dart';
import 'chart_painting.dart';
import 'chart_scale.dart';

/// Paints [AppLineChart]: grid, smooth lines with area, dots, selection.
class LineChartPainter extends CustomPainter {
  LineChartPainter({
    required this.labels,
    required this.series,
    required this.values,
    required this.valueFormatter,
    required this.progress,
    required this.selected,
    required this.axisWidth,
    required this.labelHeight,
    required this.topPadding,
    required this.lineWidth,
    required this.dotRadius,
    required this.bubblePadding,
    required this.bubbleRadius,
    required this.bubbleGap,
    required this.gridColor,
    required this.bubbleColor,
    required this.dotFill,
    required this.labelStyle,
    required this.bubbleStyle,
  });

  final List<String> labels;
  final List<ChartSeries> series;
  final List<List<double>> values;
  final String Function(double) valueFormatter;
  final double progress;
  final int? selected;
  final double axisWidth;
  final double labelHeight;
  final double topPadding;
  final double lineWidth;
  final double dotRadius;
  final double bubblePadding;
  final double bubbleRadius;
  final double bubbleGap;
  final Color gridColor;
  final Color bubbleColor;
  final Color dotFill;
  final TextStyle labelStyle;
  final TextStyle bubbleStyle;

  static const double _areaAlpha = 0.22;

  @override
  void paint(Canvas canvas, Size size) {
    final plot = Rect.fromLTRB(
      axisWidth,
      topPadding,
      size.width,
      size.height - labelHeight,
    );
    final max = ChartScale.niceMax(ChartScale.maxOf(values));

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

    if (labels.isEmpty) return;
    final slot = plot.width / labels.length;
    double xAt(int i) => plot.left + slot * (i + 0.5);
    double yAt(double v) => plot.bottom - v / max * plot.height;

    for (final (i, label) in labels.indexed) {
      ChartPainting.textCenteredAt(
        canvas,
        label,
        labelStyle,
        Offset(xAt(i), plot.bottom + bubbleGap),
        maxWidth: slot,
      );
    }

    final eased = AppCurves.standard.transform(progress);
    canvas.save();
    canvas.clipRect(
      Rect.fromLTRB(
        0,
        0,
        plot.left + plot.width * eased + dotRadius * 2,
        size.height,
      ),
    );

    for (final (k, line) in values.indexed) {
      final color = series[k % series.length].color;
      final points = [
        for (final (i, v) in line.indexed) Offset(xAt(i), yAt(v)),
      ];
      if (points.isEmpty) continue;

      if (points.length > 1) {
        final path = _smooth(points, plot.top, plot.bottom);
        final area = Path.from(path)
          ..lineTo(points.last.dx, plot.bottom)
          ..lineTo(points.first.dx, plot.bottom)
          ..close();
        canvas.drawPath(
          area,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withValues(alpha: _areaAlpha),
                color.withValues(alpha: 0),
              ],
            ).createShader(plot),
        );
        canvas.drawPath(
          path,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = lineWidth
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );
      }

      for (final (i, p) in points.indexed) {
        final isSelected = selected == i;
        final radius = isSelected ? dotRadius * 1.6 : dotRadius;
        canvas.drawCircle(p, radius, Paint()..color = dotFill);
        canvas.drawCircle(
          p,
          radius,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = lineWidth * 0.7,
        );
      }
    }
    canvas.restore();

    final index = selected;
    if (index != null && progress >= 1 && index < labels.length) {
      canvas.drawLine(
        Offset(xAt(index), plot.top),
        Offset(xAt(index), plot.bottom),
        Paint()
          ..color = gridColor
          ..strokeWidth = 1.5,
      );
      final entries = [
        for (final (k, line) in values.indexed)
          if (index < line.length) (series[k % series.length], line[index]),
      ];
      final top = entries.isEmpty
          ? 0.0
          : entries.map((e) => e.$2).reduce(math.max);
      ChartPainting.bubble(
        canvas,
        size,
        Offset(xAt(index), yAt(top)),
        [
          labels[index],
          for (final e in entries) chartTooltipLine(e.$1.name, valueFormatter(e.$2)),
        ],
        background: bubbleColor,
        style: bubbleStyle,
        padding: bubblePadding,
        radius: bubbleRadius,
        gap: bubbleGap + dotRadius,
      );
    }
  }

  /// Catmull-Rom curve through [pts]; control points are kept inside
  /// [minY]..[maxY] so a curve never dips below the baseline.
  Path _smooth(List<Offset> pts, double minY, double maxY) {
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 0; i < pts.length - 1; i++) {
      final p0 = pts[math.max(i - 1, 0)];
      final p1 = pts[i];
      final p2 = pts[i + 1];
      final p3 = pts[math.min(i + 2, pts.length - 1)];
      final c1 = p1 + (p2 - p0) / 6;
      final c2 = p2 - (p3 - p1) / 6;
      path.cubicTo(
        c1.dx,
        c1.dy.clamp(minY, maxY),
        c2.dx,
        c2.dy.clamp(minY, maxY),
        p2.dx,
        p2.dy,
      );
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant LineChartPainter old) =>
      old.progress != progress ||
      old.selected != selected ||
      old.values != values ||
      old.labels != labels ||
      old.gridColor != gridColor ||
      old.labelStyle != labelStyle;
}
