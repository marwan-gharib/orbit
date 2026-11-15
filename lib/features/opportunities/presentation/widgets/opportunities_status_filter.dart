import 'package:flutter/material.dart';
import 'package:orbit/core/animations/selection/selection.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_radius.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/features/opportunities/domain/enums/opportunity_status.dart';

/// Status filter (All / Open / Won / Lost) shown right under the stage chips.
///
/// Drawn as a full-width segmented control (a rounded track with one sliding
/// pill) so it reads differently from the scrolling stage chips above it.
/// `null` is the "All" value.
class OpportunitiesStatusFilter extends StatelessWidget {
  const OpportunitiesStatusFilter({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final OpportunityStatus? selected;
  final ValueChanged<OpportunityStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.t.crm.crmOpportunities.status;
    final colors = context.colors;

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: AppSpacing.md,
        end: AppSpacing.md,
        bottom: AppSpacing.sm,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: AppRadius.borderFull,
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.all(AppSpacing.xxs),
          child: AnimatedChipSelector<OpportunityStatus?>(
            selectedValue: selected,
            onChanged: onChanged,
            items: [
              ChipItem<OpportunityStatus?>(
                value: null,
                label: t.all,
                icon: Icons.apps_rounded,
              ),
              ChipItem<OpportunityStatus?>(
                value: OpportunityStatus.open,
                label: t.open,
                icon: Icons.schedule_rounded,
              ),
              ChipItem<OpportunityStatus?>(
                value: OpportunityStatus.won,
                label: t.won,
                icon: Icons.emoji_events_rounded,
              ),
              ChipItem<OpportunityStatus?>(
                value: OpportunityStatus.lost,
                label: t.lost,
                icon: Icons.cancel_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
