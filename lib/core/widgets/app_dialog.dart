import 'package:flutter/material.dart';

import 'package:orbit/core/theme/app_radius.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';

/// A styled dialog using Orbit's theme tokens.
///
/// Use with [showAppDialog] from the animations layer for the focus-pull
/// entrance and blurred barrier, or directly in a [showDialog] call for a
/// standard modal.
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
/// ```
class AppDialog extends StatelessWidget {
  const AppDialog({
    this.title,
    this.content,
    this.actions,
    this.icon,
    super.key,
  });

  final Widget? title;
  final Widget? content;
  final List<Widget>? actions;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    return AlertDialog(
      icon: icon,
      title: title,
      content: content,
      actions: actions,
      actionsPadding: EdgeInsetsDirectional.only(
        end: AppSpacing.md,
        bottom: AppSpacing.sm,
      ),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
      backgroundColor: colors.surfaceElevated,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: textStyles.headlineSmall,
      contentTextStyle: textStyles.bodyMedium,
    );
  }
}
