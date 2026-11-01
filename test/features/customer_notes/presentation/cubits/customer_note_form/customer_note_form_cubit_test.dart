import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/utils/api_result.dart';

import 'package:orbit/features/customer_notes/domain/params/add_customer_note_params.dart';
import 'package:orbit/features/customer_notes/domain/params/update_customer_note_params.dart';
import 'package:orbit/features/customer_notes/domain/usecases/add_customer_note_usecase.dart';
import 'package:orbit/features/customer_notes/domain/usecases/update_customer_note_usecase.dart';
import 'package:orbit/features/customer_notes/presentation/cubits/customer_note_form/customer_note_form_cubit.dart';
import 'package:orbit/features/customer_notes/presentation/cubits/customer_note_form/customer_note_form_state.dart';

import '../../../customer_notes_test_mocks.dart';

class _MockAddCustomerNoteUseCase extends Mock
    implements AddCustomerNoteUseCase {}

class _MockUpdateCustomerNoteUseCase extends Mock
    implements UpdateCustomerNoteUseCase {}

void main() {
  setUpAll(registerCustomerNotesFallbacks);

  late _MockAddCustomerNoteUseCase addCustomerNote;
  late _MockUpdateCustomerNoteUseCase updateCustomerNote;

  setUp(() {
    addCustomerNote = _MockAddCustomerNoteUseCase();
    updateCustomerNote = _MockUpdateCustomerNoteUseCase();
  });

  CustomerNoteFormCubit newCubit({
    AddCustomerNoteUseCase? a,
    UpdateCustomerNoteUseCase? u,
  }) =>
      CustomerNoteFormCubit(
        a ?? addCustomerNote,
        u ?? updateCustomerNote,
      );

  test('should have CustomerNoteFormInitial as the initial state', () {
    expect(newCubit().state, isA<CustomerNoteFormInitial>());
  });

  test('startAdd should emit Ready with no existing note', () {
    final cubit = newCubit();
    cubit.startAdd();

    expect(
      cubit.state,
      isA<CustomerNoteFormReady>().having((s) => s.existing, 'existing', isNull),
    );
  });

  test('startEdit should emit Ready with the existing note', () {
    final cubit = newCubit();
    final note = tCustomerNote();

    cubit.startEdit(note);

    expect(
      cubit.state,
      isA<CustomerNoteFormReady>().having(
        (s) => s.existing,
        'existing',
        note,
      ),
    );
  });

  test('submitNew should emit Submitting then Success', () async {
    when(() => addCustomerNote(any()))
        .thenAnswer((_) async => const Success(null));

    final cubit = newCubit();
    cubit.startAdd();

    await cubit.submitNew(
      const AddCustomerNoteParams(customerId: 7, noteText: 'New note.'),
    );

    expect(
      cubit.state,
      isA<CustomerNoteFormSuccess>().having((s) => s.isEdit, 'isEdit', false),
    );
  });

  test('submitNew should emit Submitting then SubmitError on failure', () async {
    const failure = UnauthorizedFailure(message: 'no session');
    when(() => addCustomerNote(any()))
        .thenAnswer((_) async => ResultFailure<void>(failure));

    final cubit = newCubit();
    cubit.startAdd();

    await cubit.submitNew(
      const AddCustomerNoteParams(customerId: 7, noteText: 'New note.'),
    );

    expect(
      cubit.state,
      isA<CustomerNoteFormSubmitError>().having(
        (s) => s.failure,
        'failure',
        isA<UnauthorizedFailure>(),
      ),
    );
  });

  test('submitUpdate should emit Submitting then Success', () async {
    when(() => updateCustomerNote(any(), customerId: any(named: 'customerId')))
        .thenAnswer((_) async => const Success(null));

    final cubit = newCubit();
    final note = tCustomerNote();
    cubit.startEdit(note);

    await cubit.submitUpdate(
      const UpdateCustomerNoteParams(noteId: 1, noteText: 'Updated.'),
    );

    expect(
      cubit.state,
      isA<CustomerNoteFormSuccess>().having((s) => s.isEdit, 'isEdit', true),
    );
  });

  test('should ignore a second submit while one is in flight', () async {
    final pending = Completer<ApiResult<void>>();
    when(() => addCustomerNote(any())).thenAnswer((_) async => pending.future);

    final cubit = newCubit();
    cubit.startAdd();

    final first = cubit.submitNew(
      const AddCustomerNoteParams(customerId: 7, noteText: 'A.'),
    );
    await Future<void>.delayed(Duration.zero);
    await cubit.submitNew(
      const AddCustomerNoteParams(customerId: 7, noteText: 'B.'),
    );
    pending.complete(const Success(null));
    await first;

    verify(() => addCustomerNote(any())).called(1);
  });
}
