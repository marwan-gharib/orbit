import 'package:flutter/material.dart';

import 'package:orbit/features/splash/presentation/constants/splash_layout_constants.dart';

/// CustomPainter for drawing elliptical orbit rings with path trim animation.
///
/// All geometry derives from the [Size] passed to [paint], relative to its
/// center, so the rings always fit the stage they are painted into.
class OrbitRingsPainter extends CustomPainter {
  const OrbitRingsPainter({required this.progress, required this.ringColor});

  /// Draw-in progress for the rings, clamped to 0..1.
  final double progress;

  /// Ring stroke color, supplied by the composition from the theme.
  final Color ringColor;

  // (semi-major axis, semi-minor axis, tilt radians) as fractions of the
  // stage side.
  static const List<({double a, double b, double tilt})> _rings = [
    (
      a: SplashLayoutRatios.ring1SemiMajorOfStage,
      b:
          SplashLayoutRatios.ring1SemiMajorOfStage *
          SplashLayoutRatios.ring1MinorMajorRatio,
      tilt: SplashLayoutRatios.ring1TiltRadians,
    ),
    (
      a: SplashLayoutRatios.ring2SemiMajorOfStage,
      b:
          SplashLayoutRatios.ring2SemiMajorOfStage *
          SplashLayoutRatios.ring2MinorMajorRatio,
      tilt: SplashLayoutRatios.ring2TiltRadians,
    ),
  ];

  /// Stagger between consecutive rings' draw-in, as a fraction of the
  /// draw-in phase (matches the original 5%-per-ring cadence).
  static const double _ringStagger = 0.05 / 0.125;

  @override
  void paint(Canvas canvas, Size size) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final side = size.shortestSide;
    final center = size.center(Offset.zero);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = SplashLayoutRatios.ringStrokeOfStage * side
      ..color = ringColor
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < _rings.length; i++) {
      // Stagger each ring's draw-in
      final ringProgress = (clampedProgress - i * _ringStagger).clamp(0.0, 1.0);
      if (ringProgress <= 0) continue;

      final ring = _rings[i];
      final path = _buildEllipsePath(
        center: center,
        semiMajor: ring.a * side,
        semiMinor: ring.b * side,
        tilt: ring.tilt,
      );
      final metrics = path.computeMetrics().first;
      final trimmedPath = metrics.extractPath(
        0.0,
        metrics.length * ringProgress,
      );

      canvas.drawPath(trimmedPath, paint);
    }
  }

  Path _buildEllipsePath({
    required Offset center,
    required double semiMajor,
    required double semiMinor,
    required double tilt,
  }) {
    final path = Path();
    final rect = Rect.fromCenter(
      center: center,
      width: semiMajor * 2,
      height: semiMinor * 2,
    );
    path.addOval(rect);
    final matrix = Matrix4.identity()
      ..translateByDouble(center.dx, center.dy, 0.0, 1.0)
      ..rotateZ(tilt)
      ..translateByDouble(-center.dx, -center.dy, 0.0, 1.0);
    return path.transform(matrix.storage);
  }

  @override
  bool shouldRepaint(covariant OrbitRingsPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.ringColor != ringColor;
}
