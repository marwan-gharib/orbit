import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/features/customer_notes/data/models/customer_notes_response_model.dart';
import 'package:orbit/features/customer_notes/domain/entities/customer_note_entity.dart';

import '../../customer_notes_test_mocks.dart';

void main() {
  group('CustomerNotesResponseModel', () {
    test('should map from JSON', () {
      final model = CustomerNotesResponseModel.fromJson(<String, dynamic>{
        'customer_id': 7,
        'total': 2,
        'notes': [tCustomerNoteJson()],
      });

      expect(model.customerId, 7);
      expect(model.total, 2);
      expect(model.notes, hasLength(1));
      expect(model.notes.first.noteId, 1);
    });

    test('should throw when notes root is not a list', () {
      expect(
        () => CustomerNotesResponseModel.fromJson(<String, dynamic>{
          'customer_id': 7,
          'total': 0,
          'notes': 'not a list',
        }),
        throwsFormatException,
      );
    });

    test('should convert to entity', () {
      final model = CustomerNotesResponseModel.fromJson(<String, dynamic>{
        'customer_id': 7,
        'total': 2,
        'notes': [tCustomerNoteJson()],
      });

      final entity = model.toEntity();

      expect(entity.notes, hasLength(1));
      expect(entity.total, 2);
      expect(entity.notes.first, isA<CustomerNote>());
    });
  });
}
