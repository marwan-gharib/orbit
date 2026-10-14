import 'package:flutter/widgets.dart';

import '../tokens/app_animation_constants.dart';
import '../tokens/app_curves.dart';
import '../tokens/app_durations.dart';

/// Cross-fades between states — loading, content, error, empty — with a fade
/// plus a slight scale, stacked so the parent never resizes while the fade
/// runs.
///
/// Give the child one key per state type; equal-keyed children update in
/// place without a transition:
///
/// ```dart
/// AppAnimatedSwitcher(
///   child: KeyedSubtree(
///     key: ValueKey(state.runtimeType),
///     child: switch (state) {
///       OrdersLoading() => const Center(child: CircularProgressIndicator()),
///       OrdersSuccess(:final rows) => OrdersList(rows: rows),
///       OrdersError(:final failure) => ErrorView(failure: failure),
///       OrdersEmpty() => const EmptyState(),
///     },
///   ),
/// )
/// ```
///
/// The exiting state is excluded from hit testing and semantics while it
/// fades, so a stale loading spinner can neither absorb taps nor steal focus.
/// When `MediaQuery.disableAnimations` is true the new state renders
/// immediately.
class AppAnimatedSwitcher extends StatelessWidget {
  const AppAnimatedSwitcher({
    super.key,
    this.duration = AppDurations.normal,
    this.switchInCurve = AppCurves.enter,
    this.switchOutCurve = AppCurves.exit,
    required this.child,
  });

  /// Length of the cross-fade between the outgoing and the incoming state.
  final Duration duration;

  /// Easing applied to the incoming state.
  final Curve switchInCurve;

  /// Easing applied to the outgoing state.
  final Curve switchOutCurve;

  /// The current state; must carry a key that changes with the state type.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return child;
    }
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: switchInCurve,
      switchOutCurve: switchOutCurve,
      transitionBuilder: _crossFade,
      layoutBuilder: _stackedLayout,
      child: child,
    );
  }

  /// Fades [child] in from transparent while it grows from
  /// [AppAnimationConstants.scaleInBegin] to natural size; the outgoing child
  /// runs the same animation backwards.
  static Widget _crossFade(Widget child, Animation<double> animation) =>
      FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: animation.drive(
            Tween<double>(
              begin: AppAnimationConstants.scaleInBegin,
              end: AppAnimationConstants.scaleInEnd,
            ),
          ),
          child: child,
        ),
      );

  /// Stacks the exiting states under the current one, centered and sized to
  /// the largest of them, so layout is stable for the whole cross-fade.
  static Widget _stackedLayout(
    Widget? currentChild,
    List<Widget> previousChildren,
  ) => Stack(
    alignment: AlignmentDirectional.center,
    children: <Widget>[
      for (final previous in previousChildren)
        ExcludeSemantics(child: IgnorePointer(child: previous)),
      ?currentChild,
    ],
  );
}
