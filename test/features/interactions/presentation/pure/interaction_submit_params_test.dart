import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/features/interactions/domain/enums/interaction_type.dart';
import 'package:orbit/features/interactions/domain/params/add_interaction_params.dart';
import 'package:orbit/features/interactions/domain/params/update_interaction_params.dart';
import 'package:orbit/features/interactions/presentation/pure/interaction_submit_params.dart';
import 'package:orbit/features/interactions/presentation/view_models/interaction_tile_data.dart';

void main() {
  final date = DateTime(2026, 11, 10);

  group('buildInteractionSubmitParams', () {
    test('should build AddInteractionParams in add mode', () {
      final params = buildInteractionSubmitParams(
        mode: SheetMode.add,
        type: InteractionType.call,
        subject: '  Kickoff  ',
        description: '  Agenda  ',
        date: date,
        customerId: 7,
        contactId: 3,
        opportunityId: 9,
      );

      expect(params, isA<AddInteractionParams>());
      final add = params as AddInteractionParams;
      expect(add.type, InteractionType.call);
      expect(add.subject, 'Kickoff');
      expect(add.description, 'Agenda');
      expect(add.interactionDate, date);
      expect(add.customerId, 7);
      expect(add.contactId, 3);
      expect(add.opportunityId, 9);
    });

    test('should build UpdateInteractionParams in edit mode', () {
      final params = buildInteractionSubmitParams(
        mode: SheetMode.edit,
        type: InteractionType.meeting,
        subject: 'Review',
        description: 'Notes',
        date: date,
        editData: InteractionEditData(
          interactionId: 42,
          type: InteractionType.call,
          subject: 'Old',
          description: 'Old desc',
          date: date,
        ),
      );

      expect(params, isA<UpdateInteractionParams>());
      final update = params as UpdateInteractionParams;
      expect(update.interactionId, 42);
      expect(update.type, InteractionType.meeting);
      expect(update.subject, 'Review');
      expect(update.description, 'Notes');
      expect(update.interactionDate, date);
    });
  });
}
