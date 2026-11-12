import 'package:flutter/material.dart';
import 'package:orbit/core/animations/selection/selection.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/features/opportunities/domain/enums/opportunity_stage.dart';

/// Horizontal stage filter: "All" + the five pipeline stages, with one sliding
/// indicator. `null` is the "All" value.
class OpportunitiesStageChips extends StatelessWidget {
  const OpportunitiesStageChips({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final OpportunityStage? selected;
  final ValueChanged<OpportunityStage?> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.t.crm.crmOpportunities.stage;

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: AppSpacing.sm,
        end: AppSpacing.sm,
        bottom: AppSpacing.sm,
      ),
      child: AnimatedChipSelector<OpportunityStage?>(
        scrollable: true,
        selectedValue: selected,
        onChanged: onChanged,
        items: [
          ChipItem<OpportunityStage?>(value: null, label: t.all),
          ChipItem<OpportunityStage?>(
            value: OpportunityStage.lead,
            label: t.lead,
          ),
          ChipItem<OpportunityStage?>(
            value: OpportunityStage.qualified,
            label: t.qualified,
          ),
          ChipItem<OpportunityStage?>(
            value: OpportunityStage.proposal,
            label: t.proposal,
          ),
          ChipItem<OpportunityStage?>(
            value: OpportunityStage.negotiation,
            label: t.negotiation,
          ),
          ChipItem<OpportunityStage?>(
            value: OpportunityStage.closed,
            label: t.closed,
          ),
        ],
      ),
    );
  }
}
