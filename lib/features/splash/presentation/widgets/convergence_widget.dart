import 'dart:math' show cos, sin;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'package:orbit/features/splash/presentation/constants/splash_animation_constants.dart';
import 'package:orbit/features/splash/presentation/constants/splash_layout_constants.dart';

/// Convergence: nodes spiral inward and lock into ring around logo with micro-pulse.
///
/// All radii and node sizes are fractions of the stage side, so the lock-in
/// ring stays centered on and proportional to the logo stage.
class ConvergenceWidget extends StatelessWidget {
  const ConvergenceWidget({
    super.key,
    required this.controller,
    required this.nodeCount,
    required this.stageSide,
    required this.nodeColors,
  });

  final AnimationController controller;
  final int nodeCount;

  /// Side length of the square stage the nodes lock into.
  final double stageSide;

  /// Theme tokens for the locking nodes — same palette the orbiting
  /// nodes use in [SplashComposition].
  final List<Color> nodeColors;

  @override
  Widget build(BuildContext context) {
    const startMs = SplashAnimationConstants.convergenceStartMs;
    const endMs = SplashAnimationConstants.convergenceEndMs;
    const totalMs = SplashAnimationConstants.totalDurationMs;

    final interval = Interval(startMs / totalMs, endMs / totalMs);
    final progress = interval.transform(controller.value);

    if (progress <= 0) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final pulseProgress = _pulseProgress(progress);

        return Stack(
          alignment: Alignment.center,
          children: [
            // Micro-pulse on entire composition
            Transform.scale(
              scale:
                  1.0 +
                  (SplashAnimationConstants.holdPulseScale - 1.0) *
                      pulseProgress,
              child: Opacity(
                opacity: 1.0 - 0.1 * pulseProgress,
                child: child ?? const SizedBox.shrink(),
              ),
            ),
            // Nodes locking into final ring positions
            ...List.generate(nodeCount, (i) {
              return _ConvergingNode(
                index: i,
                progress: progress,
                stageSide: stageSide,
                nodeCount: nodeCount,
                color: nodeColors[i % nodeColors.length],
              );
            }),
          ],
        );
      },
      child: const SizedBox.shrink(),
    );
  }

  double _pulseProgress(double progress) {
    // Pulse at the end of convergence (last 30%)
    if (progress < 0.7) return 0.0;
    // At progress == 1.0 the division rounds just above 1.0, which the curve
    // rejects with an assertion; return the endpoint directly instead.
    if (progress >= 1.0) return 1.0;
    return Curves.easeInOut.transform((progress - 0.7) / 0.3);
  }
}

/// Single node converging to final ring position.
class _ConvergingNode extends StatelessWidget {
  const _ConvergingNode({
    required this.index,
    required this.progress,
    required this.stageSide,
    required this.nodeCount,
    required this.color,
  });

  final int index;
  final double progress;
  final double stageSide;
  final int nodeCount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    // Final ring radius, as a fraction of the stage side.
    final finalRadius = SplashLayoutRatios.lockInRadiusOfStage * stageSide;
    final angle = (index / nodeCount) * 2 * 3.14159;

    // Interpolate from orbit position to final ring position
    final currentRadius = lerpDouble(
      (SplashLayoutRatios.lockInStartRadiusOfStage -
              index * SplashLayoutRatios.lockInStartRadiusStepOfStage) *
          stageSide, // Starting radius (approx)
      finalRadius,
      Curves.easeOutBack.transform(progress),
    )!;

    final x = currentRadius * cos(angle);
    final y = currentRadius * sin(angle);

    final diameter = SplashLayoutRatios.lockInNodeDiameterOfStage * stageSide;

    return Transform.translate(
      offset: Offset(x, y),
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.5),
              blurRadius: SplashLayoutRatios.lockInGlowBlurOfStage * stageSide,
              spreadRadius:
                  SplashLayoutRatios.lockInGlowSpreadOfStage * stageSide,
            ),
          ],
        ),
      ),
    );
  }
}
