import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:orbit/core/animations/state/progress_driver.dart';
import 'package:orbit/core/animations/tokens/app_curves.dart';
import 'package:orbit/core/animations/tokens/app_durations.dart';
import 'package:orbit/core/responsive/responsive.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';

import 'chart_data.dart';

/// Donut chart whose ring sweeps in on first display. Tapping a slice pops it
/// out and dims the others; tapping it again (or the centre) clears the
/// selection. [centerBuilder] draws inside the hole and receives the
/// selected slice index (or null).
///
/// An all-zero chart shows an empty track ring.
class AppDonutChart extends StatefulWidget {
  const AppDonutChart({
    super.key,
    required this.slices,
    this.centerBuilder,
    this.onSelectionChanged,
    this.size,
  });

  final List<ChartSlice> slices;
  final Widget Function(BuildContext context, int? selectedIndex)?
  centerBuilder;
  final ValueChanged<int?>? onSelectionChanged;

  /// Edge of the square the chart occupies; defaults to a responsive size.
  final double? size;

  @override
  State<AppDonutChart> createState() => _AppDonutChartState();
}

class _AppDonutChartState extends State<AppDonutChart> {
  int? _selected;

  static const double _thicknessFactor = 0.16;
  static const double _gapAngle = 0.04;

  void _select(int? index) {
    if (index == _selected) index = null;
    setState(() => _selected = index);
    widget.onSelectionChanged?.call(index);
  }

  void _onTap(TapDownDetails details, double edge) {
    final center = Offset(edge / 2, edge / 2);
    final delta = details.localPosition - center;
    final radius = edge / 2;
    final thickness = edge * _thicknessFactor;
    final distance = delta.distance;
    if (distance > radius || distance < radius - thickness * 2) {
      _select(null);
      return;
    }
    final total = widget.slices.fold<double>(0, (s, e) => s + math.max(0, e.value));
    if (total <= 0) return;
    var angle = math.atan2(delta.dy, delta.dx) + math.pi / 2;
    if (angle < 0) angle += 2 * math.pi;
    var start = 0.0;
    for (final (i, slice) in widget.slices.indexed) {
      final sweep = math.max(0, slice.value) / total * 2 * math.pi;
      if (angle >= start && angle < start + sweep) {
        _select(i);
        return;
      }
      start += sweep;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final edge = widget.size ?? Responsive.adapt(180);

    return SizedBox(
      width: edge,
      height: edge,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (details) => _onTap(details, edge),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ProgressDriver(
              duration: AppDurations.extraSlow,
              active: true,
              builder: (context, progress, _) => RepaintBoundary(
                child: CustomPaint(
                  size: Size.square(edge),
                  painter: _DonutPainter(
                    slices: widget.slices,
                    progress: progress,
                    selected: _selected,
                    thickness: edge * _thicknessFactor,
                    gapAngle: _gapAngle,
                    trackColor: colors.surfaceContainerHighest,
                  ),
                ),
              ),
              child: const SizedBox.shrink(),
            ),
            if (widget.centerBuilder != null)
              Padding(
                padding: EdgeInsets.all(edge * _thicknessFactor * 1.4),
                // Scales the hole's content down instead of overflowing when
                // the text size is large.
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: widget.centerBuilder!(context, _selected),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.slices,
    required this.progress,
    required this.selected,
    required this.thickness,
    required this.gapAngle,
    required this.trackColor,
  });

  final List<ChartSlice> slices;
  final double progress;
  final int? selected;
  final double thickness;
  final double gapAngle;
  final Color trackColor;

  static const double _dimAlpha = 0.45;
  static const double _popFactor = 1.25;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - thickness * _popFactor / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness,
    );

    final total = slices.fold<double>(0, (s, e) => s + math.max(0, e.value));
    if (total <= 0) return;

    final eased = AppCurves.standard.transform(progress);
    final visible = slices.where((s) => s.value > 0).length;
    final gap = visible > 1 ? gapAngle : 0.0;
    var start = -math.pi / 2;

    for (final (i, slice) in slices.indexed) {
      final full = math.max(0, slice.value) / total * 2 * math.pi;
      final sweep = full * eased;
      if (full > 0 && sweep > gap) {
        final isSelected = selected == i;
        final dim = selected != null && !isSelected;
        canvas.drawArc(
          rect,
          start + gap / 2,
          sweep - gap,
          false,
          Paint()
            ..color = slice.color.withValues(alpha: dim ? _dimAlpha : 1)
            ..style = PaintingStyle.stroke
            ..strokeWidth = isSelected ? thickness * _popFactor : thickness
            ..strokeCap = StrokeCap.butt,
        );
      }
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.progress != progress ||
      old.selected != selected ||
      old.slices != slices ||
      old.trackColor != trackColor;
}
