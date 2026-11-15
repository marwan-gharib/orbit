import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/services/crm_data_change.dart';
import 'package:orbit/core/services/crm_data_change_service.dart';
import 'package:orbit/features/customer_notes/domain/entities/customer_note_entity.dart';
import 'package:orbit/features/customer_notes/domain/entities/note_customer_details_entity.dart';
import 'package:orbit/features/customer_notes/domain/entities/note_employee_details_entity.dart';
import 'package:orbit/features/customer_notes/domain/params/add_customer_note_params.dart';
import 'package:orbit/features/customer_notes/domain/params/update_customer_note_params.dart';
import 'package:orbit/features/customer_notes/domain/repositories/customer_notes_repository.dart';
import 'package:orbit/features/customer_notes/domain/usecases/add_customer_note_usecase.dart';
import 'package:orbit/features/customer_notes/domain/usecases/delete_customer_note_usecase.dart';
import 'package:orbit/features/customer_notes/domain/usecases/get_customer_notes_usecase.dart';
import 'package:orbit/features/customer_notes/domain/usecases/update_customer_note_usecase.dart';
import 'package:orbit/features/customer_notes/domain/usecases/watch_note_changes_usecase.dart';

class MockCustomerNotesRepository extends Mock
    implements CustomerNotesRepository {}

class MockGetCustomerNotesUseCase extends Mock
    implements GetCustomerNotesUseCase {}

class MockWatchNoteChangesUseCase extends Mock
    implements WatchNoteChangesUseCase {}

class MockCrmDataChangeService extends Mock implements CrmDataChangeService {}

class MockAddCustomerNoteUseCase extends Mock
    implements AddCustomerNoteUseCase {}

class MockUpdateCustomerNoteUseCase extends Mock
    implements UpdateCustomerNoteUseCase {}

class MockDeleteCustomerNoteUseCase extends Mock
    implements DeleteCustomerNoteUseCase {}

/// Registers mocktail fallbacks once for all customer notes tests.
void registerCustomerNotesFallbacks() {
  registerFallbackValue(
    AddCustomerNoteParams(customerId: 1, noteText: 'Follow up.'),
  );
  registerFallbackValue(
    UpdateCustomerNoteParams(noteId: 1, noteText: 'Updated.'),
  );
  registerFallbackValue(
    const CrmDataChange(kind: CrmDataKind.note, customerId: 0),
  );
  registerFallbackValue(tCustomerNote());
}

/// One customer note under test (collection-shaped values).
CustomerNote tCustomerNote({
  int id = 1,
  int customerId = 7,
  String noteText = 'Follow up next week.',
  DateTime? createdAt,
}) => CustomerNote(
  noteId: id,
  customerId: customerId,
  employeeId: 46,
  noteText: noteText,
  createdAt: createdAt ?? DateTime.utc(2026, 10, 31, 13, 36, 45),
  customerDetails: tCustomerDetails(),
  employeeDetails: tEmployeeDetails(),
);

NoteCustomerDetails tCustomerDetails() => NoteCustomerDetails(
  customerId: 7,
  customerCode: 'CUS-2026-9973',
  name: 'Omar Ibrahim',
  companyName: 'PWC',
);

NoteEmployeeDetails tEmployeeDetails() => NoteEmployeeDetails(
  employeeId: 1,
  employeeCode: 'EMP001',
  name: 'Omar Mohammed',
  workEmail: 'omar@example.com',
);

/// Wire shape of one customer note.
Map<String, dynamic> tCustomerNoteJson({
  int id = 1,
  int customerId = 7,
  String noteText = 'Follow up next week.',
  String date = '2026-10-31T13:36:45.675049Z',
}) => <String, dynamic>{
  'note_id': id,
  'customer_id': customerId,
  'employee_id': 46,
  'note_text': noteText,
  'created_at': date,
  'customer_details': <String, dynamic>{
    'customer_id': 7,
    'customer_code': 'CUS-2026-9973',
    'name': 'Omar Ibrahim',
    'company_name': 'PWC',
  },
  'employee_details': <String, dynamic>{
    'employee_id': 1,
    'employee_code': 'EMP001',
    'name': 'Omar Mohammed',
    'work_email': 'omar@example.com',
  },
};

Map<String, dynamic> tNotesResponse(List<Map<String, dynamic>> notes) =>
    <String, dynamic>{'customer_id': 7, 'total': notes.length, 'notes': notes};
