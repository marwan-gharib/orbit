import 'package:flutter/widgets.dart';

/// How [ProgressDriver] moves its progress when [ProgressDriver.active]
/// changes.
enum ProgressDriverMode {
  /// An entrance run: [ProgressDriver.active] restarting it always plays from
  /// zero, and going inactive holds the start state (progress 0). Use for
  /// choreographed entrances of pages and slides.
  replay,

  /// A two-state value: activation drives forward from where the value is
  /// (never jumping), deactivation drives back in reverse; mounting settles
  /// instantly on the active state. Use for morphing between two rest states.
  toggle,
}

/// Builds the animated body of a [ProgressDriver].
///
/// [progress] runs 0..1 with the driver's [ProgressDriver.delayFraction]
/// already applied. [child] is the driver's child and must be passed straight
/// through so the subtree is built once instead of on every animation tick.
typedef ProgressDriverBuilder = Widget Function(
  BuildContext context,
  double progress,
  Widget child,
);

/// Owns one 0..1 progress timeline for content that plays while its slide,
/// page or section is active, and exposes the progress to a [builder].
///
/// This is the Janus primitive behind rebuild-driven entrances: the widget
/// stays mounted while the parent rebuilds with a new [active] flag, and the
/// driver decides — without the caller ever touching a controller — whether
/// the change replays the run ([ProgressDriverMode.replay]) or drives the
/// value to the other rest state ([ProgressDriverMode.toggle]).
///
/// [delayFraction] keeps the first share of the timeline as a hold (progress
/// stays 0) before the run begins, so a driver can start late inside its
/// total [duration]. [builder] receives the post-hold progress, so anything
/// built from it reads plain 0..1 windows.
///
/// ```dart
/// ProgressDriver(
///   duration: AppDurations.slow,
///   active: page.isActive,
///   mode: ProgressDriverMode.replay,
///   delayFraction: 0.2,
///   builder: (context, progress, child) => AssembledSlide(progress: progress, child: child),
///   child: Child(),
/// )
/// ```
///
/// With `MediaQuery.disableAnimations` the progress jumps to the settled
/// value before the first frame.
class ProgressDriver extends StatefulWidget {
  const ProgressDriver({
    super.key,
    required this.duration,
    required this.active,
    this.mode = ProgressDriverMode.replay,
    this.delayFraction = 0.0,
    required this.builder,
    required this.child,
  }) : assert(delayFraction >= 0.0 && delayFraction < 1.0);

  /// Total timeline length, including the [delayFraction] hold.
  final Duration duration;

  /// Whether the content this driver belongs to is currently active.
  final bool active;

  /// What an [active] change does; see [ProgressDriverMode].
  final ProgressDriverMode mode;

  /// First share of [duration] held before the run starts (0..1).
  final double delayFraction;

  /// Receives the post-hold progress and the child.
  final ProgressDriverBuilder builder;

  /// The subtree passed to [builder]; never rebuilt by the driver.
  final Widget child;

  @override
  State<ProgressDriver> createState() => _ProgressDriverState();
}

class _ProgressDriverState extends State<ProgressDriver>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _mountedDependencies = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_mountedDependencies) {
      return;
    }
    _mountedDependencies = true;
    if (widget.mode == ProgressDriverMode.toggle) {
      // A toggle driver mounts settled on whichever state it is built in.
      _controller.value = widget.active ? 1.0 : 0.0;
    } else if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1.0;
    } else if (widget.active) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void didUpdateWidget(covariant ProgressDriver oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
    }
    switch (widget.mode) {
      case ProgressDriverMode.toggle:
        // Keep driving toward the current target on every rebuild, matching
        // an interruptible morph that continues from the running value.
        if (MediaQuery.disableAnimationsOf(context)) {
          _controller.value = widget.active ? 1.0 : 0.0;
        } else if (widget.active) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
      case ProgressDriverMode.replay:
        if (MediaQuery.disableAnimationsOf(context)) {
          _controller.value = 1.0;
          return;
        }
        if (!widget.active) {
          _controller.value = 0.0;
          return;
        }
        if (oldWidget.active != true) {
          _controller.forward(from: 0.0);
        }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final delay = widget.delayFraction;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final raw = _controller.value;
        final progress = delay > 0
            ? (raw <= delay ? 0.0 : (raw - delay) / (1.0 - delay))
            : raw;
        return widget.builder(context, progress.clamp(0.0, 1.0), child!);
      },
      child: widget.child,
    );
  }
}
