import 'package:flutter/material.dart';
import 'package:orbit/core/animations/state/animated_counter.dart';
import 'package:orbit/core/animations/state/progress_driver.dart';
import 'package:orbit/core/animations/tokens/app_curves.dart';
import 'package:orbit/core/animations/tokens/app_durations.dart';
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

/// Current stage + probability ring (sweeps from 0 on first display) above
/// the stage stepper. The probability is the server value, never computed.
class ProgressCard extends StatelessWidget {
  const ProgressCard({super.key, required this.opportunity});

  final Opportunity opportunity;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final t = context.t.crm.crmOpportunities;

    final ringColor = switch (opportunity.status) {
      OpportunityStatus.won => colors.success,
      OpportunityStatus.lost => colors.error,
      _ => colors.primary,
    };

    return AppCard(
      padding: EdgeInsetsDirectional.all(
        OpportunityLayoutConstants.progressCardPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.detail.facts.stage,
                      style: textStyles.labelMedium.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xxs),
                    Text(
                      _stageLabel(opportunity.stage, t.stage),
                      style: textStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.md),
              _ProbabilityRing(
                probability: opportunity.probability,
                color: ringColor,
              ),
            ],
          ),
          SizedBox(height: OpportunityLayoutConstants.progressCardPadding),
          StageStepper(
            currentStage: opportunity.stage,
            status: opportunity.status,
          ),
        ],
      ),
    );
  }

  String _stageLabel(
    OpportunityStage stage,
    Translations$crm$crmOpportunities$stage$en t,
  ) => switch (stage) {
    OpportunityStage.lead => t.lead,
    OpportunityStage.qualified => t.qualified,
    OpportunityStage.proposal => t.proposal,
    OpportunityStage.negotiation => t.negotiation,
    OpportunityStage.closed => t.closed,
    OpportunityStage.unknown => t.all,
  };
}

class _ProbabilityRing extends StatelessWidget {
  const _ProbabilityRing({required this.probability, required this.color});

  final int probability;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final target = (probability / 100).clamp(0.0, 1.0);
    final size = OpportunityLayoutConstants.progressRingSizeLarge;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ProgressDriver(
          duration: AppDurations.extraSlow,
          active: true,
          builder: (context, progress, child) => SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ProgressRing(
                  size: size,
                  progress: target * AppCurves.standard.transform(progress),
                  strokeWidth: OpportunityLayoutConstants.progressRingStrokeWidth,
                  trackColor: colors.surfaceContainerHighest,
                  progressColor: color,
                ),
                AnimatedCounter(
                  value: probability,
                  progress: progress,
                  formatter: (n) => '${n.round()}%',
                  style: context.textStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          child: const SizedBox.shrink(),
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          context.t.crm.crmOpportunities.detail.facts.probability,
          style: context.textStyles.labelSmall.copyWith(
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }
}
