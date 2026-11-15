import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tokens/app_animation_constants.dart';
import '../tokens/app_curves.dart';
import '../tokens/app_durations.dart';
import 'progress_driver.dart';

/// A check mark that draws itself once on first display, followed by a small
/// burst of dots. Built with a [CustomPainter] (no packages).
///
/// With "reduce motion" on, the check appears already drawn and no burst
/// plays.
///
/// ```dart
/// DrawnCheck(color: colors.success)
/// ```
class DrawnCheck extends StatelessWidget {
  const DrawnCheck({
    super.key,
    required this.color,
    this.size = AppAnimationConstants.drawnCheckSize,
    this.burst = true,
  });

  /// Colour of the check and the burst dots.
  final Color color;

  /// Edge of the square the check is drawn in. The burst may reach past it.
  final double size;

  /// Whether the dots burst out once the check is drawn.
  final bool burst;

  @override
  Widget build(BuildContext context) {
    final playBurst = burst && !MediaQuery.disableAnimationsOf(context);

    return ProgressDriver(
      duration: AppDurations.extraSlow,
      active: true,
      builder: (context, progress, child) => RepaintBoundary(
        child: CustomPaint(
          size: Size.square(size),
          painter: _DrawnCheckPainter(
            progress: progress,
            color: color,
            burst: playBurst,
          ),
        ),
      ),
      child: const SizedBox.shrink(),
    );
  }
}

class _DrawnCheckPainter extends CustomPainter {
  const _DrawnCheckPainter({
    required this.progress,
    required this.color,
    required this.burst,
  });

  final double progress;
  final Color color;
  final bool burst;

  // Share of the timeline used to draw the check; the burst uses the rest.
  static const double _drawShare = 0.5;
  static const int _dots = 8;

  @override
  void paint(Canvas canvas, Size size) {
    final draw = AppCurves.standard.transform(
      (progress / _drawShare).clamp(0.0, 1.0),
    );

    final path = Path()
      ..moveTo(size.width * 0.22, size.height * 0.52)
      ..lineTo(size.width * 0.42, size.height * 0.72)
      ..lineTo(size.width * 0.78, size.height * 0.30);
    final metric = path.computeMetrics().first;
    canvas.drawPath(
      metric.extractPath(0, metric.length * draw),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.1
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    if (!burst || progress <= _drawShare) return;
    final t = ((progress - _drawShare) / (1 - _drawShare)).clamp(0.0, 1.0);
    final eased = AppCurves.enter.transform(t);
    final center = size.center(Offset.zero);
    final paint = Paint()..color = color.withValues(alpha: 1 - t);
    for (var i = 0; i < _dots; i++) {
      final angle = 2 * math.pi * i / _dots;
      final distance = size.width * (0.55 + 0.3 * eased);
      canvas.drawCircle(
        center + Offset(math.cos(angle), math.sin(angle)) * distance,
        size.width * 0.05 * (1 - t),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DrawnCheckPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.burst != burst;
}
