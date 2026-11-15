import 'package:flutter/material.dart';
import 'package:orbit/core/animations/feedback/pulse_widget.dart';
import 'package:orbit/core/animations/state/progress_driver.dart';
import 'package:orbit/core/animations/tokens/app_curves.dart';
import 'package:orbit/core/animations/tokens/app_durations.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_radius.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';
import 'package:orbit/features/opportunities/domain/enums/opportunity_stage.dart';
import 'package:orbit/features/opportunities/domain/enums/opportunity_status.dart';
import 'package:orbit/features/opportunities/presentation/constants/opportunity_layout_constants.dart';

/// Five-node pipeline stepper (Lead → Closed).
///
/// On first display the progress line fills up to the current stage and the
/// nodes pop in one after another; while the opportunity is open the current
/// node breathes. Everything is driven by one [ProgressDriver].
class StageStepper extends StatelessWidget {
  const StageStepper({
    super.key,
    required this.currentStage,
    required this.status,
  });

  final OpportunityStage currentStage;
  final OpportunityStatus status;

  static const double _nodeStagger = 0.12;
  static const double _nodeSpan = 0.4;

  @override
  Widget build(BuildContext context) {
    final stages = OpportunityStage.values
        .where((s) => s != OpportunityStage.unknown)
        .toList();
    final currentIndex = stages
        .indexOf(currentStage)
        .clamp(0, stages.length - 1)
        .toInt();
    final labels = context.t.crm.crmOpportunities.stage;
    final colors = context.colors;
    final accent = switch (status) {
      OpportunityStatus.won => colors.success,
      OpportunityStatus.lost => colors.error,
      _ => colors.primary,
    };
    final targetFill = stages.length > 1 ? currentIndex / (stages.length - 1) : 0.0;

    return ProgressDriver(
      duration: AppDurations.extraSlow,
      active: true,
      builder: (context, progress, child) {
        final fill = targetFill * AppCurves.standard.transform(progress);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: OpportunityLayoutConstants.stepperNodeSizeCurrent,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  FractionallySizedBox(
                    widthFactor: (stages.length - 1) / stages.length,
                    child: _Line(fill: fill, accent: accent),
                  ),
                  Row(
                    children: [
                      for (final (i, _) in stages.indexed)
                        Expanded(
                          child: Center(
                            child: Transform.scale(
                              scale: Interval(
                                i * _nodeStagger,
                                i * _nodeStagger + _nodeSpan,
                                curve: AppCurves.spring,
                              ).transform(progress),
                              child: _Node(
                                isDone: i < currentIndex,
                                isCurrent: i == currentIndex,
                                status: status,
                                accent: accent,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                for (final (i, stage) in stages.indexed)
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _label(stage, labels),
                        maxLines: 1,
                        style: context.textStyles.labelSmall.copyWith(
                          color: i == currentIndex
                              ? colors.textPrimary
                              : colors.textSecondary,
                          fontWeight: i == currentIndex
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
      child: const SizedBox.shrink(),
    );
  }

  String _label(
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

class _Line extends StatelessWidget {
  const _Line({required this.fill, required this.accent});

  final double fill;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final height = OpportunityLayoutConstants.stepperConnectorHeight;
    return SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerHighest,
          borderRadius: AppRadius.borderFull,
        ),
        child: FractionallySizedBox(
          alignment: AlignmentDirectional.centerStart,
          widthFactor: fill.clamp(0.0, 1.0),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: accent,
              borderRadius: AppRadius.borderFull,
            ),
          ),
        ),
      ),
    );
  }
}

class _Node extends StatelessWidget {
  const _Node({
    required this.isDone,
    required this.isCurrent,
    required this.status,
    required this.accent,
  });

  final bool isDone;
  final bool isCurrent;
  final OpportunityStatus status;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final size = isCurrent
        ? OpportunityLayoutConstants.stepperNodeSizeCurrent
        : OpportunityLayoutConstants.stepperNodeSize;
    final isOpenCurrent = isCurrent && status == OpportunityStatus.open;
    final filled = isDone || (isCurrent && status != OpportunityStatus.open);

    final IconData? icon = !filled
        ? null
        : (isCurrent && status == OpportunityStatus.lost)
        ? Icons.close_rounded
        : Icons.check_rounded;

    final node = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? accent : colors.surface,
        border: Border.all(
          color: (isCurrent || isDone) ? accent : colors.outline,
          width: OpportunityLayoutConstants.stepperNodeBorderWidth,
        ),
      ),
      child: icon != null
          ? Icon(icon, size: size * 0.6, color: colors.onPrimary)
          : isCurrent
          ? Center(
              child: Container(
                width: size * 0.4,
                height: size * 0.4,
                decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
              ),
            )
          : null,
    );

    return isOpenCurrent ? PulseWidget(active: true, child: node) : node;
  }
}
