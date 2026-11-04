import 'package:flutter/material.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';
import 'package:orbit/features/opportunities/domain/enums/opportunity_stage.dart';
import 'package:orbit/features/opportunities/domain/enums/opportunity_status.dart';
import 'package:orbit/features/opportunities/presentation/constants/opportunity_layout_constants.dart';

/// 5-node stage stepper with connector lines.
/// Nodes: Lead → Qualified → Proposal → Negotiation → Closed
class StageStepper extends StatelessWidget {
  const StageStepper({
    super.key,
    required this.currentStage,
    required this.status,
  });

  final OpportunityStage currentStage;
  final OpportunityStatus status;

  @override
  Widget build(BuildContext context) {
    final stages = OpportunityStage.values
        .where((s) => s != OpportunityStage.unknown)
        .toList();
    final currentIndex = stages.indexOf(currentStage);
    final isLost = status == OpportunityStatus.lost;
    final isWon = status == OpportunityStatus.won;

    final colors = _StepperColors(
      completed: isWon ? context.colors.success : context.colors.primary,
      current: isLost
          ? context.colors.error
          : (isWon ? context.colors.success : context.colors.primary),
      upcoming: context.colors.outline,
      lost: context.colors.error,
    );

    return Row(
      children: List.generate(stages.length * 2 - 1, (index) {
        if (index.isEven) {
          // Node
          final stageIndex = index ~/ 2;
          final stage = stages[stageIndex];
          final isCurrent = stageIndex == currentIndex;
          final isCompleted =
              stageIndex < currentIndex || (isCurrent && (isWon || isLost));
          final isLostStage = isLost && stage == OpportunityStage.closed;

          return _StageNode(
            stage: stage,
            isCompleted: isCompleted,
            isCurrent: isCurrent,
            isLost: isLostStage,
            colors: colors,
            label: _stageLabelShort(stage),
          );
        } else {
          // Connector
          final connectorIndex = index ~/ 2;
          final isCompleted =
              connectorIndex < currentIndex ||
              (connectorIndex == currentIndex && (isWon || isLost));
          final isLostConnector =
              isLost &&
              connectorIndex >= stages.indexOf(OpportunityStage.closed) - 1;

          return _Connector(
            isCompleted: isCompleted,
            isLost: isLostConnector,
            colors: colors,
          );
        }
      }),
    );
  }

  String _stageLabelShort(OpportunityStage stage) => switch (stage) {
    OpportunityStage.lead => 'L',
    OpportunityStage.qualified => 'Q',
    OpportunityStage.proposal => 'P',
    OpportunityStage.negotiation => 'N',
    OpportunityStage.closed => 'C',
    OpportunityStage.unknown => '?',
  };
}

class _StepperColors {
  const _StepperColors({
    required this.completed,
    required this.current,
    required this.upcoming,
    required this.lost,
  });

  final Color completed;
  final Color current;
  final Color upcoming;
  final Color lost;
}

class _StageNode extends StatelessWidget {
  const _StageNode({
    required this.stage,
    required this.isCompleted,
    required this.isCurrent,
    required this.isLost,
    required this.colors,
    required this.label,
  });

  final OpportunityStage stage;
  final bool isCompleted;
  final bool isCurrent;
  final bool isLost;
  final _StepperColors colors;
  final String label;

  @override
  Widget build(BuildContext context) {
    final nodeSize = isCurrent
        ? OpportunityLayoutConstants.stepperNodeSizeCurrent
        : OpportunityLayoutConstants.stepperNodeSize;

    Color nodeColor;
    Color borderColor;
    Widget? centerWidget;

    if (isLost) {
      nodeColor = colors.lost;
      borderColor = colors.lost;
      centerWidget = Icon(
        Icons.close_rounded,
        size: nodeSize * 0.5,
        color: Colors.white,
      );
    } else if (isCompleted) {
      nodeColor = colors.completed;
      borderColor = colors.completed;
      centerWidget = Icon(
        Icons.check_rounded,
        size: nodeSize * 0.5,
        color: Colors.white,
      );
    } else if (isCurrent) {
      nodeColor = Colors.transparent;
      borderColor = colors.current;
      centerWidget = null;
    } else {
      nodeColor = Colors.transparent;
      borderColor = colors.upcoming;
      centerWidget = null;
    }

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: nodeSize,
            height: nodeSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ring for current node
                if (isCurrent && !isLost)
                  SizedBox(
                    width: nodeSize,
                    height: nodeSize,
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth:
                          OpportunityLayoutConstants.progressRingStrokeWidth,
                      valueColor: AlwaysStoppedAnimation(colors.current),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                // Node circle
                Container(
                  width: nodeSize,
                  height: nodeSize,
                  decoration: BoxDecoration(
                    color: nodeColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: borderColor,
                      width: isCurrent
                          ? OpportunityLayoutConstants.progressRingStrokeWidth
                          : 2,
                    ),
                  ),
                  child: centerWidget != null
                      ? Center(child: centerWidget)
                      : null,
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: context.textStyles.labelSmall.copyWith(
              fontSize: 10,
              color: context.colors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _Connector extends StatelessWidget {
  const _Connector({
    required this.isCompleted,
    required this.isLost,
    required this.colors,
  });

  final bool isCompleted;
  final bool isLost;
  final _StepperColors colors;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: OpportunityLayoutConstants.stepperConnectorHeight,
        margin: EdgeInsets.symmetric(
          vertical: OpportunityLayoutConstants.stepperNodeSizeCurrent / 2,
        ),
        decoration: BoxDecoration(
          color: isLost
              ? colors.lost
              : isCompleted
              ? colors.completed
              : colors.upcoming,
          borderRadius: BorderRadius.circular(
            OpportunityLayoutConstants.stepperConnectorHeight / 2,
          ),
        ),
      ),
    );
  }
}
