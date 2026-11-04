import 'package:flutter/material.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';
import 'package:orbit/core/utils/formatters.dart';
import 'package:orbit/core/widgets/app_card.dart';
import 'package:orbit/features/opportunities/domain/entities/opportunity_entity.dart';
import 'package:orbit/features/opportunities/domain/enums/opportunity_status.dart';
import 'package:orbit/features/opportunities/presentation/constants/opportunity_layout_constants.dart';

/// Full-width status banner for Won/Lost opportunities.
/// Open opportunities have no banner (breathing dot on badge instead).
class StatusBanner extends StatelessWidget {
  const StatusBanner({super.key, required this.opportunity});

  final Opportunity opportunity;

  @override
  Widget build(BuildContext context) {
    if (opportunity.status == OpportunityStatus.open) {
      return const SizedBox.shrink();
    }

    final isWon = opportunity.status == OpportunityStatus.won;
    final colors = context.colors;
    final textStyles = context.textStyles;
    final t = context.t.crm.crmOpportunities.detail;

    return AppCard(
      padding: EdgeInsets.all(OpportunityLayoutConstants.progressCardPadding),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isWon ? colors.successContainer : colors.errorContainer,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isWon
                  ? Icon(
                      Icons.check_rounded,
                      size: 24,
                      color: colors.onSuccessContainer,
                    )
                  : Icon(
                      Icons.close_rounded,
                      size: 24,
                      color: colors.onErrorContainer,
                    ),
            ),
          ),
          SizedBox(width: AppSpacing.md),

          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isWon ? t.statusWon : t.statusLost,
                  style: textStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isWon ? colors.success : colors.error,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  isWon
                      ? '${t.facts.closedAt} ${Formatters.crmDate(opportunity.closedAt!)}'
                      : (opportunity.lostReason.isEmpty
                            ? t.lostReasonEmpty
                            : opportunity.lostReason),
                  style: textStyles.bodyMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
