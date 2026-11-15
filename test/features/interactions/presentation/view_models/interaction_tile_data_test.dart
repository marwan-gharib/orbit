import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/features/interactions/domain/enums/interaction_type.dart';
import 'package:orbit/features/interactions/presentation/view_models/interaction_tile_data.dart';

void main() {
  group('InteractionTileData', () {
    const id = 1;
    const type = InteractionType.call;
    const subject = 'Call with client';
    const description = 'Discussed project timeline';
    final date = DateTime(2026, 10, 19);
    const authorName = 'John Doe';
    const customerId = 100;
    const contactId = 200;
    const opportunityId = 300;

    test('props are correct', () {
      final data = InteractionTileData(
        id: id,
        type: type,
        subject: subject,
        description: description,
        date: date,
        authorName: authorName,
        customerId: customerId,
        contactId: contactId,
        opportunityId: opportunityId,
      );

      expect(data.id, id);
      expect(data.type, type);
      expect(data.subject, subject);
      expect(data.description, description);
      expect(data.date, date);
      expect(data.authorName, authorName);
      expect(data.customerId, customerId);
      expect(data.contactId, contactId);
      expect(data.opportunityId, opportunityId);
    });

    test('equality works', () {
      final data1 = InteractionTileData(
        id: id,
        type: type,
        subject: subject,
        description: description,
        date: date,
        authorName: authorName,
        customerId: customerId,
        contactId: contactId,
        opportunityId: opportunityId,
      );

      final data2 = InteractionTileData(
        id: id,
        type: type,
        subject: subject,
        description: description,
        date: date,
        authorName: authorName,
        customerId: customerId,
        contactId: contactId,
        opportunityId: opportunityId,
      );

      expect(data1, equals(data2));
      expect(data1.hashCode, equals(data2.hashCode));
    });

    test('inequality works when fields differ', () {
      final data1 = InteractionTileData(
        id: 1,
        type: type,
        subject: subject,
        description: description,
        date: date,
      );

      final data2 = InteractionTileData(
        id: 2,
        type: type,
        subject: subject,
        description: description,
        date: date,
      );

      expect(data1, isNot(equals(data2)));
    });
  });

  group('InteractionContactOption', () {
    test('props are correct', () {
      const option = InteractionContactOption(id: 5, label: 'Jane Smith');
      expect(option.id, 5);
      expect(option.label, 'Jane Smith');
    });

    test('equality works', () {
      const o1 = InteractionContactOption(id: 5, label: 'Jane Smith');
      const o2 = InteractionContactOption(id: 5, label: 'Jane Smith');
      expect(o1, equals(o2));
    });
  });

  group('InteractionEditData', () {
    const interactionId = 10;
    const type = InteractionType.email;
    const subject = 'Follow up';
    const description = 'Sent proposal';
    final date = DateTime(2026, 10, 20);
    const customerId = 100;
    const opportunityId = 300;

    test('props are correct', () {
      final data = InteractionEditData(
        interactionId: interactionId,
        type: type,
        subject: subject,
        description: description,
        date: date,
        customerId: customerId,
        opportunityId: opportunityId,
      );

      expect(data.interactionId, interactionId);
      expect(data.type, type);
      expect(data.subject, subject);
      expect(data.description, description);
      expect(data.date, date);
      expect(data.customerId, customerId);
      expect(data.opportunityId, opportunityId);
    });

    test('equality works', () {
      final d1 = InteractionEditData(
        interactionId: interactionId,
        type: type,
        subject: subject,
        description: description,
        date: date,
        customerId: customerId,
        opportunityId: opportunityId,
      );

      final d2 = InteractionEditData(
        interactionId: interactionId,
        type: type,
        subject: subject,
        description: description,
        date: date,
        customerId: customerId,
        opportunityId: opportunityId,
      );

      expect(d1, equals(d2));
    });
  });
}
