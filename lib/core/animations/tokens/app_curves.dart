import 'package:flutter/animation.dart';

/// Curve tokens for every animation in Orbit.
///
/// Widgets never hardcode a [Curve]; they read it from here so easing stays
/// consistent across features.
abstract final class AppCurves {
  /// Material standard easing for general-purpose motion inside a screen.
  static const Curve standard = Cubic(0.2, 0.0, 0.0, 1.0);

  /// Decelerating curve for content that enters the screen (entrances).
  static const Curve enter = Curves.easeOutCubic;

  /// Accelerating curve for content that leaves the screen (exits).
  static const Curve exit = Curves.easeInCubic;

  /// Playful bounce for celebratory moments. Opt-in; never a default.
  static const Curve bounce = Curves.bounceOut;

  /// Single gentle overshoot: spring feel without a physics simulation.
  static const Curve spring = Curves.easeOutBack;

  /// Travel of an element from one resting spot to another: starts and ends
  /// at rest, so the move reads as one connected motion.
  static const Curve travel = Curves.easeInOutCubic;

  /// No easing. For looping sweeps and travels that must keep a constant
  /// speed, so a repeating cycle never hitches at its seams.
  static const Curve linear = Curves.linear;

  /// Symmetric in-and-out rhythm for placeholders that fade between two
  /// opacities; the reverse leg mirrors the forward one.
  static const Curve pulse = Curves.easeInOut;
}
