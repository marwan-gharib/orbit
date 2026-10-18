import 'package:flutter/material.dart';

import 'package:orbit/core/animations/tokens/app_animation_constants.dart';
import 'package:orbit/core/animations/tokens/app_curves.dart';
import 'package:orbit/core/animations/tokens/app_durations.dart';

/// Animation timing constants for the onboarding feature.
/// Every value is derived from shared tokens via [static final] arithmetic
/// (Duration operators are not const-evaluable); only token references,
/// plain doubles and [Duration.zero] stay const.
abstract final class OnboardingAnimationTimings {
  /// Total duration of a slide's entrance choreography: two emphasised
  /// beats plus a two-stagger tail (500·2 + 50·2 = 1100 ms).
  static final Duration entranceTotal =
      AppDurations.slow * 2 + AppDurations.stagger * 2;

  /// Headline reveal duration (masked slide-up + fade):
  /// one standard beat plus a two-stagger tail (300 + 50·2 = 400 ms).
  static final Duration headlineReveal =
      AppDurations.normal + AppDurations.stagger * 2;

  /// Body reveal duration (fade + slide up):
  /// one standard beat plus a stagger tail (300 + 50 = 350 ms).
  static final Duration bodyReveal = AppDurations.normal + AppDurations.stagger;

  /// Standard entrance easing.
  static const Curve entranceCurve = AppCurves.enter;

  /// Spring feel for morphing elements (indicator, button).
  static const Curve springCurve = AppCurves.spring;

  /// Skip button hide/show animation.
  static final Duration skipTransition = AppDurations.fast;

  /// Primary button morph (Next → Get Started).
  static final Duration buttonMorph = AppDurations.normal;

  /// Page indicator morph (dot → pill).
  static final Duration indicatorMorph = AppDurations.normal;

  /// Parallax background interpolation factor.
  static const double parallaxFactor =
      AppAnimationConstants.parallaxDefaultFactor;

  /// Total duration of one illustration entrance (the assembly choreography):
  /// three emphasised beats (500·3 = 1500 ms). Plays when a slide becomes the
  /// current page; intentionally longer than the page transition so the
  /// pieces can settle before the user swipes on.
  static final Duration illustrationEntranceDuration = AppDurations.slow * 3;

  /// Delay after a slide becomes current before its illustration entrance
  /// starts, so the screen's own first-load animation finishes first
  /// (one standard beat, 300 ms).
  static final Duration illustrationEntranceDelay = AppDurations.normal;

  /// Share of [illustrationEntranceDuration] spent in the named delay before
  /// the assembly begins (300 ms / 1500 ms). Kept as a fraction so tests can
  /// drive it with simulated time instead of real-time delays.
  static const double illustrationEntranceDelayFraction = 0.2;

  /// First-load screen entrance delays.
  static const Duration topBarDelay = Duration.zero;
  static final Duration bottomBarDelay = AppDurations.stagger * 2;

  /// Inner entrance window of the top bar: the old `Interval(0.0, 0.6)` on
  /// the [AppDurations.normal] screen timeline, as a delay plus its closure
  /// duration.
  static const Duration topBarInnerDelay = Duration.zero;
  static final Duration topBarInnerDuration = AppDurations.normal * 0.6;

  /// Inner entrance window of the bottom block: the old `Interval(0.2, 0.8)`
  /// on the [AppDurations.normal] screen timeline, as a delay plus its
  /// closure duration.
  static final Duration bottomBarInnerDelay = AppDurations.normal * 0.2;
  static final Duration bottomBarInnerDuration = AppDurations.normal * 0.6;

  /// Exit transition duration (route fadeThrough).
  static final Duration exitTransition = AppDurations.normal;
}
