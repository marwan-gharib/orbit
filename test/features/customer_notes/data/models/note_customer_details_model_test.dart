import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/features/customer_notes/data/models/note_customer_details_model.dart';
import 'package:orbit/features/customer_notes/domain/entities/note_customer_details_entity.dart';

void main() {
  group('NoteCustomerDetailsModel', () {
    test('should map from JSON', () {
      final model = NoteCustomerDetailsModel.fromJson(<String, dynamic>{
        'customer_id': 7,
        'customer_code': 'CUS-2026-9973',
        'name': 'Omar Ibrahim',
        'company_name': 'PWC',
      });

      expect(model.customerId, 7);
      expect(model.customerCode, 'CUS-2026-9973');
      expect(model.name, 'Omar Ibrahim');
      expect(model.companyName, 'PWC');
    });

    test('should convert to entity', () {
      final model = NoteCustomerDetailsModel.fromJson(<String, dynamic>{
        'customer_id': 7,
        'customer_code': 'CUS-2026-9973',
        'name': 'Omar Ibrahim',
        'company_name': 'PWC',
      });

      final entity = model.toEntity();

      expect(entity, isA<NoteCustomerDetails>());
      expect(entity.customerId, 7);
      expect(entity.customerCode, 'CUS-2026-9973');
      expect(entity.name, 'Omar Ibrahim');
      expect(entity.companyName, 'PWC');
    });
  });
}
