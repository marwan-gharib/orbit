import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/services/crm_data_change.dart';
import 'package:orbit/core/utils/api_result.dart';

import 'package:orbit/features/customer_notes/data/datasources/remote/customer_notes_remote_data_source.dart';
import 'package:orbit/features/customer_notes/data/models/customer_notes_response_model.dart';
import 'package:orbit/features/customer_notes/data/repositories/customer_notes_repository_impl.dart';
import 'package:orbit/features/customer_notes/domain/params/add_customer_note_params.dart';
import 'package:orbit/features/customer_notes/domain/params/update_customer_note_params.dart';

import '../../customer_notes_test_mocks.dart';

class _MockCustomerNotesRemoteDataSource extends Mock
    implements CustomerNotesRemoteDataSource {}

void main() {
  setUpAll(registerCustomerNotesFallbacks);

  late _MockCustomerNotesRemoteDataSource remote;
  late MockCrmDataChangeService changeService;
  late CustomerNotesRepositoryImpl repository;

  Map<String, dynamic> notesResponse(List<Map<String, dynamic>> notes) =>
      <String, dynamic>{
        'customer_id': 7,
        'total': notes.length,
        'notes': notes,
      };

  setUp(() {
    remote = _MockCustomerNotesRemoteDataSource();
    changeService = MockCrmDataChangeService();
    repository = CustomerNotesRepositoryImpl(remote, changeService);
  });

  test('getCustomerNotes sorts newest-first then id desc', () async {
    when(() => remote.fetchCustomerNotes(any())).thenAnswer(
      (_) async => Success(
        CustomerNotesResponseModel.fromJson(
          notesResponse([
            tCustomerNoteJson(id: 1, date: '2026-10-31T13:36:00Z'),
            tCustomerNoteJson(id: 2, date: '2026-10-31T13:36:45Z'),
            tCustomerNoteJson(id: 3, date: '2026-10-31T13:36:45Z'),
          ]),
        ),
      ),
    );

    final result = await repository.getCustomerNotes(7);

    expect(result.isSuccess, isTrue);
    final notes = result.dataOrNull!.notes;
    expect(notes.map((n) => n.noteId), [3, 2, 1]);
    verifyNever(() => changeService.publish(any()));
  });

  test('addCustomerNote publishes CrmDataChange on success only', () async {
    when(() => remote.addCustomerNote(any()))
        .thenAnswer((_) async => const Success(null));

    final result = await repository.addCustomerNote(
      const AddCustomerNoteParams(customerId: 7, noteText: 'New note.'),
    );

    expect(result.isSuccess, isTrue);
    verify(
      () => changeService.publish(
        const CrmDataChange(kind: CrmDataKind.note, customerId: 7),
      ),
    );
  });

  test('addCustomerNote does not publish on failure', () async {
    when(() => remote.addCustomerNote(any())).thenAnswer(
      (_) async => ResultFailure<void>(UnauthorizedFailure(message: 'x')),
    );

    final result = await repository.addCustomerNote(
      const AddCustomerNoteParams(customerId: 7, noteText: 'New note.'),
    );

    expect(result.isFailure, isTrue);
    verifyNever(() => changeService.publish(any()));
  });

  test(
    'updateCustomerNote publishes CrmDataChange with customerId on success',
    () async {
      when(() => remote.updateCustomerNote(any()))
          .thenAnswer((_) async => const Success(null));

      final result = await repository.updateCustomerNote(
        const UpdateCustomerNoteParams(noteId: 1, noteText: 'Updated.'),
        customerId: 7,
      );

      expect(result.isSuccess, isTrue);
      verify(
        () => changeService.publish(
          const CrmDataChange(kind: CrmDataKind.note, customerId: 7),
        ),
      );
    },
  );

  test(
    'deleteCustomerNote publishes CrmDataChange with customerId on success',
    () async {
      when(() => remote.deleteCustomerNote(any()))
          .thenAnswer((_) async => const Success(null));

      final result = await repository.deleteCustomerNote(1, customerId: 7);

      expect(result.isSuccess, isTrue);
      verify(
        () => changeService.publish(
          const CrmDataChange(kind: CrmDataKind.note, customerId: 7),
        ),
      );
    },
  );
}
