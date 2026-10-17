import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:orbit/core/animations/animations.dart';
import 'package:orbit/features/onboarding/presentation/constants/onboarding_illustration_constants.dart';

/// Eased progress (0..1) of one entrance window at progress [p].
double _windowEased(double p, double begin, double end, Curve curve) =>
    curve.transform(((p - begin) / (end - begin)).clamp(0.0, 1.0));

/// Linear progress (0..1) of one entrance window at progress [p].
double _windowLinear(double p, double begin, double end) =>
    ((p - begin) / (end - begin)).clamp(0.0, 1.0);

/// Point on the cubic bezier `p0 → p3` at [t] (0..1).
Offset _cubicAt(Offset p0, Offset p1, Offset p2, Offset p3, double t) {
  final u = 1 - t;
  final a = u * u * u;
  final b = 3 * u * u * t;
  final c = 3 * u * t * t;
  final d = t * t * t;
  return Offset(
    a * p0.dx + b * p1.dx + c * p2.dx + d * p3.dx,
    a * p0.dy + b * p1.dy + c * p2.dy + d * p3.dy,
  );
}

/// How one illustration layer animates during the slide's entrance
/// (progress 0.0 → 1.0). A subclass owns its per-frame math; shapes shared
/// with the core [AssemblyLayer] and [ClipReveal] widgets delegate to them,
/// and every numeric value is injected from the feature's constants, so
/// motion never introduces a literal into the widget tree (H-10).
sealed class EntranceMotion {
  const EntranceMotion({
    required this.begin,
    required this.end,
    this.curve = AppCurves.enter,
  });

  /// Window in entrance progress: fully before [begin], complete at [end].
  final double begin;
  final double end;

  /// Easing applied inside the window.
  final Curve curve;

  /// Linear progress of the window at [p].
  double rawAt(double p) => _windowLinear(p, begin, end);

  /// Eased progress of the window at [p].
  double easedAt(double p) => _windowEased(p, begin, end, curve);

  /// Opacity multiplier at entrance progress [p]. Motions that only clip or
  /// travel stay fully opaque.
  double opacityAt(double p) => 1.0;

  /// Wraps [child] with this motion's transform/clip at [p] for a square of
  /// [side] logical pixels. Opacity is applied once per layer by the stage.
  Widget decorate(Widget child, {required double p, required double side}) =>
      child;
}

/// Fade in over the window.
final class FadeInMotion extends EntranceMotion {
  const FadeInMotion({required super.begin, required super.end, super.curve});

  @override
  double opacityAt(double p) => easedAt(p);
}

/// Fade in + vertical growth (scaleY 0 → 1) about [pivot]; used by the
/// dashboard bars growing up from their baseline.
final class FadeScaleYMotion extends EntranceMotion {
  const FadeScaleYMotion({
    required super.begin,
    required super.end,
    super.curve,
    required this.pivot,
  });

  final Alignment pivot;

  @override
  double opacityAt(double p) => easedAt(p);

  @override
  Widget decorate(Widget child, {required double p, required double side}) {
    return AssemblyLayer(
      progress: p,
      begin: begin,
      end: end,
      curve: curve,
      fromScaleY: 0.0,
      pivot: pivot,
      child: child,
    );
  }
}

/// Assembly entrance: the layer starts displaced by [from] (fractions of the
/// canvas side), rotated [fromDegrees] and scaled [fromScale] about [pivot],
/// assembling to identity at [end] through the shared [AssemblyLayer]. It
/// fades in over the first [assemblyFadeFraction] of its window; set
/// [overshoot] for a small springy settle, and [curve] shapes the fade-out
/// window only. When [opacityEnd] is set, opacity completes there while the
/// transform keeps easing until [end] (used by the stamp slam).
final class AssemblyMotion extends EntranceMotion {
  const AssemblyMotion({
    required super.begin,
    required super.end,
    super.curve,
    required this.from,
    required this.fromDegrees,
    required this.fromScale,
    required this.pivot,
    this.overshoot = false,
    this.opacityEnd,
    this.outBegin,
    this.outEnd,
  });

  /// Offset from the resting position, as fractions of the canvas side, in
  /// LTR space (the whole stack is mirrored in RTL).
  final Offset from;
  final double fromDegrees;
  final double fromScale;
  final Alignment pivot;
  final bool overshoot;

  /// Progress at which opacity finishes fading in; defaults to
  /// [begin] + [OnboardingIllustrationMotion.assemblyFadeFraction] of the
  /// window.
  final double? opacityEnd;

  /// When set, opacity fades back out over this independent window after
  /// fading in (used by the pending/approved pill swap). The settled frame is
  /// fully transparent for the copy that should disappear.
  final double? outBegin;
  final double? outEnd;

  @override
  double opacityAt(double p) {
    final fadeEnd =
        opacityEnd ??
        begin +
            OnboardingIllustrationMotion.assemblyFadeFraction * (end - begin);
    var opacity = AppCurves.enter.transform(
      ((p - begin) / (fadeEnd - begin)).clamp(0.0, 1.0),
    );
    if (outBegin != null && outEnd != null) {
      opacity *= 1 - _windowEased(p, outBegin!, outEnd!, curve);
    }
    return opacity;
  }

  @override
  Widget decorate(Widget child, {required double p, required double side}) {
    return AssemblyLayer(
      progress: p,
      begin: begin,
      end: end,
      from: from,
      fromDegrees: fromDegrees,
      fromScale: fromScale,
      pivot: pivot,
      overshoot: overshoot,
      child: child,
    );
  }
}

/// Crossfade of a swap pair: fades in over the primary window, out over
/// [outBegin]..[outEnd]. Both windows are independent, so the settled frame
/// is fully transparent for the copy that should disappear.
final class CrossfadeMotion extends EntranceMotion {
  const CrossfadeMotion({
    required super.begin,
    required super.end,
    super.curve,
    required this.outBegin,
    required this.outEnd,
  });

  final double outBegin;
  final double outEnd;

  @override
  double opacityAt(double p) =>
      easedAt(p) * (1 - _windowEased(p, outBegin, outEnd, curve));
}

/// Horizontal clip reveal: the content appears left to right between
/// [fromX] and [toX] (fractions of the side) through the shared [ClipReveal].
/// The clip is authored LTR and mirrors with the stack in RTL.
final class ClipRevealMotion extends EntranceMotion {
  const ClipRevealMotion({
    required super.begin,
    required super.end,
    super.curve,
    required this.fromX,
    required this.toX,
  });

  final double fromX;
  final double toX;

  @override
  Widget decorate(Widget child, {required double p, required double side}) {
    return ClipReveal(
      progress: p,
      begin: begin,
      end: end,
      fromX: fromX,
      toX: toX,
      curve: curve,
      child: child,
    );
  }
}

/// Ring-arc reveal: a sector clip around [center] grows the drawn arc from
/// nothing to the full [sweepDegrees] arc, keeping both round stroke caps
/// complete at the settled frame via [capAngleRadians].
final class SweepRevealMotion extends EntranceMotion {
  const SweepRevealMotion({
    required super.begin,
    required super.end,
    super.curve,
    required this.center,
    required this.radius,
    required this.startAngleDegrees,
    required this.sweepDegrees,
    required this.capAngleRadians,
  });

  final Offset center;
  final double radius;
  final double startAngleDegrees;
  final double sweepDegrees;
  final double capAngleRadians;

  @override
  Widget decorate(Widget child, {required double p, required double side}) {
    return ClipPath(
      clipper: _SweepClipper(
        progress: easedAt(p),
        center: Offset(center.dx * side, center.dy * side),
        radius: radius * side,
        startAngle: startAngleDegrees * math.pi / 180,
        sweepAngle: sweepDegrees * math.pi / 180,
        capAngle: capAngleRadians,
      ),
      child: child,
    );
  }
}

/// Moving element: fades in over the first [fadeFraction] of the window,
/// travels from [from] to rest with the window's easing curve and swells to
/// [liftScale] at mid-travel.
final class TravelRevealMotion extends EntranceMotion {
  const TravelRevealMotion({
    required super.begin,
    required super.end,
    super.curve = AppCurves.travel,
    required this.from,
    required this.fadeFraction,
    required this.liftScale,
    required this.pivot,
  });

  final Offset from;
  final double fadeFraction;
  final double liftScale;
  final Alignment pivot;

  @override
  double opacityAt(double p) =>
      AppCurves.enter.transform((rawAt(p) / fadeFraction).clamp(0.0, 1.0));

  @override
  Widget decorate(Widget child, {required double p, required double side}) {
    final remaining = 1 - easedAt(p);
    final lift = 1 + (liftScale - 1) * math.sin(math.pi * rawAt(p));
    return Transform.translate(
      offset: Offset(from.dx * remaining * side, from.dy * remaining * side),
      child: Transform.scale(scale: lift, alignment: pivot, child: child),
    );
  }
}

/// Dot that travels along the cubic bezier `p0 → p3` and fades at both ends,
/// leaving the settled frame empty.
final class BezierTravelMotion extends EntranceMotion {
  const BezierTravelMotion({
    required super.begin,
    required super.end,
    super.curve = AppCurves.travel,
    required this.outBegin,
    required this.outEnd,
    required this.p0,
    required this.p1,
    required this.p2,
    required this.p3,
  });

  final double outBegin;
  final double outEnd;
  final Offset p0;
  final Offset p1;
  final Offset p2;
  final Offset p3;

  @override
  double opacityAt(double p) =>
      easedAt(p) * (1 - _windowEased(p, outBegin, outEnd, curve));

  @override
  Widget decorate(Widget child, {required double p, required double side}) {
    final point = _cubicAt(p0, p1, p2, p3, easedAt(p));
    return Transform.translate(
      offset: Offset((point.dx - p0.dx) * side, (point.dy - p0.dy) * side),
      child: child,
    );
  }
}

/// No entrance: the layer stays hidden until an idle loop reveals it (pulse
/// rings, the flow dot at rest, the alert pulse).
final class HiddenEntranceMotion extends EntranceMotion {
  const HiddenEntranceMotion() : super(begin: 0, end: 1);

  @override
  double opacityAt(double p) => 0;
}

/// A looping motion of one layer, running only while the slide is the active
/// settled page, through the shared [IdleLoop]. Idle frames wrap outside the
/// settled entrance frame; an idle that owns the layer's fade turns the keyed
/// opacity root over to 1.0 and fades inside its own loop frame instead.
sealed class LayerIdle {
  const LayerIdle({required this.period});

  /// One full loop.
  final Duration period;

  /// Whether the idle owns the layer's opacity while it runs.
  bool get ownsOpacity => false;

  /// Wraps [child] with the loop's per-frame widget for a square of [side]
  /// logical pixels. A stopped loop holds the settled frame.
  Widget decorate(Widget child, {required bool active, required double side});
}

/// Gentle breathing scale between 1 and [scaleTo] about [pivot]: one leg out
/// and back down per full period (a reverse oscillator).
final class BreatheIdle extends LayerIdle {
  const BreatheIdle({
    required super.period,
    required this.scaleTo,
    required this.pivot,
  });

  final double scaleTo;
  final Alignment pivot;

  @override
  Widget decorate(Widget child, {required bool active, required double side}) {
    return IdleLoop(
      active: active,
      period: period,
      scaleTo: scaleTo,
      pivot: pivot,
      reverse: true,
      child: child,
    );
  }
}

/// Radar pulse: the layer expands to [scaleTo] while fading to fully
/// transparent, then restarts. [phaseOffset] starts the loop partway through
/// its cycle (0..1 of the period), so a second copy of the ring moves out of
/// step.
final class PulseIdle extends LayerIdle {
  const PulseIdle({
    required super.period,
    required this.scaleTo,
    required this.pivot,
    this.phaseOffset = 0,
    this.curve = AppCurves.pulse,
  });

  final double scaleTo;
  final Alignment pivot;
  final double phaseOffset;
  final Curve curve;

  @override
  bool get ownsOpacity => true;

  @override
  Widget decorate(Widget child, {required bool active, required double side}) {
    return IdleLoop(
      active: active,
      period: period,
      scaleTo: scaleTo,
      pivot: pivot,
      phase: phaseOffset,
      curve: curve,
      opacityTo: 0.0,
      child: child,
    );
  }
}

/// Bob: drifts by [amplitudeOfSide] (fractions of the side) up and back down
/// around the settled spot, one leg per half period. The shape is a triangle,
/// not a sine wave.
final class FloatIdle extends LayerIdle {
  const FloatIdle({required super.period, required this.amplitudeOfSide});

  final double amplitudeOfSide;

  @override
  Widget decorate(Widget child, {required bool active, required double side}) {
    return IdleLoop(
      active: active,
      period: period,
      translateTo: Offset(0, amplitudeOfSide),
      reverse: true,
      child: child,
    );
  }
}

/// Travel loop: the dot moves along the cubic bezier `p0 → p3`, fading in and
/// out at the ends, then hides for the tail of the period ([pauseFraction]);
/// runs on an [IdleLoop] raw-phase clock.
final class TravelLoopIdle extends LayerIdle {
  const TravelLoopIdle({
    required super.period,
    required this.pauseFraction,
    required this.fadeFraction,
    required this.p0,
    required this.p1,
    required this.p2,
    required this.p3,
    this.curve = AppCurves.travel,
  });

  final double pauseFraction;
  final double fadeFraction;
  final Offset p0;
  final Offset p1;
  final Offset p2;
  final Offset p3;
  final Curve curve;

  @override
  bool get ownsOpacity => true;

  @override
  Widget decorate(Widget child, {required bool active, required double side}) {
    return IdleLoop(
      active: active,
      period: period,
      phaseBuilder: (context, phase, child) => Opacity(
        opacity: _opacityAt(phase),
        child: Transform.translate(
          offset: _translationAt(phase, side),
          child: child,
        ),
      ),
      child: child,
    );
  }

  /// Opacity at loop [phase]: ramps in and out over [fadeFraction] at the
  /// travel leg's ends, curve-shaped.
  double _opacityAt(double phase) {
    final ramp =
        (math.min(_travelPhase(phase), 1 - _travelPhase(phase)) / fadeFraction)
            .clamp(0.0, 1.0);
    return curve.transform(ramp);
  }

  Offset _translationAt(double phase, double side) {
    final point = _cubicAt(
      p0,
      p1,
      p2,
      p3,
      curve.transform(_travelPhase(phase)),
    );
    return Offset((point.dx - p0.dx) * side, (point.dy - p0.dy) * side);
  }

  /// Travel progress: 1.0 during the pause tail (dot parked at the end,
  /// invisible through [_opacityAt]).
  double _travelPhase(double phase) {
    final activeFraction = 1 - pauseFraction;
    return phase >= activeFraction ? 1.0 : phase / activeFraction;
  }
}

class _SweepClipper extends CustomClipper<Path> {
  const _SweepClipper({
    required this.progress,
    required this.center,
    required this.radius,
    required this.startAngle,
    required this.sweepAngle,
    required this.capAngle,
  });

  final double progress;
  final Offset center;
  final double radius;
  final double startAngle;
  final double sweepAngle;
  final double capAngle;

  @override
  Path getClip(Size size) {
    // Both edges carry the cap padding, ramped by [progress]: at 0 the sector
    // is empty, at 1 it includes the full round caps at both ends.
    final start = startAngle - capAngle * progress;
    final sweep = (sweepAngle + 2 * capAngle) * progress;
    return Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        false,
      )
      ..close();
  }

  @override
  bool shouldReclip(covariant _SweepClipper old) =>
      old.progress != progress ||
      old.center != center ||
      old.radius != radius ||
      old.startAngle != startAngle ||
      old.sweepAngle != sweepAngle ||
      old.capAngle != capAngle;
}
