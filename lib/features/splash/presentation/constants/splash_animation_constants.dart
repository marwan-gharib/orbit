import 'package:flutter/animation.dart';

/// Animation timeline constants for the splash feature.
/// All values in milliseconds. Total duration: 4000ms.
/// Driven by a single AnimationController with Interval phases.
abstract final class SplashAnimationConstants {
  /// Total splash duration in milliseconds.
  static const int totalDurationMs = 4000;

  /// Phase 1: Stage setup (0-500ms)
  static const int stageSetupStartMs = 0;
  static const int stageSetupEndMs = 500;
  static const int radialGlowStartMs = 0;
  static const int radialGlowEndMs = 500;
  static const int orbitRingsDrawStartMs = 100;
  static const int orbitRingsDrawEndMs = 500;

  /// Phase 2: Logo reveal hero moment (300-1400ms)
  static const int logoRevealStartMs = 300;
  static const int logoRevealEndMs = 1400;
  static const int shockwaveStartMs = 800;
  static const int shockwaveEndMs = 1000;

  /// Phase 3: Module nodes orbit (500-2600ms)
  static const int moduleNodesStartMs = 500;
  static const int moduleNodesEndMs = 2600;

  /// Phase 4: Light sweep (1400-2200ms)
  static const int lightSweepStartMs = 1400;
  static const int lightSweepEndMs = 2200;

  /// Phase 5: Tagline reveal (1300-2700ms)
  static const int taglineStartMs = 1300;
  static const int taglineEndMs = 2700;

  /// Phase 6: Module keywords (1800-3100ms)
  static const int moduleKeywordsStartMs = 1800;
  static const int moduleKeywordsEndMs = 3100;

  /// Phase 7: Convergence / lock-in (2600-3300ms)
  static const int convergenceStartMs = 2600;
  static const int convergenceEndMs = 3300;

  /// Phase 8: Hold / breathing moment (3300-3600ms)
  static const int holdStartMs = 3300;
  static const int holdEndMs = 3600;

  /// Phase 9: Exit transition (3600-4000ms)
  static const int exitStartMs = 3600;
  static const int exitEndMs = 4000;

  /// Reduced motion: how long the static final frame is held before the
  /// screen reports the animation complete.
  static const int reducedMotionHoldMs = 500;

  /// Converts milliseconds to an Interval for a 4000ms controller.
  static Interval interval(int startMs, int endMs) =>
      Interval(startMs / totalDurationMs, endMs / totalDurationMs);

  /// Number of module nodes (one per module).
  static const int moduleNodeCount = 5;

  /// Comet trail history length (points per node).
  static const int trailHistoryLength = 12;

  /// Logo initial scale for reveal animation.
  static const double logoInitialScale = 0.6;

  /// Logo overshoot peak scale.
  static const double logoOvershootScale = 1.05;

  /// Logo final scale.
  static const double logoFinalScale = 1.0;

  /// Logo initial rotation (degrees).
  static const double logoInitialRotationDegrees = -5.0;

  /// Blur sigma start value.
  static const double blurSigmaStart = 8.0;

  /// Blur sigma end value (sharp).
  static const double blurSigmaEnd = 0.0;

  /// Shockwave max scale.
  static const double shockwaveMaxScale = 2.0;

  /// Shockwave initial opacity.
  static const double shockwaveInitialOpacity = 0.3;

  /// Hold phase pulse scale.
  static const double holdPulseScale = 1.02;

  /// Exit phase scale.
  static const double exitScale = 1.04;

  /// Tagline word stagger delay (ms per word).
  static const int taglineWordStaggerMs = 180;

  /// Tagline word slide-up distance, in layout units at full reveal.
  static const double taglineWordRiseOffset = 30.0;

  /// Module keyword stagger delay (ms per keyword).
  static const int moduleKeywordStaggerMs = 250;

  /// Module keyword rise distance, in layout units at full reveal.
  static const double moduleKeywordRiseOffset = 10.0;

  /// Index of the emphasized tagline word ("orbit.") in `splash.taglineWords`.
  static const int taglineEmphasizedWordIndex = 5;
}
