import 'package:flutter/material.dart';

import 'package:orbit/core/responsive/responsive.dart';
import 'package:orbit/core/theme/app_radius.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';

enum AppStatus { success, warning, error, info, neutral }

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    required this.label,
    required this.status,
    this.icon,
    super.key,
  });

  final String label;
  final AppStatus status;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    final (
      Color backgroundColor,
      Color textColor,
      IconData defaultIcon,
    ) = switch (status) {
      AppStatus.success => (
        colors.successContainer,
        colors.onSuccessContainer,
        Icons.check_circle,
      ),
      AppStatus.warning => (
        colors.warningContainer,
        colors.onWarningContainer,
        Icons.warning_amber,
      ),
      AppStatus.error => (
        colors.errorContainer,
        colors.onErrorContainer,
        Icons.error,
      ),
      AppStatus.info => (
        colors.primaryContainer,
        colors.onPrimaryContainer,
        Icons.info,
      ),
      AppStatus.neutral => (
        colors.surfaceVariant,
        colors.textPrimary,
        Icons.circle,
      ),
    };

    final effectiveIcon = icon ?? defaultIcon;

    return Semantics(
      label: '$label, ${_statusLabel(status)}',
      child: Container(
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: AppRadius.borderFull,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(effectiveIcon, size: Responsive.adapt(14), color: textColor),
            SizedBox(width: AppSpacing.xxs),
            Text(
              label,
              style: textStyles.labelSmall.copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(AppStatus status) {
    return switch (status) {
      AppStatus.success => 'Success',
      AppStatus.warning => 'Warning',
      AppStatus.error => 'Error',
      AppStatus.info => 'Info',
      AppStatus.neutral => 'Neutral',
    };
  }
}
