import 'package:flutter/material.dart';
import 'package:orbit/core/animations/staggered/staggered_column.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_radius.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';
import 'package:orbit/core/utils/formatters.dart';
import 'package:orbit/core/widgets/app_card.dart';
import 'package:orbit/features/opportunities/domain/entities/opportunity_entity.dart';
import 'package:orbit/features/opportunities/domain/enums/opportunity_status.dart';
import 'package:orbit/features/opportunities/presentation/constants/opportunity_layout_constants.dart';

/// Facts card of the Overview tab: dates, owner, lead source and customer
/// code, one icon-led row per fact so labels and values line up.
class OpportunityDetailsCard extends StatelessWidget {
  const OpportunityDetailsCard({super.key, required this.opportunity});

  final Opportunity opportunity;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final t = context.t.crm.crmOpportunities.detail.facts;
    final c = opportunity.customer;
    final closedAt = opportunity.closedAt;
    final leadSource = c.leadSource;
    final isOverdue =
        opportunity.status == OpportunityStatus.open &&
        opportunity.expectedCloseDate.isBefore(DateTime.now());

    final rows = <_FactRow>[
      _FactRow(
        icon: Icons.event_rounded,
        label: t.expectedClose,
        value: Formatters.crmDate(opportunity.expectedCloseDate),
        valueColor: isOverdue ? colors.error : null,
      ),
      _FactRow(
        icon: Icons.add_circle_outline_rounded,
        label: t.created,
        value: Formatters.crmDate(opportunity.createdAt),
      ),
      if (closedAt != null)
        _FactRow(
          icon: Icons.flag_rounded,
          label: t.closedAt,
          value: Formatters.crmDate(closedAt),
        ),
      _FactRow(
        icon: Icons.person_outline_rounded,
        label: t.owner,
        value: opportunity.employee.employeeName,
      ),
      if (leadSource != null && leadSource.isNotEmpty)
        _FactRow(
          icon: Icons.campaign_outlined,
          label: t.leadSource,
          value: leadSource,
        ),
      _FactRow(
        icon: Icons.tag_rounded,
        label: t.customerCode,
        value: c.customerCode,
      ),
    ];

    return AppCard(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: OpportunityLayoutConstants.overviewCardPadding,
        vertical: AppSpacing.sm,
      ),
      child: StaggeredColumn(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, row) in rows.indexed) ...[
            row,
            if (i < rows.length - 1)
              Divider(height: 1, color: colors.border),
          ],
        ],
      ),
    );
  }
}

class _FactRow extends StatelessWidget {
  const _FactRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final box = OpportunityLayoutConstants.factIconBox;

    return Padding(
      padding: EdgeInsetsDirectional.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: box,
            height: box,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: AppRadius.borderMd,
            ),
            child: Icon(
              icon,
              size: OpportunityLayoutConstants.overviewIconSize,
              color: colors.onPrimaryContainer,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textStyles.labelSmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                SizedBox(height: AppSpacing.xxs),
                Text(
                  value,
                  style: textStyles.bodyMedium.copyWith(
                    color: valueColor,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
