import 'package:flutter/material.dart';

import 'package:orbit/features/splash/presentation/constants/splash_animation_constants.dart';
import 'package:orbit/features/splash/presentation/constants/splash_layout_constants.dart';

/// CustomPainter for drawing 5 orbiting module nodes with comet trails.
/// Uses precomputed positions to avoid per-frame allocations.
///
/// Positions are precomputed as fractions of the stage side; [paint] scales
/// them by the live [Size] so nodes always orbit proportionally inside the
/// stage they are painted into, relative to its center.
class ModuleNodesPainter extends CustomPainter {
  ModuleNodesPainter({
    required this.nodePositionFractions,
    required this.frameIndex,
    required this.trailHistoryLength,
    required this.nodeColors,
    required this.trailColors,
  });

  /// Per-frame node positions as fractions of the stage side.
  final List<List<Offset>> nodePositionFractions;
  final int frameIndex;
  final int trailHistoryLength;
  final List<Color> nodeColors;
  final List<Color> trailColors;

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    final center = size.center(Offset.zero);
    const nodeCount = SplashAnimationConstants.moduleNodeCount;

    // Draw trails first (behind nodes)
    for (int i = 0; i < nodeCount; i++) {
      _drawTrail(canvas, center, side, i);
    }

    // Draw nodes on top
    for (int i = 0; i < nodeCount; i++) {
      _drawNode(canvas, center, side, i);
    }
  }

  Offset _screenPos(Offset center, double side, Offset fraction) =>
      center + fraction * side;

  void _drawTrail(Canvas canvas, Offset center, double side, int nodeIndex) {
    if (frameIndex < trailHistoryLength) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = SplashLayoutRatios.nodeTrailStrokeOfStage * side
      ..color = trailColors[nodeIndex]
      ..strokeCap = StrokeCap.round;

    final trailPath = Path();
    bool started = false;

    // Draw trail segments from history
    for (int h = 0; h < trailHistoryLength; h++) {
      final historyFrame = frameIndex - h;
      if (historyFrame < 0) break;

      final fraction = nodePositionFractions[nodeIndex][historyFrame];
      if (fraction == Offset.zero) continue;

      final screenPos = _screenPos(center, side, fraction);
      if (!started) {
        trailPath.moveTo(screenPos.dx, screenPos.dy);
        started = true;
      } else {
        trailPath.lineTo(screenPos.dx, screenPos.dy);
      }
    }

    if (started) {
      canvas.drawPath(trailPath, paint);
    }
  }

  void _drawNode(Canvas canvas, Offset center, double side, int nodeIndex) {
    final fraction = nodePositionFractions[nodeIndex][frameIndex];
    if (fraction == Offset.zero) return;

    final screenPos = _screenPos(center, side, fraction);

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = nodeColors[nodeIndex];
    canvas.drawCircle(
      screenPos,
      SplashLayoutRatios.nodeRadiusOfStage * side,
      paint,
    );

    // Inner glow
    final glowPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = nodeColors[nodeIndex].withValues(alpha: 0.3);
    canvas.drawCircle(
      screenPos,
      SplashLayoutRatios.nodeGlowRadiusOfStage * side,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ModuleNodesPainter oldDelegate) =>
      oldDelegate.frameIndex != frameIndex ||
      oldDelegate.nodeColors != nodeColors ||
      oldDelegate.trailColors != trailColors;
}
