import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/features/opportunities/data/models/embedded_note_model.dart';
import 'package:orbit/features/opportunities/domain/entities/embedded_customer_note_entity.dart';

void main() {
  group('EmbeddedNoteModel', () {
    test('should map from JSON', () {
      final model = EmbeddedNoteModel.fromJson(<String, dynamic>{
        'note_id': 10,
        'employee_id': 1,
        'employee_name': 'Omar Mohammed',
        'note_text': 'Follow up next week.',
        'created_at': '2026-10-31T13:36:45.675049Z',
      });

      expect(model.noteId, 10);
      expect(model.employeeId, 1);
      expect(model.employeeName, 'Omar Mohammed');
      expect(model.noteText, 'Follow up next week.');
    });

    test('should convert to entity', () {
      final model = EmbeddedNoteModel.fromJson(<String, dynamic>{
        'note_id': 10,
        'employee_id': 1,
        'employee_name': 'Omar Mohammed',
        'note_text': 'Follow up next week.',
        'created_at': '2026-10-31T13:36:45.675049Z',
      });

      final entity = model.toEntity();
      expect(entity, isA<EmbeddedCustomerNote>());
      expect(entity.noteId, 10);
    });
  });
}
