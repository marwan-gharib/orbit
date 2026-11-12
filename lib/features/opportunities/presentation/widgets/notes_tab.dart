import 'package:flutter/material.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/features/customer_notes/presentation/cubits/customer_notes_list/customer_notes_list_cubit.dart';
import 'package:orbit/features/customer_notes/presentation/widgets/customer_notes_thread.dart';
import 'package:orbit/features/opportunities/domain/entities/opportunity_entity.dart';

/// Notes tab showing the customer notes thread, inset from the screen edges.
/// The [cubit] belongs to the detail page, so the loaded notes survive tab
/// switches.
class NotesTab extends StatelessWidget {
  const NotesTab({super.key, required this.opportunity, required this.cubit});

  final Opportunity opportunity;
  final CustomerNotesListCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: CustomerNotesThread(
        customerId: opportunity.customer.customerId,
        cubit: cubit,
      ),
    );
  }
}
