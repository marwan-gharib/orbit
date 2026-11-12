import 'package:flutter/material.dart';
import 'package:orbit/core/animations/staggered/staggered_column.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/features/opportunities/domain/entities/opportunity_entity.dart';
import 'package:orbit/features/opportunities/presentation/widgets/customer_overview_card.dart';
import 'package:orbit/features/opportunities/presentation/widgets/opportunity_details_card.dart';

/// Overview tab: customer card and facts card, revealed one after the other.
class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key, required this.opportunity});

  final Opportunity opportunity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.all(AppSpacing.md),
      child: StaggeredColumn(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomerOverviewCard(opportunity: opportunity),
          SizedBox(height: AppSpacing.lg),
          OpportunityDetailsCard(opportunity: opportunity),
        ],
      ),
    );
  }
}
