import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/features/interactions/domain/entities/interaction_entity.dart';
import 'package:orbit/features/interactions/domain/enums/interaction_type.dart';
import 'package:orbit/features/interactions/presentation/mappers/interaction_tile_mapper.dart';

void main() {
  group('buildInteractionTileData', () {
    const interactionId = 1;
    const customerId = 100;
    const employeeId = 50;
    const contactId = 200;
    const opportunityId = 300;
    final date = DateTime(2026, 10, 19);
    const authorName = 'Jane Doe';

    final interaction = Interaction(
      interactionId: interactionId,
      type: InteractionType.meeting,
      subject: 'Quarterly review',
      description: 'Discussed Q4 goals',
      interactionDate: date,
      customerId: customerId,
      employeeId: employeeId,
      contactId: contactId,
      opportunityId: opportunityId,
    );

    test('maps all fields correctly', () {
      final tileData = buildInteractionTileData(
        interaction,
        authorName: authorName,
      );

      expect(tileData.id, interactionId);
      expect(tileData.type, InteractionType.meeting);
      expect(tileData.subject, 'Quarterly review');
      expect(tileData.description, 'Discussed Q4 goals');
      expect(tileData.date, date);
      expect(tileData.authorName, authorName);
      expect(tileData.customerId, customerId);
      expect(tileData.contactId, contactId);
      expect(tileData.opportunityId, opportunityId);
    });

    test('authorName is null when not provided', () {
      final tileData = buildInteractionTileData(interaction);
      expect(tileData.authorName, isNull);
    });

    test('optional fields are preserved', () {
      final interactionNoOptional = Interaction(
        interactionId: 2,
        type: InteractionType.call,
        subject: 'Quick call',
        description: '',
        interactionDate: date,
        customerId: customerId,
        employeeId: employeeId,
        contactId: null,
        opportunityId: null,
      );

      final tileData = buildInteractionTileData(interactionNoOptional);
      expect(tileData.contactId, isNull);
      expect(tileData.opportunityId, isNull);
    });

    test('unknown type is preserved', () {
      final interactionUnknown = Interaction(
        interactionId: 3,
        type: InteractionType.unknown,
        subject: 'Unknown type',
        description: 'Test',
        interactionDate: date,
        customerId: customerId,
        employeeId: employeeId,
      );

      final tileData = buildInteractionTileData(interactionUnknown);
      expect(tileData.type, InteractionType.unknown);
    });
  });
}
