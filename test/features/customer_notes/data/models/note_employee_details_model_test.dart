import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/features/customer_notes/data/models/note_employee_details_model.dart';
import 'package:orbit/features/customer_notes/domain/entities/note_employee_details_entity.dart';

void main() {
  group('NoteEmployeeDetailsModel', () {
    test('should map from JSON', () {
      final model = NoteEmployeeDetailsModel.fromJson(<String, dynamic>{
        'employee_id': 1,
        'employee_code': 'EMP001',
        'name': 'Omar Mohammed',
        'work_email': 'omar@example.com',
      });

      expect(model.employeeId, 1);
      expect(model.employeeCode, 'EMP001');
      expect(model.name, 'Omar Mohammed');
      expect(model.workEmail, 'omar@example.com');
    });

    test('should convert to entity', () {
      final model = NoteEmployeeDetailsModel.fromJson(<String, dynamic>{
        'employee_id': 1,
        'employee_code': 'EMP001',
        'name': 'Omar Mohammed',
        'work_email': 'omar@example.com',
      });

      final entity = model.toEntity();

      expect(entity, isA<NoteEmployeeDetails>());
      expect(entity.employeeId, 1);
      expect(entity.employeeCode, 'EMP001');
      expect(entity.name, 'Omar Mohammed');
      expect(entity.workEmail, 'omar@example.com');
    });
  });
}
