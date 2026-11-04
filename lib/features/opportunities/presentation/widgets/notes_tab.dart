import 'package:flutter/material.dart';

import 'package:orbit/features/customer_notes/presentation/widgets/customer_note_composer.dart';
import 'package:orbit/features/customer_notes/presentation/widgets/customer_notes_thread.dart';
import 'package:orbit/features/opportunities/domain/entities/opportunity_entity.dart';

/// Notes tab showing the notes thread and composer.
class NotesTab extends StatelessWidget {
  const NotesTab({
    super.key,
    required this.opportunity,
  });

  final Opportunity opportunity;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Notes thread
        Expanded(
          child: CustomerNotesThread(customerId: opportunity.customer.customerId),
        ),
        // Composer as bottom bar
        CustomerNoteComposer(customerId: opportunity.customer.customerId),
      ],
    );
  }
}