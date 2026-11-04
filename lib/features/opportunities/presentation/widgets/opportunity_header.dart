import 'package:flutter/material.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_radius.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';
import 'package:orbit/core/utils/formatters.dart';
import 'package:orbit/core/widgets/status_badge.dart';
import 'package:orbit/features/opportunities/domain/entities/opportunity_entity.dart';
import 'package:orbit/features/opportunities/domain/enums/opportunity_stage.dart';
import 'package:orbit/features/opportunities/domain/enums/opportunity_status.dart';
import 'package:orbit/features/opportunities/presentation/constants/opportunity_layout_constants.dart';

/// Header section for the opportunity detail — shown in the collapsing SliverAppBar.
class OpportunityHeader extends StatelessWidget {
  const OpportunityHeader({super.key, required this.opportunity});

  final Opportunity opportunity;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final t = context.t.crm.crmOpportunities.detail;
    final isOverdue = _isOverdue(opportunity);

    return Padding(
      padding: EdgeInsets.all(OpportunityLayoutConstants.headerPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title (large, up to 2 lines)
          Text(
            opportunity.title,
            style: textStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: OpportunityLayoutConstants.headerTitleGap),

          // Status badge + Stage chip
          Row(
            children: [
              _StatusBadge(status: opportunity.status),
              SizedBox(width: AppSpacing.sm),
              _StageChip(stage: opportunity.stage),
            ],
          ),
          SizedBox(height: OpportunityLayoutConstants.headerRowGap),

          // Estimated value (prominent)
          Text(
            Formatters.money(opportunity.estimatedValue, opportunity.currency),
            style: textStyles.headlineSmall.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: OpportunityLayoutConstants.headerRowGap),

          // Dates row
          Row(
            children: [
              Expanded(
                child: _DateRow(
                  icon: Icons.calendar_today_rounded,
                  label: t.facts.expectedClose,
                  value: Formatters.crmDate(opportunity.expectedCloseDate),
                  isOverdue: isOverdue,
                ),
              ),
              if (opportunity.closedAt != null)
                Expanded(
                  child: _DateRow(
                    icon: Icons.event_rounded,
                    label: t.facts.closedAt,
                    value: Formatters.crmDate(opportunity.closedAt!),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  bool _isOverdue(Opportunity o) =>
      o.status == OpportunityStatus.open &&
      o.expectedCloseDate.isBefore(
        DateTime.now().copyWith(
          hour: 0,
          minute: 0,
          second: 0,
          millisecond: 0,
          microsecond: 0,
        ),
      );
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final OpportunityStatus status;

  @override
  Widget build(BuildContext context) {
    final t = context.t.crm.crmOpportunities.detail;

    final (label, type) = switch (status) {
      OpportunityStatus.open => (t.statusOpen, AppStatus.info),
      OpportunityStatus.won => (t.statusWon, AppStatus.success),
      OpportunityStatus.lost => (t.statusLost, AppStatus.error),
      OpportunityStatus.unknown => (t.statusOpen, AppStatus.neutral),
    };

    return StatusBadge(label: label, status: type);
  }
}

class _StageChip extends StatelessWidget {
  const _StageChip({required this.stage});

  final OpportunityStage stage;

  @override
  Widget build(BuildContext context) {
    final t = context.t.crm.crmOpportunities.detail;
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: AppRadius.borderSm,
      ),
      child: Text(
        _stageLabel(stage, t),
        style: context.textStyles.labelSmall.copyWith(
          color: colors.textSecondary,
        ),
      ),
    );
  }

  String _stageLabel(OpportunityStage stage, dynamic t) => switch (stage) {
    OpportunityStage.lead => t.stage.lead,
    OpportunityStage.qualified => t.stage.qualified,
    OpportunityStage.proposal => t.stage.proposal,
    OpportunityStage.negotiation => t.stage.negotiation,
    OpportunityStage.closed => t.stage.closed,
    OpportunityStage.unknown => t.stage.all,
  };
}

class _DateRow extends StatelessWidget {
  const _DateRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isOverdue = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isOverdue;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textStyles.labelSmall.copyWith(color: colors.textSecondary),
        ),
        SizedBox(height: AppSpacing.xxs),
        Row(
          children: [
            Icon(
              icon,
              size: OpportunityLayoutConstants.overviewIconSize,
              color: colors.textSecondary,
            ),
            SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                value,
                style: textStyles.bodyMedium.copyWith(
                  color: isOverdue ? colors.error : colors.textPrimary,
                  fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isOverdue) ...[
              SizedBox(width: AppSpacing.xs),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: colors.errorContainer,
                  borderRadius: AppRadius.borderSm,
                ),
                child: Text(
                  context.t.crm.crmOpportunities.card.overdue,
                  style: textStyles.labelSmall.copyWith(
                    color: colors.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
