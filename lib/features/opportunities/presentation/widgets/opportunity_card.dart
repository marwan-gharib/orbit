import 'package:flutter/material.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_radius.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';
import 'package:orbit/core/utils/formatters.dart';
import 'package:orbit/core/widgets/app_card.dart';
import 'package:orbit/core/widgets/progress_ring.dart';
import 'package:orbit/core/widgets/status_badge.dart';
import 'package:orbit/features/opportunities/domain/entities/opportunity_entity.dart';
import 'package:orbit/features/opportunities/domain/enums/opportunity_stage.dart';
import 'package:orbit/features/opportunities/domain/enums/opportunity_status.dart';
import 'package:orbit/features/opportunities/presentation/constants/opportunity_layout_constants.dart';

/// A single opportunity card in the list.
/// One tap target over the whole surface (Q1).
class OpportunityCard extends StatelessWidget {
  const OpportunityCard({
    super.key,
    required this.opportunity,
    required this.onTap,
  });

  final Opportunity opportunity;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final c = opportunity.customer;
    final isOverdue = _isOverdue(opportunity);

    return AppCard(
      padding: EdgeInsets.all(OpportunityLayoutConstants.cardPadding),
      onTap: () => onTap(opportunity.opportunityId),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row A: Title + Status badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  opportunity.title,
                  style: textStyles.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              _StatusBadge(status: opportunity.status),
            ],
          ),
          SizedBox(height: OpportunityLayoutConstants.cardRowGap),

          // Row B: Customer name + company
          Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: OpportunityLayoutConstants.overviewIconSize,
                color: colors.textSecondary,
              ),
              SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  '${c.firstName} ${c.lastName} \u00b7 ${c.companyName}',
                  style: textStyles.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: OpportunityLayoutConstants.cardDividerGap),
          Divider(height: 1, color: colors.border),
          SizedBox(height: OpportunityLayoutConstants.cardDividerGap),

          // Row C: Estimated value + Probability ring
          Row(
            children: [
              Expanded(
                child: Text(
                  Formatters.money(
                    opportunity.estimatedValue,
                    opportunity.currency,
                  ),
                  style: textStyles.titleMedium.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              _ProbabilityRingSmall(probability: opportunity.probability),
            ],
          ),
          SizedBox(height: OpportunityLayoutConstants.cardRowGap),

          // Row D: Stage chip + Expected close date (+ Overdue tag)
          Row(
            children: [
              _StageChip(stage: opportunity.stage),
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: OpportunityLayoutConstants.overviewIconSize,
                    color: colors.textSecondary,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    Formatters.crmDate(opportunity.expectedCloseDate),
                    style: textStyles.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  if (isOverdue) ...[
                    SizedBox(width: AppSpacing.sm),
                    _OverdueTag(),
                  ],
                ],
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
    final t = context.t.crm.crmOpportunities;

    final (label, type) = switch (status) {
      OpportunityStatus.open => (t.status.open, AppStatus.info),
      OpportunityStatus.won => (t.status.won, AppStatus.success),
      OpportunityStatus.lost => (t.status.lost, AppStatus.error),
      OpportunityStatus.unknown => (t.status.all, AppStatus.neutral),
    };

    return StatusBadge(label: label, status: type);
  }
}

class _ProbabilityRingSmall extends StatelessWidget {
  const _ProbabilityRingSmall({required this.probability});

  final int probability;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sweep = (probability / 100).clamp(0.0, 1.0);

    return SizedBox(
      width: OpportunityLayoutConstants.cardRingSizeSmall,
      height: OpportunityLayoutConstants.cardRingSizeSmall,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ProgressRing(
            progress: sweep,
            strokeWidth: OpportunityLayoutConstants.cardRingStrokeWidth,
            trackColor: colors.border,
            progressColor: colors.primary,
          ),
          Text(
            '$probability%',
            style: context.textStyles.labelSmall.copyWith(
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _StageChip extends StatelessWidget {
  const _StageChip({required this.stage});

  final OpportunityStage stage;

  @override
  Widget build(BuildContext context) {
    final t = context.t.crm.crmOpportunities;
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
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

class _OverdueTag extends StatelessWidget {
  const _OverdueTag();

  @override
  Widget build(BuildContext context) {
    final t = context.t.crm.crmOpportunities;
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: AppRadius.borderSm,
      ),
      child: Text(
        t.card.overdue,
        style: context.textStyles.labelSmall.copyWith(
          color: colors.onErrorContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
