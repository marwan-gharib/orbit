import 'package:flutter/widgets.dart';

import '../tokens/app_animation_constants.dart';
import '../tokens/app_curves.dart';
import '../tokens/app_durations.dart';

/// Programmatic trigger for a [BounceWidget]; call [bounce] to play it.
///
/// ```dart
/// final bounce = BounceController();
/// // ...
/// BounceWidget(controller: bounce, child: child)
/// bounce.bounce();
/// ```
class BounceController {
  VoidCallback? _play;

  /// Plays the attached [BounceWidget]; no-op while none is mounted.
  void bounce() => _play?.call();

  void _attach(VoidCallback play) {
    _play = play;
  }

  void _detach() {
    _play = null;
  }
}

/// Plays a one-shot scale bounce on [child] — a new row landing in a list, a
/// counter ticking up.
///
/// Fire it either way: hold a [BounceController] and call `controller.bounce()`
/// (e.g. from a `BlocListener`), or pass [trigger] and increment the counter
/// in Cubit state. The pop rises with [AppCurves.enter] and lands with
/// [AppCurves.bounce], resting exactly at scale 1.0. With
/// `MediaQuery.disableAnimations` the motion is skipped and the child renders
/// at rest.
///
/// ```dart
/// BounceWidget(
///   trigger: state.addedCount,
///   child: child,
/// )
/// ```
class BounceWidget extends StatefulWidget {
  const BounceWidget({
    super.key,
    required this.child,
    this.trigger = 0,
    this.controller,
    this.duration = AppDurations.normal,
  });

  /// Increment this counter to fire the bounce (e.g. from a Cubit state).
  final int trigger;

  /// Alternative programmatic trigger; fires independently of [trigger].
  final BounceController? controller;

  /// Length of the whole bounce (rise plus settle).
  final Duration duration;

  /// The subtree that bounces; never rebuilt by the animation.
  final Widget child;

  @override
  State<BounceWidget> createState() => _BounceWidgetState();
}

class _BounceWidgetState extends State<BounceWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _bounce;
  late bool _disableAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _bounce = TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 1.0,
          end: AppAnimationConstants.bounceScale,
        ).chain(CurveTween(curve: AppCurves.enter)),
        weight: AppAnimationConstants.bounceRiseWeight,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: AppAnimationConstants.bounceScale,
          end: 1.0,
        ).chain(CurveTween(curve: AppCurves.bounce)),
        weight: AppAnimationConstants.bounceSettleWeight,
      ),
    ]).animate(_controller);
    widget.controller?._attach(_play);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _disableAnimations = MediaQuery.disableAnimationsOf(context);
  }

  @override
  void didUpdateWidget(covariant BounceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
    }
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?._detach();
      widget.controller?._attach(_play);
    }
    if (widget.trigger != oldWidget.trigger) {
      _play();
    }
  }

  @override
  void dispose() {
    widget.controller?._detach();
    _controller.dispose();
    super.dispose();
  }

  void _play() {
    if (_disableAnimations) return;
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) =>
      ScaleTransition(scale: _bounce, child: widget.child);
}
