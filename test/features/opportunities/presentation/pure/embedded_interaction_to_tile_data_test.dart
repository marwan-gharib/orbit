import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/features/interactions/domain/enums/interaction_type.dart';
import 'package:orbit/features/opportunities/domain/entities/customer_contact_entity.dart';
import 'package:orbit/features/opportunities/domain/entities/embedded_customer_interaction_entity.dart';
import 'package:orbit/features/opportunities/presentation/pure/contact_to_interaction_option.dart';
import 'package:orbit/features/opportunities/presentation/pure/embedded_interaction_to_tile_data.dart';

void main() {
  group('embeddedInteractionToTileData', () {
    final fixedDate = DateTime(2026, 3, 15);
    const customerId = 42;
    const opportunityId = 99;

    test('maps all fields correctly', () {
      final embedded = EmbeddedCustomerInteraction(
        interactionId: 10,
        employeeId: 5,
        employeeName: 'Ahmed Ali',
        type: InteractionType.call,
        subject: 'Follow up',
        description: 'Discussed pricing',
        interactionDate: fixedDate,
        contactId: 7,
        opportunityId: 11,
      );

      final tile = embeddedInteractionToTileData(
        embedded,
        customerId: customerId,
        opportunityId: opportunityId,
      );

      expect(tile.id, equals(10));
      expect(tile.type, equals(InteractionType.call));
      expect(tile.subject, equals('Follow up'));
      expect(tile.description, equals('Discussed pricing'));
      expect(tile.date, equals(fixedDate));
      expect(tile.authorName, equals('Ahmed Ali'));
      expect(tile.customerId, equals(customerId));
      expect(tile.contactId, equals(7));
      expect(tile.opportunityId, equals(11));
    });

    test('falls back to opportunityId when embedded opportunityId is null', () {
      final embedded = EmbeddedCustomerInteraction(
        interactionId: 10,
        employeeId: 5,
        employeeName: 'Ahmed Ali',
        type: InteractionType.email,
        subject: 'Proposal sent',
        description: '',
        interactionDate: fixedDate,
        contactId: null,
        opportunityId: null,
      );

      final tile = embeddedInteractionToTileData(
        embedded,
        customerId: customerId,
        opportunityId: opportunityId,
      );

      expect(tile.opportunityId, equals(opportunityId));
      expect(tile.contactId, isNull);
    });
  });

  group('contactToInteractionOption', () {
    test('maps contact to option with id and name', () {
      const contact = CustomerContact(
        contactId: 123,
        name: 'John Doe',
        jobTitle: 'CTO',
        email: 'john@example.com',
        phone: '+15551234567',
        isPrimary: true,
      );

      final option = contactToInteractionOption(contact);

      expect(option.id, equals(123));
      expect(option.label, equals('John Doe'));
    });

    test('works with non-primary contact', () {
      const contact = CustomerContact(
        contactId: 456,
        name: 'Jane Smith',
        jobTitle: 'Manager',
        email: 'jane@example.com',
        phone: '+15557654321',
        isPrimary: false,
      );

      final option = contactToInteractionOption(contact);

      expect(option.id, equals(456));
      expect(option.label, equals('Jane Smith'));
    });
  });
}