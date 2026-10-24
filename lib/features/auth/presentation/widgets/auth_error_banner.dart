import 'package:flutter/material.dart';

import 'package:orbit/core/theme/app_radius.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';

import '../constants/auth_layout_constants.dart';

/// Dismiss-less error surface for a failed auth request: a localized title,
/// the localized failure message, and an icon, all in the theme's error
/// container colours.
///
/// The banner is decoration only; it announces itself once via [Semantics] and
/// the screen decides when to show it (and whether to shake the form).
class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({
    required this.title,
    required this.message,
    super.key,
  });

  /// Short localized heading, e.g. "Couldn't sign you in".
  final String title;

  /// Localized, user-safe failure explanation.
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    return Semantics(
      liveRegion: true,
      label: '$title. $message',
      child: ExcludeSemantics(
        child: Container(
          padding: EdgeInsetsDirectional.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: colors.errorContainer,
            borderRadius: AppRadius.borderMd,
            border: Border.all(
              color: colors.error.withValues(
                alpha: AuthLayout.errorBorderOpacity,
              ),
              width: AuthLayout.errorBorderWidth,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.error_outline,
                size: AuthLayout.errorIconSize,
                color: colors.onErrorContainer,
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textStyles.titleSmall.copyWith(
                        color: colors.onErrorContainer,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xxs),
                    Text(
                      message,
                      style: textStyles.bodySmall.copyWith(
                        color: colors.onErrorContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
