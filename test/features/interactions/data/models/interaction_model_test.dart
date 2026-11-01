import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/features/interactions/domain/enums/interaction_type.dart';
import 'package:orbit/features/interactions/data/models/interaction_model.dart';

import '../../interactions_test_mocks.dart';

void main() {
  test('parses a wire interaction including an instant date', () {
    final model = InteractionModel.fromJson(tInteractionJson(id: 10));

    expect(model.interactionId, 10);
    expect(model.type, InteractionType.call);
    expect(model.subject, 'Sync meeting');
    expect(model.description, 'Notes');
    expect(model.interactionDate, DateTime.utc(2025, 6, 1));
    expect(model.customerId, 7);
    expect(model.employeeId, 46);
    expect(model.contactId, isNull);
    expect(model.opportunityId, isNull);
  });

  test('parses an unknown type to the unknown member without throwing', () {
    final model = InteractionModel.fromJson(
      tInteractionJson(type: 'video', id: 2),
    );

    expect(model.type, InteractionType.unknown);
  });

  test('tolerates a missing description as empty', () {
    final model = InteractionModel.fromJson(
      tInteractionJson(description: null, id: 3),
    );

    expect(model.description, '');
  });

  test('fails the parse for an unparsable interaction_date', () {
    expect(
      () => InteractionModel.fromJson(
        tInteractionJson(date: 'not-a-date', id: 4),
      ),
      throwsFormatException,
    );
  });

  test('maps to the entity unchanged', () {
    final model = InteractionModel.fromJson(tInteractionJson(id: 5));
    final entity = model.toEntity();

    expect(entity.interactionId, model.interactionId);
    expect(entity.type, model.type);
    expect(entity.subject, model.subject);
    expect(entity.description, model.description);
    expect(entity.interactionDate, model.interactionDate);
    expect(entity.customerId, model.customerId);
    expect(entity.employeeId, model.employeeId);
    expect(entity.contactId, model.contactId);
    expect(entity.opportunityId, model.opportunityId);
  });

  test('parses dates-only wire dates as UTC-normalized', () {
    final model = InteractionModel.fromJson(
      tInteractionJson(date: '2025-06-01', id: 6),
    );

    expect(model.interactionDate, DateTime.utc(2025, 6, 1));
    expect(model.interactionDate.isUtc, isTrue);
  });

  test('the wire root key constant stays "Interactions"', () {
    // Capital-I contract from the collection; a rename would break parsing.
    expect(ApiKeys.interactionsRootKey, 'Interactions');
  });
}
