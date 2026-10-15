import 'package:flutter/widgets.dart';

import '../tokens/app_curves.dart';
import '../tokens/app_durations.dart';

/// Builds the animated body of an [Entrance].
///
/// [drive] runs 0..1 with the entrance's delay and curve already applied.
/// [child] is the entrance's child and must be passed straight through so
/// the subtree is built once instead of on every animation tick.
typedef EntranceTransitionBuilder = Widget Function(
  BuildContext context,
  Animation<double> drive,
  Widget child,
);

/// Shared engine behind [FadeIn], [SlideIn], [ScaleIn], [FadeSlideIn] and
/// [BlurIn]; prefer those typed wrappers, use this only for a custom
/// transition.
///
/// Plays exactly one forward animation, starting with the first build: the
/// start value is held for [delay], then [transition] animates for
/// [duration]. The delay is an [Interval] on the controller's own timeline,
/// so no timer is ever scheduled and disposal cannot strand one. When
/// `MediaQuery.disableAnimations` is true the controller is moved to its end
/// value before the first frame, so the final state renders immediately.
///
/// ```dart
/// Entrance(
///   delay: AppDurations.stagger,
///   duration: AppDurations.fast,
///   transition: (context, drive, child) =>
///       FadeTransition(opacity: drive, child: child),
///   child: child,
/// )
/// ```
class Entrance extends StatefulWidget {
  const Entrance({
    super.key,
    this.delay = Duration.zero,
    this.duration = AppDurations.normal,
    this.curve = AppCurves.enter,
    required this.transition,
    required this.child,
  });

  /// How long the start value is held before the animation begins.
  final Duration delay;

  /// Length of the visible transition, excluding [delay].
  final Duration duration;

  /// Easing applied once [delay] has passed.
  final Curve curve;

  /// The transition body; see [EntranceTransitionBuilder].
  final EntranceTransitionBuilder transition;

  /// The subtree animated by [transition]; never rebuilt by the animation.
  final Widget child;

  @override
  State<Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<Entrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _drive;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _total);
    _drive = _controller.drive(CurveTween(curve: _delayedCurve));
  }

  Duration get _total => widget.delay + widget.duration;

  Curve get _delayedCurve {
    // A zero duration would make the interval start at 1.0 and divide by
    // zero; the plain curve over `delay + duration` is the sane degenerate.
    if (widget.delay <= Duration.zero || widget.duration <= Duration.zero) {
      return widget.curve;
    }
    final start = widget.delay.inMicroseconds / _total.inMicroseconds;
    return Interval(start, 1.0, curve: widget.curve);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1.0;
    } else if (_controller.status == AnimationStatus.dismissed) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant Entrance oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.delay == oldWidget.delay &&
        widget.duration == oldWidget.duration &&
        widget.curve == oldWidget.curve) {
      return;
    }
    _controller.duration = _total;
    _drive = _controller.drive(CurveTween(curve: _delayedCurve));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      widget.transition(context, _drive, widget.child);
}
