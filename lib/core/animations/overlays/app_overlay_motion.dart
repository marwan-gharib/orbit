import 'package:flutter/widgets.dart';

import '../tokens/app_curves.dart';
import '../tokens/app_durations.dart';

/// Motion profile for every modal surface in `overlays/`.
///
/// One place decides how overlays in Orbit move, so dialogs, sheets,
/// snackbars and menus always feel like the same family: they arrive with
/// [AppCurves.enter] and leave with the shorter [AppCurves.exit] tail.
///
/// Reads the ambient `MediaQuery.disableAnimations`; when the user asked the
/// system for reduced motion, the returned style is
/// [AnimationStyle.noAnimation] and the surface renders its final state on the
/// first frame.
///
/// ```dart
/// showDialog(
///   context: context,
///   animationStyle: AppOverlayMotion.modalOf(context),
///   builder: (_) => const SignOutDialog(),
/// );
/// ```
abstract final class AppOverlayMotion {
  /// Motion for full surfaces that own the screen while they are open:
  /// dialogs, bottom sheets and snackbars.
  static AnimationStyle modalOf(BuildContext context) => _styleOf(
    context,
    duration: AppDurations.normal,
    reverseDuration: AppDurations.fast,
  );

  /// Snappier motion for small overlays anchored to a widget, such as a
  /// popup menu: they must feel like a tap response, not a screen change.
  static AnimationStyle anchoredOf(BuildContext context) => _styleOf(
    context,
    duration: AppDurations.fast,
    reverseDuration: AppDurations.fast,
  );

  static AnimationStyle _styleOf(
    BuildContext context, {
    required Duration duration,
    required Duration reverseDuration,
  }) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return AnimationStyle.noAnimation;
    }
    return AnimationStyle(
      curve: AppCurves.enter,
      duration: duration,
      reverseCurve: AppCurves.exit,
      reverseDuration: reverseDuration,
    );
  }
}
