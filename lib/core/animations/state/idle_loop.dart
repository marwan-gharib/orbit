import 'package:flutter/widgets.dart';

import '../tokens/app_curves.dart';

/// Builds the loop frame of an [IdleLoop] from the raw phase.
///
/// [phase] is the controller value (0..1), unshaped by any curve; use it for
/// loop shapes with their own pause or travel math. [child] is the loop's
/// child and must be passed straight through.
typedef IdleLoopPhaseBuilder = Widget Function(
  BuildContext context,
  double phase,
  Widget child,
);

/// Loops an idle motion around [child] while [active].
///
/// The typed constructor runs a generic loop from ranges: rest at every
/// default (scale 1, no travel, full opacity) so a stopped loop renders
/// exactly the settled frame. The physics:
///
/// - `reverse: false` repeats forward, snapping back to the start value each
///   cycle — the expanding/echo pulse shape. [phase] delays the loop start
///   (0..1 of [period]) so two copies can alternate out of step.
/// - `reverse: true` drives out and back (the reverse repeat doubles the
///   cycle), one linear leg out, one leg back — a breathing/float shape.
///
/// [curve] shapes each leg. [translateTo] is the highest travel as fractions
/// of the child's size; [scaleTo] is the peak scale; [opacityTo] the opacity
/// at the top of the loop.
///
/// The `phase` builder constructor hands the raw controller phase to the
/// caller instead, for loop shapes with their own math (travel pauses,
/// bezier paths). No controller ever leaves the widget.
///
/// Loops stop when [active] turns false and when `MediaQuery.disableAnimations`
/// is on, holding the settled frame in both cases: the typed ranges all rest,
/// and a raw-phase frame hands its child back untouched (its shape math has no
/// settled point).
///
/// ```dart
/// IdleLoop(
///   active: slide.isSettled,
///   period: AppDurations.indeterminate,
///   scaleTo: AppAnimationConstants.pulsePeak,
///   child: const RingArtwork(),
/// )
/// ```
class IdleLoop extends StatefulWidget {
  const IdleLoop({
    super.key,
    required this.active,
    required this.period,
    required this.child,
    this.phaseBuilder,
    this.scaleTo = 1.0,
    this.translateTo = Offset.zero,
    this.opacityTo = 1.0,
    this.curve = AppCurves.linear,
    this.reverse = false,
    this.phase = 0.0,
    this.pivot = Alignment.center,
  }) : assert(
         phaseBuilder == null ||
             (scaleTo == 1.0 &&
                 translateTo == Offset.zero &&
                 opacityTo == 1.0 &&
                 phase == 0.0),
         'Using phaseBuilder replaces the typed ranges; set only one.',
       ),
       assert(!reverse || phase == 0.0);

  /// Whether the idle loop should currently run.
  final bool active;

  /// One full loop cycle. In `reverse` mode the cycle is the out-and-back
  /// round trip; one leg runs for half of it.
  final Duration period;

  /// The subtree the loop wraps; never rebuilt by the loop itself.
  final Widget child;

  /// Raw-phase variant; see [IdleLoopPhaseBuilder].
  final IdleLoopPhaseBuilder? phaseBuilder;

  /// Peak scale of the loop (1.0 is the settled size).
  final double scaleTo;

  /// Highest travel as fractions of the child's size.
  final Offset translateTo;

  /// Opacity at the top of the loop (1.0 keeps the child opaque).
  final double opacityTo;

  /// Easing of one loop leg.
  final Curve curve;

  /// Whether the loop drives out and back instead of restarting each cycle.
  final bool reverse;

  /// Loop start offset (0..1 of [period]); requires `reverse: false`.
  final double phase;

  /// Origin of the scale, in the child's alignment space.
  final Alignment pivot;

  @override
  State<IdleLoop> createState() => _IdleLoopState();
}

class _IdleLoopState extends State<IdleLoop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _disableAnimations = false;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    // Reverse mode doubles the cycle: period is the full round trip.
    _controller = AnimationController(
      vsync: this,
      duration: widget.reverse ? widget.period ~/ 2 : widget.period,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _disableAnimations = MediaQuery.disableAnimationsOf(context);
    _syncLoop();
  }

  @override
  void didUpdateWidget(covariant IdleLoop oldWidget) {
    super.didUpdateWidget(oldWidget);
    final leg = widget.reverse ? widget.period ~/ 2 : widget.period;
    if (leg != _controller.duration) {
      _controller.duration = leg;
    }
    final reduced = MediaQuery.disableAnimationsOf(context);
    if (widget.active != oldWidget.active || reduced != _disableAnimations) {
      _disableAnimations = reduced;
      _syncLoop();
    }
  }

  void _syncLoop() {
    final canLoop = widget.active && !_disableAnimations;
    _running = canLoop;
    if (canLoop && !_controller.isAnimating) {
      _controller.repeat(reverse: widget.reverse);
    } else if (!canLoop && _controller.isAnimating) {
      _controller
        ..stop()
        ..value = 0.0;
    } else if (!canLoop) {
      _controller.value = 0.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final buildFrame = widget.phaseBuilder;
        if (buildFrame != null) {
          // A stopped raw-phase loop holds the settled frame by handing the
          // child back untouched: its shape math has no settled point.
          return _running
              ? buildFrame(context, _controller.value, child!)
              : child!;
        }
        // A stopped typed loop rests every range; without this gate a phased
        // loop would show its phase slice while inactive.
        final double leg;
        if (!_running) {
          leg = 0.0;
        } else if (widget.reverse) {
          leg = _controller.value;
        } else {
          leg = (_controller.value + widget.phase) % 1.0;
        }
        final eased = widget.curve.transform(leg);
        Widget looped = child!;
        if (widget.scaleTo != 1.0) {
          looped = Transform.scale(
            scale: 1.0 + (widget.scaleTo - 1.0) * eased,
            alignment: widget.pivot,
            child: looped,
          );
        }
        if (widget.translateTo != Offset.zero) {
          looped = FractionalTranslation(
            translation: Offset(
              widget.translateTo.dx * eased,
              widget.translateTo.dy * eased,
            ),
            child: looped,
          );
        }
        final opacity = 1.0 - (1.0 - widget.opacityTo) * eased;
        return opacity >= 1.0
            ? looped
            : Opacity(opacity: opacity, child: looped);
      },
      child: widget.child,
    );
  }
}
