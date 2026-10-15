import 'package:flutter/widgets.dart';

import '../tokens/app_animation_constants.dart';
import '../tokens/app_curves.dart';
import '../tokens/app_durations.dart';
import 'entrance.dart';

/// Slides [child] in from one edge, once, on its first build; rebuilds do
/// not replay it.
///
/// [delay], [duration] and [curve] behave as in [Entrance]. [offset] is the
/// begin offset as a fraction of the child's size; the `fromStart`/`fromEnd`
/// variants mirror it when the direction is RTL.
///
/// ```dart
/// SlideIn.fromBottom(
///   child: const Card(child: SizedBox(height: 120)),
/// )
///
/// SlideIn.fromStart(
///   offset: const Offset(-0.25, 0), // comes from further out
///   child: const DrawerPanel(),
/// )
/// ```
class SlideIn extends StatelessWidget {
  /// Enters from the top edge, moving downward into place.
  const SlideIn.fromTop({
    super.key,
    this.delay = Duration.zero,
    this.duration = AppDurations.normal,
    this.curve = AppCurves.enter,
    this.offset = AppAnimationConstants.slideFromTop,
    required this.child,
  }) : _mirrorX = false;

  /// Enters from the bottom edge, moving upward into place.
  const SlideIn.fromBottom({
    super.key,
    this.delay = Duration.zero,
    this.duration = AppDurations.normal,
    this.curve = AppCurves.enter,
    this.offset = AppAnimationConstants.slideFromBottom,
    required this.child,
  }) : _mirrorX = false;

  /// Enters from the leading edge (left in LTR, right in RTL).
  const SlideIn.fromStart({
    super.key,
    this.delay = Duration.zero,
    this.duration = AppDurations.normal,
    this.curve = AppCurves.enter,
    this.offset = AppAnimationConstants.slideFromStart,
    required this.child,
  }) : _mirrorX = true;

  /// Enters from the trailing edge (right in LTR, left in RTL).
  const SlideIn.fromEnd({
    super.key,
    this.delay = Duration.zero,
    this.duration = AppDurations.normal,
    this.curve = AppCurves.enter,
    this.offset = AppAnimationConstants.slideFromEnd,
    required this.child,
  }) : _mirrorX = true;

  /// Hold time before the slide starts.
  final Duration delay;

  /// Length of the slide, excluding [delay].
  final Duration duration;

  /// Easing of the slide.
  final Curve curve;

  /// Begin offset as a fraction of the child's size, in LTR space.
  final Offset offset;

  /// The subtree that slides in; never rebuilt by the animation.
  final Widget child;

  /// Whether the horizontal component follows the text direction.
  final bool _mirrorX;

  @override
  Widget build(BuildContext context) => Entrance(
    delay: delay,
    duration: duration,
    curve: curve,
    transition: (context, drive, child) {
      final bool mirrored =
          _mirrorX && Directionality.of(context) == TextDirection.rtl;
      final begin = mirrored ? Offset(-offset.dx, offset.dy) : offset;
      return SlideTransition(
        position: drive.drive(Tween<Offset>(begin: begin, end: Offset.zero)),
        child: child,
      );
    },
    child: child,
  );
}
