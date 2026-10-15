import 'package:flutter/widgets.dart';

import '../tokens/app_animation_constants.dart';
import '../tokens/app_curves.dart';
import '../tokens/app_durations.dart';

/// Loops a gentle scale/opacity breath on [child] while [active] is true —
/// notification badges, an "important" button that needs attention.
///
/// The ticker runs only while active: flip `active` to false and it stops,
/// snaps to the rest state (full scale, full opacity), and costs no frames.
/// With `MediaQuery.disableAnimations` the loop never starts; the rest state
/// renders immediately. Both axes read their values from the tokens.
///
/// ```dart
/// PulseWidget(
///   active: hasUnread,
///   child: Badge(count: unreadCount),
/// )
/// ```
class PulseWidget extends StatefulWidget {
  const PulseWidget({
    super.key,
    required this.child,
    this.active = false,
    this.duration = AppDurations.normal,
  });

  /// Whether the loop runs; false renders the static rest state.
  final bool active;

  /// Length of one direction of the breath (out and back each take this).
  final Duration duration;

  /// The subtree that pulses; rebuilt only when this widget rebuilds, never
  /// on animation ticks.
  final Widget child;

  @override
  State<PulseWidget> createState() => _PulseWidgetState();
}

class _PulseWidgetState extends State<PulseWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;
  late bool _disableAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    final Animation<double> drive = _controller.drive(
      CurveTween(curve: AppCurves.standard),
    );
    _scale = drive.drive(
      Tween<double>(begin: 1.0, end: AppAnimationConstants.pulseScale),
    );
    _opacity = drive.drive(
      Tween<double>(
        begin: AppAnimationConstants.fadeOpacityEnd,
        end: AppAnimationConstants.pulseOpacityMin,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _disableAnimations = MediaQuery.disableAnimationsOf(context);
    _syncLoop();
  }

  @override
  void didUpdateWidget(covariant PulseWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
    }
    if (widget.active != oldWidget.active) {
      _syncLoop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _syncLoop() {
    if (widget.active && !_disableAnimations) {
      if (!_controller.isAnimating) {
        _controller.repeat(reverse: true);
      }
      return;
    }
    if (_controller.isAnimating) {
      _controller.stop();
      _controller.value = 0.0; // snap home instead of freezing mid-breath
    }
  }

  @override
  Widget build(BuildContext context) => ScaleTransition(
    scale: _scale,
    child: FadeTransition(
      opacity: _opacity,
      // One cached layer: the loop composites it instead of repainting the
      // child on every breath.
      child: RepaintBoundary(child: widget.child),
    ),
  );
}
