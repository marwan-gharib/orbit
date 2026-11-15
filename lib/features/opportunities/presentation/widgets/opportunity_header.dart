import 'package:flutter/material.dart';
import 'package:orbit/core/animations/feedback/pulse_widget.dart';
import 'package:orbit/core/animations/navigation/app_hero.dart';
import 'package:orbit/core/animations/state/animated_counter.dart';
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
import 'package:orbit/features/opportunities/presentation/constants/opportunity_hero_tags.dart';
import 'package:orbit/features/opportunities/presentation/constants/opportunity_layout_constants.dart';

/// Expanded content of the collapsing detail header: title, status + stage,
/// value (counts up on first display) and the expected close date.
///
/// Title, value and status badge are `AppHero`s that pair with the list card.
class OpportunityHeader extends StatelessWidget {
  const OpportunityHeader({super.key, required this.opportunity});

  final Opportunity opportunity;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final t = context.t.crm.crmOpportunities.detail;
    final id = opportunity.opportunityId;

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: OpportunityLayoutConstants.headerPadding,
        end: OpportunityLayoutConstants.headerPadding,
        top: AppSpacing.xs,
        bottom: OpportunityLayoutConstants.headerPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppHero(
            id: OpportunityHeroTag.title(id),
            child: Material(
              type: MaterialType.transparency,
              child: Text(
                opportunity.title,
                style: textStyles.headlineMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          SizedBox(height: OpportunityLayoutConstants.headerRowGap),
          Row(
            children: [
              AppHero(
                id: OpportunityHeroTag.status(id),
                child: _StatusBadge(status: opportunity.status),
              ),
              if (opportunity.status == OpportunityStatus.open) ...[
                SizedBox(width: AppSpacing.xs),
                PulseWidget(
                  active: true,
                  child: Container(
                    width: AppSpacing.sm,
                    height: AppSpacing.sm,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
              SizedBox(width: AppSpacing.sm),
              _StageChip(stage: opportunity.stage),
            ],
          ),
          SizedBox(height: OpportunityLayoutConstants.headerRowGap),
          AppHero(
            id: OpportunityHeroTag.value(id),
            child: Material(
              type: MaterialType.transparency,
              child: AnimatedCounter(
                value: opportunity.estimatedValue,
                formatter: (value) =>
                    Formatters.money(value, opportunity.currency),
                style: textStyles.headlineSmall.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(height: OpportunityLayoutConstants.headerRowGap),
          _DateRow(
            label: t.facts.expectedClose,
            value: Formatters.crmDate(opportunity.expectedCloseDate),
            isOverdue: _isOverdue(opportunity),
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
    final tStages = context.t.crm.crmOpportunities.stage;
    final colors = context.colors;

    return Container(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: AppRadius.borderSm,
      ),
      child: Text(
        _stageLabel(stage, tStages),
        style: context.textStyles.labelSmall.copyWith(
          color: colors.textSecondary,
        ),
      ),
    );
  }

  String _stageLabel(
    OpportunityStage stage,
    Translations$crm$crmOpportunities$stage$en tStages,
  ) => switch (stage) {
    OpportunityStage.lead => tStages.lead,
    OpportunityStage.qualified => tStages.qualified,
    OpportunityStage.proposal => tStages.proposal,
    OpportunityStage.negotiation => tStages.negotiation,
    OpportunityStage.closed => tStages.closed,
    OpportunityStage.unknown => tStages.all,
  };
}

class _DateRow extends StatelessWidget {
  const _DateRow({
    required this.label,
    required this.value,
    required this.isOverdue,
  });

  final String label;
  final String value;
  final bool isOverdue;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final valueColor = isOverdue ? colors.error : colors.textPrimary;

    return Row(
      children: [
        Icon(
          Icons.calendar_today_rounded,
          size: OpportunityLayoutConstants.overviewIconSize,
          color: colors.textSecondary,
        ),
        SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: textStyles.labelMedium.copyWith(color: colors.textSecondary),
        ),
        SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            value,
            style: textStyles.bodyMedium.copyWith(
              color: valueColor,
              fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (isOverdue) ...[
          SizedBox(width: AppSpacing.xs),
          Container(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xxs,
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
    );
  }
}
