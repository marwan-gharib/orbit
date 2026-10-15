import 'package:flutter/widgets.dart';

import '../tokens/app_animation_constants.dart';
import '../tokens/app_curves.dart';
import '../tokens/app_durations.dart';
import 'app_haptics.dart';

/// Scales [child] down to [AppAnimationConstants.tapScale] while pressed and
/// springs it back on release.
///
/// Press feedback listens to raw pointer events, not gesture recognizers, so
/// the child's own gestures and ink effects (e.g. an `InkWell`) keep winning
/// the gesture arena untouched. When [onTap] is set the subtree is annotated
/// with a button role; the accessible label still comes from the child.
/// With `MediaQuery.disableAnimations` the pressed state applies instantly,
/// without a tween.
///
/// ```dart
/// TapScale(
///   haptic: HapticType.light,
///   onTap: onSubmit,
///   child: child,
/// )
/// ```
class TapScale extends StatefulWidget {
  const TapScale({
    super.key,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.haptic = HapticType.none,
    required this.child,
  });

  /// Called on a completed tap; adds the button semantics role.
  final VoidCallback? onTap;

  /// Called on a completed long press.
  final VoidCallback? onLongPress;

  /// When false, no press feedback and no callbacks fire; the child stays
  /// interactive on its own.
  final bool enabled;

  /// Haptic played on press down.
  final HapticType haptic;

  /// The subtree that presses; never rebuilt by the animation.
  final Widget child;

  @override
  State<TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<TapScale>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late bool _disableAnimations;

  @override
  void initState() {
    super.initState();
    // Duration is chosen per transition in the pointer handlers; the
    // controller only carries the value.
    _controller = AnimationController(vsync: this);
    _scale = _controller.drive(
      Tween<double>(begin: 1.0, end: AppAnimationConstants.tapScale),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _disableAnimations = MediaQuery.disableAnimationsOf(context);
  }

  @override
  void didUpdateWidget(covariant TapScale oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled && !widget.enabled) {
      _controller.value = 0.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (!widget.enabled) return;
    AppHaptics.play(widget.haptic);
    if (_disableAnimations) {
      _controller.value = 1.0;
    } else {
      _controller.animateTo(
        1.0,
        duration: AppDurations.fast,
        curve: AppCurves.standard,
      );
    }
  }

  void _handlePointerRelease(PointerEvent event) {
    // Always restore, even if `enabled` flipped mid-press.
    if (_disableAnimations) {
      _controller.value = 0.0;
    } else {
      _controller.animateBack(
        0.0,
        duration: AppDurations.fast,
        curve: AppCurves.spring,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget pressed = Listener(
      onPointerDown: _handlePointerDown,
      onPointerUp: _handlePointerRelease,
      onPointerCancel: _handlePointerRelease,
      child: GestureDetector(
        onTap: widget.enabled ? widget.onTap : null,
        onLongPress: widget.enabled ? widget.onLongPress : null,
        child: ScaleTransition(scale: _scale, child: widget.child),
      ),
    );
    if (widget.onTap == null) return pressed;
    return Semantics(button: true, child: pressed);
  }
}
