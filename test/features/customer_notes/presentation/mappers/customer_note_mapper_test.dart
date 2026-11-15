import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/features/customer_notes/domain/entities/customer_note_entity.dart';
import 'package:orbit/features/customer_notes/domain/entities/note_employee_details_entity.dart';
import 'package:orbit/features/customer_notes/presentation/mappers/customer_note_mapper.dart';
import 'package:orbit/features/customer_notes/presentation/view_models/customer_note_view_model.dart';

import '../../customer_notes_test_mocks.dart';

void main() {
  group('CustomerNoteMapper', () {
    test('should map every rendered field from the entity', () {
      final note = tCustomerNote(id: 9, noteText: 'Call back about pricing.');

      final viewModel = note.toViewModel();

      expect(
        viewModel,
        CustomerNoteViewModel(
          noteId: 9,
          customerId: 7,
          authorName: 'Omar Mohammed',
          initials: 'OM',
          text: 'Call back about pricing.',
          createdAt: DateTime.utc(2026, 10, 31, 13, 36, 45),
        ),
      );
    });

    test('should use the employee name as the author', () {
      final viewModel = tCustomerNote().toViewModel();

      expect(viewModel.authorName, 'Omar Mohammed');
    });

    test('should fall back to a placeholder when the author name is blank', () {
      final note = CustomerNote(
        noteId: 1,
        customerId: 7,
        employeeId: 1,
        noteText: 'Follow up.',
        createdAt: DateTime.utc(2026, 10, 31),
        customerDetails: tCustomerDetails(),
        employeeDetails: const NoteEmployeeDetails(
          employeeId: 1,
          employeeCode: 'EMP001',
          name: '   ',
          workEmail: 'omar@example.com',
        ),
      );

      expect(note.toViewModel().initials, '?');
    });
  });
}
