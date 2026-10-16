import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:orbit/core/responsive/responsive.dart';

/// Named layout ratios for the splash composition. Every size in the splash
/// is expressed as a fraction of the screen (`W`/`H`/`short = min(W, H)`) or
/// of the stage side `S` — never in raw pixels.
abstract final class SplashLayoutRatios {
  /// Stage side `S = min(stageOfShortSide * short, stageOfHeight * H,
  /// SplashLayout.stageMaxSide)`.
  static const double stageOfShortSide = 0.80;
  static const double stageOfHeight = 0.45;

  /// Logo box width as a fraction of `S`; height follows the image aspect.
  static const double logoWidthOfStage = 0.55;

  /// Background glow radius, capped as a fraction of `short`.
  static const double glowRadiusOfShortSide = 0.60;

  /// Shockwave ring: starts at the logo edge and expands toward `short`.
  static const double shockwaveBaseRadiusOfLogoWidth = 0.6;
  static const double shockwaveMaxRadiusOfShortSide = 0.5;
  static const double shockwaveStrokeOfStage = 0.007;

  /// Orbit ring 1: semi-major axis, minor/major ratio, tilt.
  static const double ring1SemiMajorOfStage = 0.46;
  static const double ring1MinorMajorRatio = 0.42;
  static const double ring1TiltRadians = -20 * math.pi / 180;

  /// Orbit ring 2: semi-major axis, minor/major ratio, tilt.
  static const double ring2SemiMajorOfStage = 0.36;
  static const double ring2MinorMajorRatio = 0.50;
  static const double ring2TiltRadians = 25 * math.pi / 180;

  static const double ringStrokeOfStage = 0.006;

  /// Module node geometry as fractions of `S` (body radius, glow radius,
  /// comet-trail stroke).
  static const double nodeRadiusOfStage = 0.025;
  static const double nodeGlowRadiusOfStage = 0.038;
  static const double nodeTrailStrokeOfStage = 0.007;

  /// Per-node orbit shapes (semi-major, semi-minor, tilt radians) as
  /// fractions of `S` — same proportions as the original design, scaled.
  static const List<({double a, double b, double tilt})> nodeOrbits = [
    (a: 0.46, b: 0.33, tilt: 0.3),
    (a: 0.36, b: 0.26, tilt: -0.2),
    (a: 0.30, b: 0.23, tilt: 0.4),
    (a: 0.40, b: 0.30, tilt: -0.1),
    (a: 0.33, b: 0.25, tilt: 0.25),
  ];

  /// Convergence lock-in ring: final radius, spiral start radius and step,
  /// lock-in node diameter, and the lock-in node glow (blur/spread) — all
  /// fractions of `S`.
  static const double lockInRadiusOfStage = 0.40;
  static const double lockInStartRadiusOfStage = 0.46;
  static const double lockInStartRadiusStepOfStage = 0.033;
  static const double lockInNodeDiameterOfStage = 0.05;
  static const double lockInGlowBlurOfStage = 0.0286;
  static const double lockInGlowSpreadOfStage = 0.0071;

  /// Vertical rhythm (gaps as fractions of `H`) and text block width
  /// (fraction of `W`).
  static const double stageToTaglineGapOfHeight = 0.03;
  static const double taglineToKeywordsGapOfHeight = 0.02;
  static const double contentMaxWidthOfWidth = 0.80;
}

/// Single source of truth for splash layout sizes. Derived from the current
/// screen through [SplashLayoutRatios]; the composition positions every
/// element from these values only, so animation progress never moves or
/// resizes layout.
@immutable
class SplashLayout {
  const SplashLayout({required this.screenSize, required this.stageSide});

  factory SplashLayout.fromScreen(Size screenSize) {
    final stageSide = math.min(
      math.min(
        SplashLayoutRatios.stageOfShortSide * screenSize.shortestSide,
        SplashLayoutRatios.stageOfHeight * screenSize.height,
      ),
      stageMaxSide,
    );
    return SplashLayout(screenSize: screenSize, stageSide: stageSide);
  }

  /// Large-screen bound for the stage: the design baseline's short side run
  /// through `Responsive.adapt`, whose clamped scale (max 1.30) is the
  /// project's tablet/large-screen bound, so the stage cannot balloon on
  /// tablets while phones stay untouched.
  static double get stageMaxSide =>
      Responsive.adapt(Responsive.designSize.shortestSide);

  final Size screenSize;
  final double stageSide;

  double get shortestSide => screenSize.shortestSide;

  double get logoWidth => SplashLayoutRatios.logoWidthOfStage * stageSide;

  double get glowMaxRadius =>
      SplashLayoutRatios.glowRadiusOfShortSide * shortestSide;

  double get shockwaveMaxRadius =>
      SplashLayoutRatios.shockwaveMaxRadiusOfShortSide * shortestSide;

  double get contentMaxWidth =>
      SplashLayoutRatios.contentMaxWidthOfWidth * screenSize.width;

  double get stageToTaglineGap =>
      SplashLayoutRatios.stageToTaglineGapOfHeight * screenSize.height;

  double get taglineToKeywordsGap =>
      SplashLayoutRatios.taglineToKeywordsGapOfHeight * screenSize.height;
}
