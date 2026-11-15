import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/features/interactions/domain/enums/interaction_type.dart';
import 'package:orbit/features/opportunities/data/models/embedded_interaction_model.dart';
import 'package:orbit/features/opportunities/domain/entities/embedded_customer_interaction_entity.dart';

void main() {
  group('EmbeddedInteractionModel', () {
    test('should map from JSON', () {
      final model = EmbeddedInteractionModel.fromJson(<String, dynamic>{
        'interaction_id': 1,
        'employee_id': 22,
        'employee_name': 'Omar Mohammed',
        'type': 'meeting',
        'subject': 'Requirements analysis',
        'description': 'To fetch the reqs',
        'interaction_date': '2006-10-14T00:00:00Z',
        'contact_id': null,
        'opportunity_id': null,
      });

      expect(model.interactionId, 1);
      expect(model.employeeId, 22);
      expect(model.employeeName, 'Omar Mohammed');
      expect(model.type, InteractionType.meeting);
      expect(model.subject, 'Requirements analysis');
      expect(model.description, 'To fetch the reqs');
      expect(model.contactId, isNull);
      expect(model.opportunityId, isNull);
    });

    test('should map unknown type to unknown', () {
      final model = EmbeddedInteractionModel.fromJson(<String, dynamic>{
        'interaction_id': 1,
        'employee_id': 22,
        'employee_name': 'Omar',
        'type': 'unknown_type',
        'subject': 'S',
        'description': 'D',
        'interaction_date': '2006-10-14T00:00:00Z',
      });

      expect(model.type, InteractionType.unknown);
    });

    test('should convert to entity', () {
      final model = EmbeddedInteractionModel.fromJson(<String, dynamic>{
        'interaction_id': 1,
        'employee_id': 22,
        'employee_name': 'Omar Mohammed',
        'type': 'call',
        'subject': 'Call',
        'description': 'Discussion',
        'interaction_date': '2006-10-14T00:00:00Z',
      });

      final entity = model.toEntity();
      expect(entity, isA<EmbeddedCustomerInteraction>());
      expect(entity.type, InteractionType.call);
    });
  });
}
