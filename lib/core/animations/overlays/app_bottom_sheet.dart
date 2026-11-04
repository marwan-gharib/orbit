import 'package:flutter/material.dart';

import 'app_overlay_motion.dart';

/// Modal bottom sheet with Orbit's unified motion, a themed drag handle and
/// safe-area handling.
///
/// Enter and exit durations and curves come from [AppOverlayMotion], so every
/// sheet in the app arrives and leaves the same way; with
/// `MediaQuery.disableAnimations` it appears in its final position on the
/// first frame. Colors, shape and the drag handle come from the ambient
/// theme, never from this helper. The sheet already keeps clear of the home
/// indicator and the keyboard; content that must grow past the default height
/// (forms, pickers) is what [isScrollControlled] is for.
///
/// A form that must not lose typed text can be made non-dismissible
/// (`isDismissible: false`, `enableDrag: false`) and hide the handle with
/// `showDragHandle: false`; dismissal then only happens through the sheet's
/// own actions or a handled system back.
///
/// ```dart
/// final filter = await AppBottomSheet.show<ProjectFilter>(
///   context: context,
///   isScrollControlled: true,
///   builder: (context) => const ProjectFilterSheet(),
/// );
/// ```
abstract final class AppBottomSheet {
  /// Shows [builder] in a modal bottom sheet and completes with the value the
  /// sheet was popped with, or null when it was dismissed.
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool isScrollControlled = false,
    bool isDismissible = true,
    bool enableDrag = true,
    bool showDragHandle = true,
    bool useSafeArea = true,
    RouteSettings? routeSettings,
  }) => showModalBottomSheet<T>(
    context: context,
    builder: builder,
    isScrollControlled: isScrollControlled,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    showDragHandle: showDragHandle,
    useSafeArea: useSafeArea,
    routeSettings: routeSettings,
    sheetAnimationStyle: AppOverlayMotion.modalOf(context),
  );
}
