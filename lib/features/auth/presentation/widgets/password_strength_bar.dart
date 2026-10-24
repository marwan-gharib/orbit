import 'package:flutter/material.dart';

import 'package:orbit/core/animations/animations.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';

import '../constants/auth_layout_constants.dart';
import 'password_rules.dart';

/// Strength meter derived from the same checklist progress.
///
/// [AnimatedProgressBar] runs from the shared animation layer, and the track
/// is announced as one localized percentage-free statement (the bar itself is
/// decoration). Wrap it like [PasswordChecklist] to keep rebuilds local.
class PasswordStrengthBar extends StatelessWidget {
  const PasswordStrengthBar({required this.password, super.key});

  /// Raw current password text.
  final String password;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final strength = passwordStrengthOf(password);
    final label = strength.label(context);
    final total = passwordRules.rules.length;
    final progress = satisfiedPasswordRuleCount(password) / total;

    final color = switch (strength) {
      PasswordStrength.weak => colors.error,
      PasswordStrength.fair => colors.warning,
      PasswordStrength.good => colors.primary,
      PasswordStrength.strong => colors.success,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                context.t.auth.signup.strengthLabel,
                style: textStyles.labelMedium.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
            Text(label, style: textStyles.labelMedium.copyWith(color: color)),
          ],
        ),
        SizedBox(height: AppSpacing.xs),
        Semantics(
          label: '${context.t.auth.signup.strengthLabel}: $label',
          child: ExcludeSemantics(
            child: AnimatedProgressBar(
              progress: progress,
              color: color,
              height: AuthLayout.strengthBarHeight,
            ),
          ),
        ),
      ],
    );
  }
}
