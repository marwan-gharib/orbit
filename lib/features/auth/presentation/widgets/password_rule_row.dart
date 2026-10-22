import 'package:flutter/material.dart';
import 'package:orbit/core/animations/animations.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';

import '../constants/auth_layout_constants.dart';
import 'password_rules.dart';

/// One checklist line: marker plus requirement.
///
/// The marker swaps through [AppAnimatedSwitcher], so only the icon cross-fades
/// when the rule flips; the label stays put and nothing above rebuilds.
class PasswordRuleRow extends StatelessWidget {
  const PasswordRuleRow({
    required this.rule,
    required this.satisfied,
    super.key,
  });

  final PasswordRuleId rule;
  final bool satisfied;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final status = satisfied
        ? context.t.auth.signup.a11y.ruleMet
        : context.t.auth.signup.a11y.ruleNotMet;

    return Semantics(
      label: '${rule.label(context)}, $status',
      child: ExcludeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppAnimatedSwitcher(
              child: Icon(
                satisfied ? Icons.check_circle : Icons.radio_button_unchecked,
                key: ValueKey(satisfied),
                size: AuthLayout.checklistMarkerSize,
                color: satisfied ? colors.success : colors.textDisabled,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                rule.label(context),
                style: textStyles.bodySmall.copyWith(
                  color: satisfied ? colors.textPrimary : colors.textSecondary,
                  decoration: satisfied
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
