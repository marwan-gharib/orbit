import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/features/customer_notes/data/models/note_model.dart';
import 'package:orbit/features/customer_notes/domain/entities/customer_note_entity.dart';

import '../../customer_notes_test_mocks.dart';

void main() {
  group('NoteModel', () {
    test('should map from JSON', () {
      final model = NoteModel.fromJson(tCustomerNoteJson());

      expect(model.noteId, 1);
      expect(model.customerId, 7);
      expect(model.employeeId, 46);
      expect(model.noteText, 'Follow up next week.');
      expect(model.createdAt, DateTime.utc(2026, 10, 31));
      expect(model.customerDetails.customerId, 7);
      expect(model.employeeDetails.employeeId, 1);
    });

    test('should convert to entity', () {
      final model = NoteModel.fromJson(tCustomerNoteJson());

      final entity = model.toEntity();

      expect(entity, isA<CustomerNote>());
      expect(entity.noteId, 1);
      expect(entity.customerId, 7);
      expect(entity.noteText, 'Follow up next week.');
    });

    test('should tolerate missing optional text fields', () {
      final model = NoteModel.fromJson(<String, dynamic>{
        'note_id': 1,
        'customer_id': 7,
        'employee_id': 1,
        'note_text': null,
        'created_at': '2026-10-31T13:36:45.675049Z',
        'customer_details': <String, dynamic>{
          'customer_id': 7,
          'customer_code': null,
          'name': null,
          'company_name': null,
        },
        'employee_details': <String, dynamic>{
          'employee_id': 1,
          'employee_code': null,
          'name': null,
          'work_email': null,
        },
      });

      expect(model.noteText, '');
      expect(model.customerDetails.customerCode, '');
      expect(model.employeeDetails.employeeCode, '');
    });
  });
}
