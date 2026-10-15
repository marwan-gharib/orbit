import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../entrance/blur_in.dart';
import '../entrance/scale_in.dart';
import '../tokens/app_animation_constants.dart';
import '../tokens/app_curves.dart';
import '../tokens/app_durations.dart';
import 'app_overlay_motion.dart';

/// Dialog with Orbit's focus-pull entrance: the barrier dims and blurs the
/// page below in, and the content resolves from blurred and scaled to sharp.
///
/// Enter and exit durations and curves come from [AppOverlayMotion]; with
/// `MediaQuery.disableAnimations` the dialog and the backdrop blur render
/// their final state on the first frame. The scrim is the theme's
/// `ColorScheme.scrim`, so light, dark and custom schemes all read correctly.
///
/// ```dart
/// await showAppDialog<bool>(
///   context: context,
///   builder: (context) => AppDialog(
///     title: Text(context.strings.deleteProject),
///     content: Text(context.strings.deleteProjectConfirm),
///     actions: [
///       TextButton(
///         onPressed: () => Navigator.pop(context, false),
///         child: Text(context.strings.cancel),
///       ),
///       FilledButton(
///         onPressed: () => Navigator.pop(context, true),
///         child: Text(context.strings.delete),
///       ),
///     ],
///   ),
/// );
///
/// // Or use the convenience confirm method from [ConfirmDialog]:
/// final confirmed = await ConfirmDialog.show(
///   context: context,
///   title: context.strings.deleteProject,
///   message: context.strings.deleteProjectConfirm,
///   confirmLabel: context.strings.delete,
///   cancelLabel: context.strings.cancel,
///   destructive: true,
/// );
/// ```
Future<T?> showAppDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  bool blurBarrier = true,
  bool useSafeArea = true,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
}) {
  final NavigatorState navigator = Navigator.of(
    context,
    rootNavigator: useRootNavigator,
  );
  return navigator.push<T>(
    _AppDialogRoute<T>(
      context: context,
      themes: InheritedTheme.capture(from: context, to: navigator.context),
      builder: (dialogContext) =>
          BlurIn(child: ScaleIn(child: builder(dialogContext))),
      barrierDismissible: barrierDismissible,
      barrierColor: Theme.of(context).colorScheme.scrim,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      useSafeArea: useSafeArea,
      animationStyle: AppOverlayMotion.modalOf(context),
      blurBarrier: blurBarrier,
      settings: routeSettings,
    ),
  );
}

/// The route behind [showAppDialog]: [DialogRoute] plus a barrier that
/// blurs whatever it covers, and a shorter exit than the entrance.
class _AppDialogRoute<T> extends DialogRoute<T> {
  _AppDialogRoute({
    required super.context,
    required super.builder,
    required super.themes,
    required super.barrierColor,
    required super.barrierDismissible,
    required super.barrierLabel,
    required super.useSafeArea,
    required AnimationStyle animationStyle,
    required this.blurBarrier,
    super.settings,
  }) : super(animationStyle: animationStyle);

  /// Whether the barrier blurs the page under it; false keeps the scrim but
  /// skips the full-window `BackdropFilter`.
  final bool blurBarrier;

  CurvedAnimation? _barrierBlur;

  /// The dialog clears the screen faster than it settles in.
  @override
  Duration get reverseTransitionDuration => AppDurations.fast;

  @override
  Widget buildModalBarrier() {
    final Widget barrier = super.buildModalBarrier();
    final Animation<double>? routeAnimation = animation;
    if (!blurBarrier || routeAnimation == null) return barrier;
    return _BlurredBarrier(
      progress: _blurCurveFor(routeAnimation),
      child: barrier,
    );
  }

  /// The barrier blur follows the route in both directions, unlike [BlurIn],
  /// which only plays once: the backdrop has to unwind on the way out, and it
  /// has to be at full strength in the steady state.
  CurvedAnimation _blurCurveFor(Animation<double> routeAnimation) {
    final CurvedAnimation? existing = _barrierBlur;
    if (existing != null && existing.parent == routeAnimation) return existing;
    existing?.dispose();
    return _barrierBlur = CurvedAnimation(
      parent: routeAnimation,
      curve: AppCurves.enter,
      reverseCurve: AppCurves.exit,
    );
  }

  @override
  void dispose() {
    _barrierBlur?.dispose();
    super.dispose();
  }
}

/// Blurs the page under the barrier while the dialog is open. The filter is
/// dropped at zero strength, so nothing is filtered once the blur has unwound.
class _BlurredBarrier extends StatelessWidget {
  const _BlurredBarrier({required this.progress, required this.child});

  /// Route progress, curved with the enter and exit tokens.
  final Animation<double> progress;

  /// The route's own barrier, kept intact for tap-to-dismiss and semantics.
  final Widget child;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: AnimatedBuilder(
      animation: progress,
      builder: (context, _) {
        final double sigma = AppAnimationConstants.blurSigma * progress.value;
        if (sigma <= 0.0) return child;
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: child,
        );
      },
    ),
  );
}
