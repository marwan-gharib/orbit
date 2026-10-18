import 'dart:ui' show lerpDouble, ImageFilter;

import 'package:flutter/material.dart';

import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/features/splash/presentation/constants/splash_animation_constants.dart';
import 'package:orbit/features/splash/presentation/constants/splash_layout_constants.dart';

/// Logo reveal with scale+overshoot, blur-in, rotation, fade, and shockwave.
///
/// Sizes derive from the stage side so the logo and its shockwave stay
/// proportional to the stage, never to raw pixels.
class LogoRevealWidget extends StatelessWidget {
  const LogoRevealWidget({
    super.key,
    required this.controller,
    required this.logoAsset,
    required this.stageSide,
    required this.shockwaveMaxRadius,
  });

  final AnimationController controller;
  final String logoAsset;

  /// Side length of the square stage this logo sits in.
  final double stageSide;

  /// Largest shockwave radius, from the short screen side so the ring never
  /// runs off a narrow edge.
  final double shockwaveMaxRadius;

  double get _logoWidth => SplashLayoutRatios.logoWidthOfStage * stageSide;

  @override
  Widget build(BuildContext context) {
    final logoInterval = Interval(
      SplashAnimationConstants.logoRevealStartMs /
          SplashAnimationConstants.totalDurationMs,
      SplashAnimationConstants.logoRevealEndMs /
          SplashAnimationConstants.totalDurationMs,
    );

    final shockwaveInterval = Interval(
      SplashAnimationConstants.shockwaveStartMs /
          SplashAnimationConstants.totalDurationMs,
      SplashAnimationConstants.shockwaveEndMs /
          SplashAnimationConstants.totalDurationMs,
    );

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final progress = controller.value;
        final logoProgress = logoInterval.transform(progress);
        final shockwaveProgress = shockwaveInterval.transform(progress);

        if (logoProgress <= 0) return const SizedBox.shrink();

        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Shockwave ring
            if (shockwaveProgress > 0)
              _ShockwaveRing(
                progress: shockwaveProgress,
                stageSide: stageSide,
                maxRadius: shockwaveMaxRadius,
              ),

            // Logo with transformations
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.diagonal3Values(
                _logoScale(logoProgress),
                _logoScale(logoProgress),
                1.0,
              )..rotateZ(_logoRotation(logoProgress)),
              child: Opacity(
                opacity: logoProgress.clamp(0.0, 1.0),
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(
                    sigmaX: _blurSigma(logoProgress),
                    sigmaY: _blurSigma(logoProgress),
                  ),
                  child: Image.asset(
                    logoAsset,
                    width: _logoWidth,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  double _logoScale(double progress) {
    // Spring-like: 0.6 -> 1.05 -> 1.0
    if (progress < 0.7) {
      // Rise to overshoot
      return lerpDouble(
        SplashAnimationConstants.logoInitialScale,
        SplashAnimationConstants.logoOvershootScale,
        Curves.easeOutBack.transform(progress / 0.7),
      )!;
    } else {
      // Settle to 1.0
      return lerpDouble(
        SplashAnimationConstants.logoOvershootScale,
        SplashAnimationConstants.logoFinalScale,
        (progress - 0.7) / 0.3,
      )!;
    }
  }

  double _logoRotation(double progress) {
    // -5 degrees to 0
    return lerpDouble(
      SplashAnimationConstants.logoInitialRotationDegrees * 3.14159 / 180,
      0.0,
      progress,
    )!;
  }

  double _blurSigma(double progress) {
    // 8 to 0
    return lerpDouble(
      SplashAnimationConstants.blurSigmaStart,
      SplashAnimationConstants.blurSigmaEnd,
      progress,
    )!;
  }
}

/// Expanding shockwave ring at logo landing. Starts at the logo edge and
/// expands toward the short screen side, fading out; always centered on the
/// stage center. Scaled via [Transform] so the layout stays at the base size
/// and the ring can paint beyond the stage without being clamped.
class _ShockwaveRing extends StatelessWidget {
  const _ShockwaveRing({
    required this.progress,
    required this.stageSide,
    required this.maxRadius,
  });

  final double progress;
  final double stageSide;

  /// Final ring radius, from the short screen side.
  final double maxRadius;

  @override
  Widget build(BuildContext context) {
    if (progress <= 0) return const SizedBox.shrink();

    final baseRadius =
        SplashLayoutRatios.shockwaveBaseRadiusOfLogoWidth *
        SplashLayoutRatios.logoWidthOfStage *
        stageSide;
    final scale = lerpDouble(1.0, maxRadius / baseRadius, progress)!;
    final opacity = lerpDouble(
      SplashAnimationConstants.shockwaveInitialOpacity,
      0.0,
      Curves.easeOutCubic.transform(progress),
    )!;

    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: baseRadius * 2,
          height: baseRadius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: context.colors.primary,
              width: SplashLayoutRatios.shockwaveStrokeOfStage * stageSide,
            ),
          ),
        ),
      ),
    );
  }
}
