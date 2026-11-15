import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/features/opportunities/data/models/contact_model.dart';
import 'package:orbit/features/opportunities/data/models/embedded_interaction_model.dart';
import 'package:orbit/features/opportunities/data/models/embedded_note_model.dart';
import 'package:orbit/features/opportunities/data/models/opportunity_customer_model.dart';

import '../../opportunities_test_mocks.dart';

void main() {
  group('OpportunityCustomerModel', () {
    test('should map from JSON', () {
      final model = OpportunityCustomerModel.fromJson(tCustomerJson());

      expect(model.customerId, 1);
      expect(model.customerCode, 'CUS-2026-9973');
      expect(model.firstName, 'Omar');
      expect(model.lastName, 'Ibrahim');
      expect(model.phone, '01144130977');
      expect(model.companyName, 'PWC');
      expect(model.email, 'omar@gmail.com');
      expect(model.address, 'Cairo');
      expect(model.leadSource, isNull);
      expect(model.createdAt, DateTime.utc(2026, 10, 15));
      expect(model.updatedAt, DateTime.utc(2026, 10, 15));
      expect(model.contacts, isEmpty);
      expect(model.notes, isEmpty);
      expect(model.interactions, isEmpty);
    });

    test('should map the embedded contact, note and interaction lists', () {
      final json = tCustomerJson()
        ..[ApiKeys.contactsRootKey] = [
          {
            ApiKeys.contactIdKey: 5,
            ApiKeys.nameKey: 'Hana Adel',
            ApiKeys.jobTitleKey: 'CTO',
            ApiKeys.emailKey: 'hana@pwc.com',
            ApiKeys.phoneKey: '01000000000',
            ApiKeys.isPrimaryKey: true,
          },
        ]
        ..[ApiKeys.notesRootKey] = [
          {
            ApiKeys.noteIdKey: 7,
            ApiKeys.employeeIdKey: 22,
            ApiKeys.employeeNameKey: 'Omar Mohammed',
            ApiKeys.noteTextKey: 'Scope agreed',
            ApiKeys.createdAtKey: '2026-10-20T09:00:00Z',
          },
        ]
        ..[ApiKeys.interactionsRootKey] = [
          {
            ApiKeys.interactionIdKey: 11,
            ApiKeys.employeeIdKey: 22,
            ApiKeys.employeeNameKey: 'Omar Mohammed',
            ApiKeys.typeKey: 'call',
            ApiKeys.subjectKey: 'Sync meeting',
            ApiKeys.descriptionKey: 'Notes',
            ApiKeys.interactionDateKey: '2025-06-01T00:00:00.000Z',
            ApiKeys.opportunityIdKey: 9,
          },
        ];

      final model = OpportunityCustomerModel.fromJson(json);

      expect(model.contacts.single.contactId, 5);
      expect(model.notes.single.noteId, 7);
      expect(model.notes.single.employeeId, 22);
      expect(model.interactions.single.interactionId, 11);
      expect(model.interactions.single.opportunityId, 9);
    });

    test('should default missing optional strings to empty values', () {
      final json = tCustomerJson()
        ..remove(ApiKeys.customerCodeKey)
        ..remove(ApiKeys.firstNameKey)
        ..remove(ApiKeys.lastNameKey)
        ..remove(ApiKeys.phoneKey)
        ..remove(ApiKeys.companyNameKey)
        ..remove(ApiKeys.emailKey)
        ..remove(ApiKeys.addressKey)
        ..remove(ApiKeys.leadSourceKey);

      final model = OpportunityCustomerModel.fromJson(json);

      expect(model.customerCode, '');
      expect(model.firstName, '');
      expect(model.lastName, '');
      expect(model.phone, '');
      expect(model.companyName, '');
      expect(model.email, '');
      expect(model.address, '');
      expect(model.leadSource, isNull);
    });

    test('should skip non-map list entries defensively', () {
      final json = tCustomerJson()
        ..[ApiKeys.contactsRootKey] = ['not a map', 42]
        ..[ApiKeys.interactionsRootKey] = 'broken';

      final model = OpportunityCustomerModel.fromJson(json);

      // Non-map entries are dropped; an entirely wrong shape degrades to an
      // empty list. Map entries missing a required key still crash loudly
      // (null-cast) — that is the deliberate contract for required fields.
      expect(model.contacts, isEmpty);
      expect(model.interactions, isEmpty);
    });

    test('should convert to entity with mapped children', () {
      final json = tCustomerJson()
        ..[ApiKeys.contactsRootKey] = [
          {
            ApiKeys.contactIdKey: 5,
            ApiKeys.nameKey: 'Hana Adel',
            ApiKeys.jobTitleKey: 'CTO',
            ApiKeys.emailKey: 'hana@pwc.com',
            ApiKeys.phoneKey: '01000000000',
            ApiKeys.isPrimaryKey: true,
          },
        ]
        ..[ApiKeys.interactionsRootKey] = [
          {
            ApiKeys.interactionIdKey: 11,
            ApiKeys.employeeIdKey: 22,
            ApiKeys.employeeNameKey: 'Omar Mohammed',
            ApiKeys.typeKey: 'call',
            ApiKeys.subjectKey: 'Sync meeting',
            ApiKeys.descriptionKey: 'Notes',
            ApiKeys.interactionDateKey: '2025-06-01T00:00:00.000Z',
          },
        ];

      final entity = OpportunityCustomerModel.fromJson(json).toEntity();

      expect(entity.customerId, 1);
      expect(entity.customerCode, 'CUS-2026-9973');
      expect(entity.contacts.single.contactId, 5);
      expect(entity.interactions.single.interactionId, 11);
      expect(entity.notes, isEmpty);
    });

    test('should type the embedded collections to their models', () {
      final model = OpportunityCustomerModel.fromJson(tCustomerJson());

      expect(model.contacts, isA<List<ContactModel>>());
      expect(model.notes, isA<List<EmbeddedNoteModel>>());
      expect(model.interactions, isA<List<EmbeddedInteractionModel>>());
    });
  });
}
