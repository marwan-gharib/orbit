import 'package:flutter/material.dart';

import 'package:orbit/core/animations/overlays/app_dialog_route.dart';
import 'package:orbit/core/widgets/app_button.dart';
import 'package:orbit/core/widgets/app_dialog.dart';

/// A confirmation dialog with standardized styling and actions.
///
/// Uses Orbit's styled [AppDialog] with the focus-pull entrance animation
/// (via [showAppDialog]).
abstract final class ConfirmDialog {
  /// Shows a confirmation dialog and completes with `true` if confirmed,
  /// `false` if cancelled or dismissed.
  ///
  /// - [title]: The dialog title.
  /// - [message]: The dialog message/body.
  /// - [confirmLabel]: Label for the confirm button (primary action).
  /// - [cancelLabel]: Label for the cancel button (secondary action).
  /// - [destructive]: Whether the confirm action is destructive (uses error color).
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmLabel,
    required String cancelLabel,
    bool destructive = false,
  }) async {
    final result = await showAppDialog<bool>(
      context: context,
      builder: (context) => AppDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          AppButton.text(
            label: cancelLabel,
            onPressed: () => Navigator.pop(context, false),
          ),
          AppButton.filled(
            label: confirmLabel,
            onPressed: () => Navigator.pop(context, true),
            destructive: destructive,
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
