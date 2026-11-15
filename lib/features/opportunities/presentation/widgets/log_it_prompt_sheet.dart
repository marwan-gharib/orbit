import 'package:flutter/material.dart';
import 'package:orbit/core/animations/entrance/scale_in.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';
import 'package:orbit/core/widgets/app_button.dart';
import 'package:orbit/features/interactions/domain/enums/interaction_type.dart';

/// "Log this call/email?" prompt shown after the user comes back from a call
/// or an email launched from a contact. Pops `true` for "Log it"; any other
/// way out (button, swipe down, tap outside) means "not now".
class LogItPromptSheet extends StatelessWidget {
  const LogItPromptSheet({super.key, required this.type});

  final InteractionType type;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final t = context.t.crm.crmOpportunities.detail.logIt;
    final isCall = type == InteractionType.call;

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: AppSpacing.lg,
        end: AppSpacing.lg,
        bottom: AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ScaleIn(
                child: CircleAvatar(
                  backgroundColor: colors.primaryContainer,
                  foregroundColor: colors.onPrimaryContainer,
                  child: Icon(
                    isCall ? Icons.phone_rounded : Icons.email_rounded,
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  isCall ? t.callTitle : t.emailTitle,
                  style: context.textStyles.titleMedium,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            t.body,
            style: context.textStyles.bodyMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          AppButton(label: t.log, onPressed: () => Navigator.pop(context, true)),
          SizedBox(height: AppSpacing.xs),
          AppButton.text(
            label: t.notNow,
            onPressed: () => Navigator.pop(context, false),
          ),
        ],
      ),
    );
  }
}
