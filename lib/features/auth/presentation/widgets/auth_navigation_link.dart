import 'package:flutter/material.dart';
import 'package:orbit/core/animations/animations.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';

import '../constants/auth_layout_constants.dart';

/// Inline prompt plus underlined action ("New to Orbit? Create an account").
///
/// Motion is [TapScale] press feedback only: the underline is part of the
/// action style, and the widget never rebuilds its parent. The tap itself is
/// handled by the inner [InkWell], so ripple and focus follow the platform.
class AuthNavigationLink extends StatelessWidget {
  const AuthNavigationLink({
    required this.prompt,
    required this.action,
    required this.onTap,
    super.key,
  });

  /// Localized lead-in sentence, in secondary text colour.
  final String prompt;

  /// Localized action label, underlined in the primary colour.
  final String action;

  /// Called when the action is activated.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    return Semantics(
      button: true,
      label: '$prompt $action',
      child: ExcludeSemantics(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: AuthLayout.minTouchTarget),
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(vertical: AppSpacing.sm),
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.xs,
              children: [
                Text(
                  prompt,
                  style: textStyles.bodyMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                TapScale(
                  haptic: HapticType.selection,
                  onTap: onTap,
                  child: Text(
                    action,
                    style: textStyles.labelLarge.copyWith(
                      color: colors.primary,
                      decoration: TextDecoration.underline,
                      decorationColor: colors.primary,
                      decorationThickness: AuthLayout.linkUnderlineThickness,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
