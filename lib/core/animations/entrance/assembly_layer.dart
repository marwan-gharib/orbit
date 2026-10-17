import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../tokens/app_curves.dart';

/// The assembly transform shared by layered artwork: a layer starts
/// displaced by [from] (fractions of the child's size, LTR space — mirror the
/// parent stack for RTL), rotated [fromDegrees], and scaled [fromScale] /
/// [fromScaleY] about [pivot], settling to identity at the window's end.
///
/// Purely progress-driven — no controller inside. The caller supplies the
/// window [begin]/[end] and the current [progress]; rebuilds redraw the
/// frame. Opacity is not applied here: pipelines that composite one opacity
/// node over a transform chain (tests key on that node) apply it once at the
/// top, using the same [begin]/[end] window.
///
/// Position easing follows [curve]; set [overshoot] to ease the position with
/// a spring ([AppCurves.spring]) instead, for a small settle bounce.
///
/// ```dart
/// AssemblyLayer(
///   progress: state.entranceProgress,
///   begin: 0.4,
///   end: 0.7,
///   from: Offset(0, 0.06),
///   child: const ArtworkLayer(),
/// )
/// ```
class AssemblyLayer extends StatelessWidget {
  const AssemblyLayer({
    super.key,
    required this.progress,
    required this.begin,
    required this.end,
    this.curve = AppCurves.enter,
    this.from = Offset.zero,
    this.fromDegrees = 0.0,
    this.fromScale = 1.0,
    this.fromScaleY = 1.0,
    this.pivot = Alignment.center,
    this.overshoot = false,
    required this.child,
  }) : assert(begin <= end);

  /// Current entrance progress; the layer is at rest at 1.
  final double progress;

  /// Window in progress: fully before [begin], complete at [end].
  final double begin;
  final double end;

  /// Easing of the position; the default is the entrance curve.
  final Curve curve;

  /// Start displacement as fractions of the child's size.
  final Offset from;

  /// Start rotation in degrees, settling to zero.
  final double fromDegrees;

  /// Start uniform scale, settling to 1.
  final double fromScale;

  /// Start vertical scale (bars growing from a baseline), settling to 1.
  /// Applies independently of [fromScale]; 1.0 keeps the height.
  final double fromScaleY;

  /// Origin of the rotation and both scales, in the child's alignment space.
  final Alignment pivot;

  /// Eases the position with [AppCurves.spring] instead of [curve].
  final bool overshoot;

  /// The subtree that assembles in.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final span = end - begin;
    final raw = span <= 0
        ? (progress >= end ? 1.0 : 0.0)
        : ((progress - begin) / span).clamp(0.0, 1.0);
    final positionEased = overshoot
        ? AppCurves.spring.transform(raw)
        : curve.transform(raw);
    final remaining = 1.0 - positionEased;

    Widget layer = child;
    if (fromScaleY != 1.0) {
      layer = Transform.scale(
        scaleY: fromScaleY + (1.0 - fromScaleY) * curve.transform(raw),
        alignment: pivot,
        child: layer,
      );
    }
    if (fromScale != 1.0) {
      layer = Transform.scale(
        scale: fromScale + (1.0 - fromScale) * positionEased,
        alignment: pivot,
        child: layer,
      );
    }
    if (fromDegrees != 0.0) {
      layer = Transform.rotate(
        angle: fromDegrees * remaining * math.pi / 180,
        alignment: pivot,
        child: layer,
      );
    }
    if (from != Offset.zero) {
      layer = FractionalTranslation(
        translation: Offset(from.dx * remaining, from.dy * remaining),
        child: layer,
      );
    }
    return layer;
  }
}
