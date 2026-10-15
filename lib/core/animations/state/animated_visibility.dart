import 'package:flutter/widgets.dart';

import '../tokens/app_curves.dart';
import '../tokens/app_durations.dart';

/// Shows or hides [child] with a fade plus an animated height, so nothing
/// pops into or out of the layout.
///
/// ```dart
/// AnimatedVisibility(
///   visible: state.showBanner,
///   child: const PromoBanner(),
/// )
/// ```
///
/// The animation plays only when [visible] changes; a child that is visible
/// on first build appears right away (for a one-shot entrance use [FadeIn]
/// or [ScaleIn]). With `maintainState: true` the hidden child stays mounted
/// — zero height, without pointers or semantics — so it can hold scroll or
/// text-field state; otherwise it leaves the tree once the hide finishes.
/// When `MediaQuery.disableAnimations` is true the child shows or hides
/// immediately.
class AnimatedVisibility extends StatefulWidget {
  const AnimatedVisibility({
    super.key,
    required this.visible,
    required this.child,
    this.maintainState = false,
    this.duration = AppDurations.normal,
    this.curve = AppCurves.standard,
  });

  /// Whether [child] is shown.
  final bool visible;

  /// The subtree revealed or hidden by [visible].
  final Widget child;

  /// Keeps [child] mounted while hidden instead of removing it.
  final bool maintainState;

  /// How long showing or hiding takes.
  final Duration duration;

  /// Easing of the fade and of the height change.
  final Curve curve;

  @override
  State<AnimatedVisibility> createState() => _AnimatedVisibilityState();
}

class _AnimatedVisibilityState extends State<AnimatedVisibility>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _drive;
  bool _disableAnimations = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: widget.visible ? 1.0 : 0.0,
    );
    _drive = _controller.drive(CurveTween(curve: widget.curve));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _disableAnimations = MediaQuery.disableAnimationsOf(context);
    if (_disableAnimations) {
      _controller.value = widget.visible ? 1.0 : 0.0;
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedVisibility oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible != oldWidget.visible) {
      _animateTo(widget.visible);
    }
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
    }
    if (widget.curve != oldWidget.curve) {
      _drive = _controller.drive(CurveTween(curve: widget.curve));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animateTo(bool target) {
    if (_disableAnimations) {
      _controller.value = target ? 1.0 : 0.0;
      return;
    }
    if (target) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (!widget.visible &&
            !widget.maintainState &&
            _controller.status == AnimationStatus.dismissed) {
          return const SizedBox.shrink();
        }
        return IgnorePointer(
          ignoring: !widget.visible,
          child: ExcludeSemantics(
            excluding: !widget.visible,
            child: FadeTransition(
              opacity: _drive,
              child: SizeTransition(
                alignment: AlignmentDirectional.topStart,
                sizeFactor: _drive,
                child: child,
              ),
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}
