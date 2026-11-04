import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/utils/api_result.dart';

import 'package:orbit/features/customer_notes/domain/usecases/delete_customer_note_usecase.dart';
import 'package:orbit/features/customer_notes/presentation/cubits/customer_note_delete/customer_note_delete_cubit.dart';
import 'package:orbit/features/customer_notes/presentation/cubits/customer_note_delete/customer_note_delete_state.dart';

import '../../../customer_notes_test_mocks.dart';

class _MockDeleteCustomerNoteUseCase extends Mock
    implements DeleteCustomerNoteUseCase {}

void main() {
  setUpAll(registerCustomerNotesFallbacks);

  late _MockDeleteCustomerNoteUseCase deleteCustomerNote;

  setUp(() {
    deleteCustomerNote = _MockDeleteCustomerNoteUseCase();
  });

  CustomerNoteDeleteCubit newCubit({DeleteCustomerNoteUseCase? d}) =>
      CustomerNoteDeleteCubit(d ?? deleteCustomerNote);

  test('should have CustomerNoteDeleteInitial as the initial state', () {
    expect(newCubit().state, isA<CustomerNoteDeleteInitial>());
  });

  test('delete should emit InProgress then Success', () async {
    when(() => deleteCustomerNote(any(), customerId: any(named: 'customerId')))
        .thenAnswer((_) async => const Success(null));

    final cubit = newCubit();
    final note = tCustomerNote();

    await cubit.delete(note);

    expect(
      cubit.state,
      isA<CustomerNoteDeleteSuccess>().having(
        (s) => s.noteId,
        'noteId',
        note.noteId,
      ),
    );
  });

  test('delete should emit InProgress then Failure', () async {
    const failure = UnauthorizedFailure(message: 'no session');
    when(() => deleteCustomerNote(any(), customerId: any(named: 'customerId')))
        .thenAnswer((_) async => ResultFailure<void>(failure));

    final cubit = newCubit();
    final note = tCustomerNote();

    await cubit.delete(note);

    expect(
      cubit.state,
      isA<CustomerNoteDeleteFailure>()
          .having((s) => s.noteId, 'noteId', note.noteId)
          .having((s) => s.failure, 'failure', isA<UnauthorizedFailure>()),
    );
  });

  test('should ignore a second delete while one is in flight', () async {
    final pending = Completer<ApiResult<void>>();
    when(() => deleteCustomerNote(any(), customerId: any(named: 'customerId')))
        .thenAnswer((_) async => pending.future);

    final cubit = newCubit();
    final note = tCustomerNote();

    final first = cubit.delete(note);
    await Future<void>.delayed(Duration.zero);
    await cubit.delete(note);
    pending.complete(const Success(null));
    await first;

    verify(
      () => deleteCustomerNote(any(), customerId: any(named: 'customerId')),
    ).called(1);
  });
}
