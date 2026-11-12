import 'package:flutter/material.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_radius.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';

/// Non-blocking, dismissible notice shown above the dashboard when a silent
/// refresh failed. The figures on screen stay as they were.
class DashboardRefreshNotice extends StatelessWidget {
  const DashboardRefreshNotice({super.key, required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final common = context.t.crm.common;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.warningContainer,
        borderRadius: AppRadius.borderMd,
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: AppSpacing.md,
          end: AppSpacing.xs,
          top: AppSpacing.xs,
          bottom: AppSpacing.xs,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                common.refreshFailedNotice,
                style: context.textStyles.bodyMedium.copyWith(
                  color: colors.onWarningContainer,
                ),
              ),
            ),
            TextButton(
              onPressed: onDismiss,
              child: Text(
                common.dismiss,
                style: context.textStyles.labelLarge.copyWith(
                  color: colors.onWarningContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
