import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:orbit/core/utils/api_result.dart';

import '../../../domain/entities/customer_note_entity.dart';
import '../../../domain/params/add_customer_note_params.dart';
import '../../../domain/params/update_customer_note_params.dart';
import '../../../domain/usecases/add_customer_note_usecase.dart';
import '../../../domain/usecases/update_customer_note_usecase.dart';
import 'customer_note_form_state.dart';

/// Drives the note form: one-shot add or edit submit.
class CustomerNoteFormCubit extends Cubit<CustomerNoteFormState> {
  CustomerNoteFormCubit(this._addCustomerNote, this._updateCustomerNote)
    : super(CustomerNoteFormInitial());

  final AddCustomerNoteUseCase _addCustomerNote;
  final UpdateCustomerNoteUseCase _updateCustomerNote;

  CustomerNote? _editingNote;

  void startAdd() {
    _editingNote = null;
    emit(CustomerNoteFormReady(existing: null));
  }

  void startEdit(CustomerNote note) {
    _editingNote = note;
    emit(CustomerNoteFormReady(existing: note));
  }

  Future<void> submitNew(AddCustomerNoteParams params) async {
    if (state is CustomerNoteFormSubmitting) return;
    emit(CustomerNoteFormSubmitting(isEdit: false));

    final result = await _addCustomerNote(params);
    if (isClosed) return;
    _emitOutcome(result, isEdit: false);
  }

  Future<void> submitUpdate(UpdateCustomerNoteParams params) async {
    final note = _editingNote;
    if (note == null || state is CustomerNoteFormSubmitting) return;
    emit(CustomerNoteFormSubmitting(isEdit: true));

    final result = await _updateCustomerNote(
      params,
      customerId: note.customerId,
    );
    if (isClosed) return;
    _emitOutcome(result, isEdit: true);
  }

  void _emitOutcome(ApiResult<void> result, {required bool isEdit}) =>
      result.fold(
        (failure) => emit(CustomerNoteFormSubmitError(failure)),
        (_) => emit(CustomerNoteFormSuccess(isEdit: isEdit)),
      );
}
