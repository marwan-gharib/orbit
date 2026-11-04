import 'package:flutter/material.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';
import 'package:orbit/core/widgets/app_card.dart';
import 'package:orbit/core/widgets/progress_ring.dart';
import 'package:orbit/features/opportunities/domain/entities/opportunity_entity.dart';
import 'package:orbit/features/opportunities/domain/enums/opportunity_stage.dart';
import 'package:orbit/features/opportunities/domain/enums/opportunity_status.dart';
import 'package:orbit/features/opportunities/presentation/constants/opportunity_layout_constants.dart';
import 'package:orbit/features/opportunities/presentation/widgets/stage_stepper.dart';

/// Progress card showing probability ring and stage stepper.
class ProgressCard extends StatelessWidget {
  const ProgressCard({super.key, required this.opportunity});

  final Opportunity opportunity;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final t = context.t.crm.crmOpportunities.detail;
    final isWon = opportunity.status == OpportunityStatus.won;
    final isLost = opportunity.status == OpportunityStatus.lost;

    final ringColor = isWon
        ? colors.success
        : isLost
        ? colors.error
        : colors.primary;

    return AppCard(
      padding: EdgeInsets.all(OpportunityLayoutConstants.progressCardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Stage label + current stage name
          Row(
            children: [
              Text(
                t.facts.stage,
                style: textStyles.labelLarge.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                _stageLabel(opportunity.stage, t),
                style: textStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              // Probability ring
              _ProbabilityRingLarge(
                probability: opportunity.probability,
                color: ringColor,
              ),
            ],
          ),
          SizedBox(height: OpportunityLayoutConstants.progressCardPadding),

          // Stage stepper
          StageStepper(
            currentStage: opportunity.stage,
            status: opportunity.status,
          ),
        ],
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

class _ProbabilityRingLarge extends StatelessWidget {
  const _ProbabilityRingLarge({required this.probability, required this.color});

  final int probability;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final sweep = (probability / 100).clamp(0.0, 1.0);

    return SizedBox(
      width: OpportunityLayoutConstants.progressRingSizeLarge,
      height: OpportunityLayoutConstants.progressRingSizeLarge,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ProgressRing(
            progress: sweep,
            strokeWidth: OpportunityLayoutConstants.progressRingStrokeWidth,
            trackColor: context.colors.surfaceContainerHighest,
            progressColor: color,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$probability%',
                style: context.textStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              Text(
                context.t.crm.crmOpportunities.detail.facts.probability,
                style: context.textStyles.labelSmall.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
