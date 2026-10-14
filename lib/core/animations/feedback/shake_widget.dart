import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../tokens/app_animation_constants.dart';
import '../tokens/app_durations.dart';
import 'app_haptics.dart';

/// Programmatic trigger for a [ShakeWidget]; call [shake] to play it.
///
/// The widget attaches itself on mount, so calls before the first build are
/// no-ops and disposal detaches cleanly.
///
/// ```dart
/// final shake = ShakeController();
/// // ...
/// ShakeWidget(controller: shake, child: child)
/// shake.shake();
/// ```
class ShakeController {
  VoidCallback? _play;

  /// Plays the attached [ShakeWidget]; no-op while none is mounted.
  void shake() => _play?.call();

  void _attach(VoidCallback play) {
    _play = play;
  }

  void _detach() {
    _play = null;
  }
}

/// Shakes [child] horizontally (4 damped oscillations) as error feedback.
///
/// Fire it either way:
/// - hold a [ShakeController] and call `controller.shake()` (e.g. from a
///   `BlocListener`), or
/// - pass [trigger] and increment the counter in Cubit state, so the shake
///   rides along with the state instead of imperative UI code.
///
/// The first kick goes toward the reading start edge, so it mirrors in RTL.
/// With `MediaQuery.disableAnimations` the motion is skipped entirely;
/// [haptic] still fires because haptics are not animations.
///
/// ```dart
/// // The login Cubit bumps `shakeTrigger` in its failure state.
/// BlocListener<LoginCubit, LoginState>(
///   listenWhen: (prev, curr) => curr.shakeTrigger != prev.shakeTrigger,
///   listener: (context, state) => showInvalidCredentials(context),
///   child: BlocBuilder<LoginCubit, LoginState>(
///     builder: (context, state) => ShakeWidget(
///       trigger: state.shakeTrigger,
///       haptic: true,
///       child: const LoginForm(),
///     ),
///   ),
/// )
/// ```
class ShakeWidget extends StatefulWidget {
  const ShakeWidget({
    super.key,
    required this.child,
    this.trigger = 0,
    this.controller,
    this.duration = AppDurations.slow,
    this.haptic = false,
  });

  /// Increment this counter to fire the shake (e.g. from a Cubit state).
  final int trigger;

  /// Alternative programmatic trigger; fires independently of [trigger].
  final ShakeController? controller;

  /// Length of one full shake.
  final Duration duration;

  /// When true, plays [AppHaptics.error] on every trigger, even if the
  /// motion itself is disabled.
  final bool haptic;

  /// The subtree that shakes; never rebuilt by the animation.
  final Widget child;

  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late bool _disableAnimations;
  late double _directionSign;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    widget.controller?._attach(_play);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _disableAnimations = MediaQuery.disableAnimationsOf(context);
    _directionSign = Directionality.of(context) == TextDirection.ltr
        ? -1.0
        : 1.0;
    // Never freeze mid-shake if the OS flips reduce-motion during one.
    if (_disableAnimations && _controller.isAnimating) {
      _controller.value = 0.0;
    }
  }

  @override
  void didUpdateWidget(covariant ShakeWidget oldWidget) {
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
    if (widget.haptic) AppHaptics.error();
    if (_disableAnimations) return;
    _controller.forward(from: 0.0);
  }

  /// Damped horizontal offset: full amplitude at the first kick, exactly zero
  /// at the end so the child always lands home.
  double get _offsetX {
    final double progress = _controller.value;
    final double wave = math.sin(
      2 * math.pi * AppAnimationConstants.shakeOscillations * progress,
    );
    return AppAnimationConstants.shakeAmplitude *
        wave *
        (1 - progress) *
        _directionSign;
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    child: widget.child,
    builder: (context, child) =>
        Transform.translate(offset: Offset(_offsetX, 0), child: child),
  );
}
