import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'package:orbit/features/splash/presentation/constants/splash_animation_constants.dart';

/// Exit transition: scale up + fade out, hands off to next route.
///
/// Always wraps the whole content composition with the same subtree — only
/// the transform and opacity values change — so the tree and its layout are
/// identical at every point of the timeline, including completion.
class ExitTransitionWidget extends StatelessWidget {
  const ExitTransitionWidget({
    super.key,
    required this.controller,
    required this.child,
  });

  final AnimationController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const startMs = SplashAnimationConstants.exitStartMs;
    const endMs = SplashAnimationConstants.exitEndMs;
    const totalMs = SplashAnimationConstants.totalDurationMs;

    final interval = Interval(startMs / totalMs, endMs / totalMs);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final exitProgress = interval.transform(controller.value);

        final scale = lerpDouble(
          1.0,
          SplashAnimationConstants.exitScale,
          Curves.easeInCubic.transform(exitProgress),
        )!;
        final opacity = lerpDouble(
          1.0,
          0.0,
          Curves.easeInCubic.transform(exitProgress),
        )!;

        return Transform.scale(
          scale: scale,
          alignment: Alignment.center,
          child: Opacity(opacity: opacity, child: child),
        );
      },
    );
  }
}
