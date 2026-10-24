import 'package:flutter/material.dart';

import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';

import 'password_rule_row.dart';
import 'password_rules.dart';

/// Live checklist for the signup password. It reads the shared [passwordRules]
/// set, so the validator and this list can never drift apart.
///
/// Wrap it in a `ValueListenableBuilder` on the password controller so only
/// this subtree rebuilds per keystroke; the widget itself holds no state.
class PasswordChecklist extends StatelessWidget {
  const PasswordChecklist({required this.password, super.key});

  /// Raw current password text.
  final String password;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final violations = passwordRules.violations(password);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.t.auth.signup.checklistTitle,
          style: textStyles.labelMedium.copyWith(color: colors.textSecondary),
        ),
        SizedBox(height: AppSpacing.sm),
        for (final rule in PasswordRuleId.values)
          Padding(
            padding: EdgeInsetsDirectional.only(bottom: AppSpacing.xs),
            child: PasswordRuleRow(
              rule: rule,
              satisfied: !(violations[rule] ?? true),
            ),
          ),
      ],
    );
  }
}
