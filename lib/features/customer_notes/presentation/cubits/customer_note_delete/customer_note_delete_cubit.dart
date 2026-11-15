import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/customer_note_entity.dart';
import '../../../domain/usecases/delete_customer_note_usecase.dart';
import 'customer_note_delete_state.dart';

/// Drives one note delete: the owning customer id comes from the entity
/// (never serialized — it only feeds the change signal).
class CustomerNoteDeleteCubit extends Cubit<CustomerNoteDeleteState> {
  CustomerNoteDeleteCubit(this._deleteCustomerNote)
    : super(CustomerNoteDeleteInitial());

  final DeleteCustomerNoteUseCase _deleteCustomerNote;

  Future<void> delete(CustomerNote note) async {
    if (state is CustomerNoteDeleteInProgress) return;
    emit(CustomerNoteDeleteInProgress(note.noteId));

    final result = await _deleteCustomerNote(
      note.noteId,
      customerId: note.customerId,
    );
    if (isClosed) return;

    result.fold(
      (failure) => emit(CustomerNoteDeleteFailure(note.noteId, failure)),
      (_) => emit(CustomerNoteDeleteSuccess(note.noteId)),
    );
  }
}
