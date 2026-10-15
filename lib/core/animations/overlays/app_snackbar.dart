import 'package:flutter/material.dart';

import '../tokens/app_animation_constants.dart';
import '../tokens/app_durations.dart';

import 'package:orbit/core/responsive/responsive.dart';

import 'app_overlay_motion.dart';

/// Severity of a transient message: picks the icon and the theme color it is
/// tinted with.
enum AppSnackbarType {
  success(Icons.check_circle_outline),
  error(Icons.error_outline),
  warning(Icons.warning_amber_outlined),
  info(Icons.info_outline);

  const AppSnackbarType(this.icon);

  /// Icon shown in front of the message, tinted with [colorOf].
  final IconData icon;

  /// Accent color for [icon], taken from the theme's [ColorScheme] so light,
  /// dark and custom schemes all read correctly. Material reserves
  /// [ColorScheme.error] for errors alone, so the other severities take the
  /// remaining accent roles: success the prominent tertiary, warning the
  /// quieter secondary, info the primary.
  Color colorOf(ColorScheme colors) => switch (this) {
    AppSnackbarType.success => colors.tertiary,
    AppSnackbarType.error => colors.error,
    AppSnackbarType.warning => colors.secondary,
    AppSnackbarType.info => colors.primary,
  };
}

/// Why a snackbar left the screen.
enum AppSnackbarResult {
  /// Its auto-dismiss timer ran out.
  autoDismissed,

  /// The user dismissed it (swipe, or an accessibility dismiss action).
  dismissed,

  /// The user pressed the action [AppSnackbar.show] was given.
  actionInvoked,

  /// It was hidden by `ScaffoldMessengerState.hideCurrentSnackBar`.
  hidden,

  /// It was removed without its exit animation.
  removed,
}

/// Transient message with Orbit's motion and severity styling.
///
/// Only one snackbar is ever on screen: showing a new one animates the current
/// one out first, and anything queued behind it is dropped, so a burst of
/// errors never stacks up in front of the user.
///
/// **Context across async gaps.** [context] is read synchronously: the
/// messenger, the theme and the motion style are all resolved before this
/// method returns, so calling it right after an `await` is safe. The returned
/// future completes when the snackbar leaves the screen — the original
/// [context] must not be used after awaiting it; capture whatever you need
/// first.
///
/// ```dart
/// final result = await AppSnackbar.show(
///   context,
///   message: context.strings.invoiceSent,
///   type: AppSnackbarType.success,
///   action: (label: context.strings.undo, onPressed: onUndo),
/// );
/// if (result == AppSnackbarResult.actionInvoked) return;
/// ```
abstract final class AppSnackbar {
  /// Shows [message] and completes when the snackbar leaves the screen, with
  /// [AppSnackbarResult] saying why.
  ///
  /// [duration] is the time the message stays readable before it
  /// auto-dismisses; it defaults to [AppDurations.messageVisible].
  static Future<AppSnackbarResult> show(
    BuildContext context, {
    required String message,
    AppSnackbarType type = AppSnackbarType.info,
    Duration? duration,
    ({String label, VoidCallback onPressed})? action,
  }) {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final ColorScheme colors = Theme.of(context).colorScheme;
    // Replace, never queue: the current message animates out and the new one
    // takes its place, so the screen shows one message at a time.
    messenger.clearSnackBars();
    final ScaffoldFeatureController<SnackBar, SnackBarClosedReason> controller =
        messenger.showSnackBar(
          _snackBar(
            message: message,
            type: type,
            colors: colors,
            duration: duration ?? AppDurations.messageVisible,
            action: action,
          ),
          snackBarAnimationStyle: AppOverlayMotion.modalOf(context),
        );
    return controller.closed.then(_resultOf);
  }

  static SnackBar _snackBar({
    required String message,
    required AppSnackbarType type,
    required ColorScheme colors,
    required Duration duration,
    required ({String label, VoidCallback onPressed})? action,
  }) => SnackBar(
    behavior: SnackBarBehavior.floating,
    duration: duration,
    action: action == null
        ? null
        : SnackBarAction(label: action.label, onPressed: action.onPressed),
    content: Row(
      children: [
        Icon(type.icon, color: type.colorOf(colors)),
        SizedBox(width: Responsive.adapt(AppAnimationConstants.overlayIconGap)),
        Expanded(child: Text(message)),
      ],
    ),
  );

  static AppSnackbarResult _resultOf(SnackBarClosedReason reason) =>
      switch (reason) {
        SnackBarClosedReason.timeout => AppSnackbarResult.autoDismissed,
        SnackBarClosedReason.dismiss ||
        SnackBarClosedReason.swipe => AppSnackbarResult.dismissed,
        SnackBarClosedReason.action => AppSnackbarResult.actionInvoked,
        SnackBarClosedReason.hide => AppSnackbarResult.hidden,
        SnackBarClosedReason.remove => AppSnackbarResult.removed,
      };
}
