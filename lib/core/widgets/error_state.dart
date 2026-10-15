import 'package:flutter/material.dart';

import 'package:orbit/core/responsive/responsive.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';
import 'package:orbit/core/widgets/app_button.dart';

class ErrorState extends StatelessWidget {
  const ErrorState({
    this.title,
    required this.message,
    this.icon,
    this.retryAction,
    super.key,
  });

  final String? title;
  final String message;
  final IconData? icon;
  final ({String label, VoidCallback onPressed})? retryAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    final effectiveIcon = icon ?? Icons.error_outline;

    return Center(
      child: Padding(
        padding: AppSpacing.page,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: Responsive.width(320)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsetsDirectional.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: colors.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  effectiveIcon,
                  size: Responsive.adapt(48),
                  color: colors.onErrorContainer,
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              if (title != null) ...[
                Text(
                  title!,
                  style: textStyles.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.sm),
              ],
              Text(
                message,
                style: textStyles.bodyMedium.copyWith(
                  color: colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              if (retryAction != null) ...[
                SizedBox(height: AppSpacing.xl),
                AppButton(
                  label: retryAction!.label,
                  variant: AppButtonVariant.filled,
                  onPressed: retryAction!.onPressed,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
