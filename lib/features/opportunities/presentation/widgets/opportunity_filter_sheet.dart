import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orbit/core/animations/selection/selection.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';
import 'package:orbit/core/widgets/app_button.dart';
import 'package:orbit/features/opportunities/domain/enums/opportunity_status.dart';
import 'package:orbit/features/opportunities/presentation/blocs/opportunities_list/opportunities_list_bloc.dart';
import 'package:orbit/features/opportunities/presentation/blocs/opportunities_list/opportunities_list_event.dart';

/// Bottom sheet for filtering opportunities by status.
class OpportunityFilterSheet extends StatelessWidget {
  const OpportunityFilterSheet({super.key, required this.currentStatus});

  final OpportunityStatus? currentStatus;

  @override
  Widget build(BuildContext context) {
    final t = context.t.crm.crmOpportunities;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
        top: AppSpacing.lg,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(t.filterTitle, style: context.textStyles.titleMedium),
              TextButton(
                onPressed: () {
                  context.read<OpportunitiesListBloc>().add(
                    const OpportunitiesListFiltersChanged(status: null),
                  );
                  Navigator.pop(context);
                },
                child: Text(t.status.all),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          AnimatedChipSelector<OpportunityStatus?>(
            items: [
              ChipItem<OpportunityStatus?>(
                value: OpportunityStatus.open,
                label: t.status.open,
              ),
              ChipItem<OpportunityStatus?>(
                value: OpportunityStatus.won,
                label: t.status.won,
              ),
              ChipItem<OpportunityStatus?>(
                value: OpportunityStatus.lost,
                label: t.status.lost,
              ),
            ],
            selectedValue: currentStatus,
            onChanged: (status) {
              context.read<OpportunitiesListBloc>().add(
                OpportunitiesListFiltersChanged(status: status),
              );
              Navigator.pop(context);
            },
            scrollable: true,
          ),
          SizedBox(height: AppSpacing.lg),
          AppButton.text(
            label: context.t.crm.common.clearFilters,
            onPressed: () {
              context.read<OpportunitiesListBloc>().add(
                const OpportunitiesListFiltersChanged(status: null),
              );
              Navigator.pop(context);
            },
          ),
          SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}
