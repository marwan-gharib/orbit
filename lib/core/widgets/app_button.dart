import 'package:flutter/material.dart';

import 'package:orbit/core/responsive/responsive.dart';
import 'package:orbit/core/theme/app_radius.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';

enum AppButtonVariant { filled, elevated, outlined, text }

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    this.variant = AppButtonVariant.filled,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.semanticLabel,
    this.destructive = false,
    super.key,
  });

  /// Creates a filled button (primary action).
  const AppButton.filled({
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.semanticLabel,
    this.destructive = false,
    super.key,
  }) : variant = AppButtonVariant.filled;

  /// Creates a text button (secondary action).
  const AppButton.text({
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.semanticLabel,
    super.key,
  }) : variant = AppButtonVariant.text,
       destructive = false;

  /// Creates an outlined button.
  const AppButton.outlined({
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.semanticLabel,
    super.key,
  }) : variant = AppButtonVariant.outlined,
       destructive = false;

  /// Creates an elevated button.
  const AppButton.elevated({
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.semanticLabel,
    super.key,
  }) : variant = AppButtonVariant.elevated,
       destructive = false;

  final String label;
  final AppButtonVariant variant;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final String? semanticLabel;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final isDisabled = onPressed == null || isLoading;
    final effectiveOnPressed = isDisabled ? null : onPressed;

    Widget child = isLoading
        ? SizedBox(
            width: textStyles.labelLarge.fontSize ?? Responsive.adapt(24),
            height: textStyles.labelLarge.fontSize ?? Responsive.adapt(24),
            child: CircularProgressIndicator(
              strokeWidth: Responsive.adapt(2),
              valueColor: AlwaysStoppedAnimation(switch (variant) {
                AppButtonVariant.filled => colors.onPrimary,
                _ => colors.primary,
              }),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[icon!, SizedBox(width: AppSpacing.xs)],
              Text(label, style: textStyles.labelLarge),
            ],
          );

    ButtonStyle style;
    switch (variant) {
      case AppButtonVariant.filled:
        style = FilledButton.styleFrom(
          padding: AppSpacing.button,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderSm),
        );
        break;
      case AppButtonVariant.elevated:
        style = ElevatedButton.styleFrom(
          padding: AppSpacing.button,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderSm),
        );
        break;
      case AppButtonVariant.outlined:
        style = OutlinedButton.styleFrom(
          padding: AppSpacing.button,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderSm),
        );
        break;
      case AppButtonVariant.text:
        style = TextButton.styleFrom(
          padding: AppSpacing.button,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderSm),
        );
        break;
    }

    Widget button = switch (variant) {
      AppButtonVariant.filled => FilledButton(
        onPressed: effectiveOnPressed,
        style: style,
        child: child,
      ),
      AppButtonVariant.elevated => ElevatedButton(
        onPressed: effectiveOnPressed,
        style: style,
        child: child,
      ),
      AppButtonVariant.outlined => OutlinedButton(
        onPressed: effectiveOnPressed,
        style: style,
        child: child,
      ),
      AppButtonVariant.text => TextButton(
        onPressed: effectiveOnPressed,
        style: style,
        child: child,
      ),
    };

    if (semanticLabel != null) {
      button = Semantics(
        label: semanticLabel,
        button: true,
        enabled: !isDisabled,
        excludeSemantics: true,
        child: button,
      );
    }

    return button;
  }
}
