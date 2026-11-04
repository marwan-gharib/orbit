import 'package:flutter/material.dart';

import 'package:orbit/core/responsive/responsive.dart';
import 'package:orbit/core/theme/app_radius.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';

/// Non-blocking, dismissible notice that the last silent refresh failed and
/// the previous interactions are still on screen.
class InteractionRefreshNotice extends StatelessWidget {
  const InteractionRefreshNotice({
    super.key,
    required this.message,
    required this.dismissLabel,
    required this.onDismiss,
  });

  final String message;
  final String dismissLabel;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsetsDirectional.only(
        start: AppSpacing.sm,
        top: AppSpacing.xs,
        bottom: AppSpacing.xs,
        end: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: colors.warningContainer,
        borderRadius: AppRadius.borderMd,
      ),
      child: Row(
        children: [
          Icon(
            Icons.sync_problem,
            size: Responsive.adapt(20),
            color: colors.onWarningContainer,
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: context.textStyles.bodySmall.copyWith(
                color: colors.onWarningContainer,
              ),
            ),
          ),
          IconButton(
            tooltip: dismissLabel,
            onPressed: onDismiss,
            icon: Icon(Icons.close, color: colors.onWarningContainer),
          ),
        ],
      ),
    );
  }
}
