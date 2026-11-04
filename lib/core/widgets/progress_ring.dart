import 'package:flutter/material.dart';

import 'package:orbit/core/responsive/responsive.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';

/// A circular progress ring driven by an external [progress] value (0.0 to 1.0).
///
/// Used for probability rings, completion circles, etc. The ring draws a sweep
/// from 0 to [progress] with configurable stroke width and colors.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.progress,
    required this.strokeWidth,
    this.trackColor,
    this.progressColor,
    this.size,
    this.backgroundColor,
  });

  /// The progress value, clamped to 0.0..1.0.
  final double progress;

  /// Width of the ring stroke.
  final double strokeWidth;

  /// Color of the track (background of the ring).
  final Color? trackColor;

  /// Color of the progress arc.
  final Color? progressColor;

  /// Overall diameter of the ring.
  final double? size;

  /// Background color behind the ring (optional).
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveSize = size ?? Responsive.adapt(48);
    final clampedProgress = progress.clamp(0.0, 1.0);

    return SizedBox(
      width: effectiveSize,
      height: effectiveSize,
      child: CustomPaint(
        painter: _ProgressRingPainter(
          progress: clampedProgress,
          strokeWidth: strokeWidth,
          trackColor: trackColor ?? colors.border,
          progressColor: progressColor ?? colors.primary,
          backgroundColor: backgroundColor,
        ),
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  _ProgressRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.trackColor,
    required this.progressColor,
    this.backgroundColor,
  });

  final double progress;
  final double strokeWidth;
  final Color trackColor;
  final Color progressColor;
  final Color? backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background circle if provided
    if (backgroundColor != null) {
      final bgPaint = Paint()
        ..color = backgroundColor!
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius + strokeWidth / 2, bgPaint);
    }

    // Draw track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    // Draw progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      const startAngle = -3.14159 / 2; // -90 degrees (top)
      final sweepAngle = 2 * 3.14159 * progress;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.progressColor != progressColor ||
      oldDelegate.backgroundColor != backgroundColor;
}