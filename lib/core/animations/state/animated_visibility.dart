import 'package:flutter/widgets.dart';

import '../tokens/app_curves.dart';
import '../tokens/app_durations.dart';

/// Shows or hides [child] with a fade plus an animated size along [axis], so
/// nothing pops into or out of the layout.
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
/// — zero size, without pointers or semantics — so it can hold scroll or
/// text-field state; otherwise it leaves the tree once the hide finishes.
/// When `MediaQuery.disableAnimations` is true the child shows or hides
/// immediately.
///
/// [collapseSize] turns the size animation off (fade, slide and scale only):
/// the child keeps its full size while it fades out, which a fixed-height
/// bar needs when one child swaps for another. [offset] slides the child in
/// from a start fraction of its own size (keep empty for a pure fade);
/// [scaleBegin] scales it up from a start factor; [reverseCurve] lets the
/// hide leg ease differently from the show leg. Hidden means not tappable
/// and excluded from semantics in every mode.
class AnimatedVisibility extends StatefulWidget {
  const AnimatedVisibility({
    super.key,
    required this.visible,
    required this.child,
    this.maintainState = false,
    this.axis = Axis.vertical,
    this.collapseSize = true,
    this.offset,
    this.scaleBegin = 1.0,
    this.duration = AppDurations.normal,
    this.curve = AppCurves.standard,
    this.reverseCurve,
  });

  /// Whether [child] is shown.
  final bool visible;

  /// The subtree revealed or hidden by [visible].
  final Widget child;

  /// Keeps [child] mounted while hidden instead of removing it.
  final bool maintainState;

  /// Axis the size animation runs along ([collapseSize] off skips it).
  final Axis axis;

  /// Whether the child's size collapses with the fade; false keeps it at
  /// full size while the fade plays (a fixed-height bar with no pop).
  final bool collapseSize;

  /// Slide-in start offset, as a fraction of the child's size; null does
  /// not slide.
  final Offset? offset;

  /// Scale the child starts from (1.0 does not scale).
  final double scaleBegin;

  /// How long showing or hiding takes.
  final Duration duration;

  /// Easing of the fade and of the size change.
  final Curve curve;

  /// Easing of the hide leg; null uses [curve] both ways.
  final Curve? reverseCurve;

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
    _drive = _animatedCurve();
  }

  Animation<double> _animatedCurve() => CurvedAnimation(
    parent: _controller,
    curve: widget.curve,
    reverseCurve: widget.reverseCurve,
  );

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
    if (widget.curve != oldWidget.curve ||
        widget.reverseCurve != oldWidget.reverseCurve) {
      _drive = _animatedCurve();
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
        Widget animated = FadeTransition(opacity: _drive, child: child);
        final offset = widget.offset;
        if (offset != null) {
          animated = SlideTransition(
            position: _drive.drive(
              Tween<Offset>(begin: offset, end: Offset.zero),
            ),
            child: animated,
          );
        }
        if (widget.scaleBegin != 1.0) {
          animated = ScaleTransition(
            scale: _drive.drive(
              Tween<double>(begin: widget.scaleBegin, end: 1.0),
            ),
            child: animated,
          );
        }
        if (widget.collapseSize) {
          animated = SizeTransition(
            axis: widget.axis,
            alignment: AlignmentDirectional.topStart,
            sizeFactor: _drive,
            child: animated,
          );
        }
        return IgnorePointer(
          ignoring: !widget.visible,
          child: ExcludeSemantics(excluding: !widget.visible, child: animated),
        );
      },
      child: widget.child,
    );
  }
}
