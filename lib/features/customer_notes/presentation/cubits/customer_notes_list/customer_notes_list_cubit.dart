import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:orbit/core/services/crm_data_change.dart';

import '../../../domain/entities/customer_note_entity.dart';
import '../../../domain/usecases/get_customer_notes_usecase.dart';
import '../../../domain/usecases/watch_note_changes_usecase.dart';
import 'customer_notes_list_state.dart';

/// Drives the customer-notes list: load, refresh, silent refetch on the CRM
/// change signal. Never patches locally — after any successful note
/// add/edit/delete, the affected list is re-fetched for its customer.
class CustomerNotesListCubit extends Cubit<CustomerNotesListState> {
  CustomerNotesListCubit({
    required this._getCustomerNotes,
    required this._watchNoteChanges,
  }) : super(CustomerNotesListInitial()) {
    _changesSubscription = _watchNoteChanges().listen(_onCrmChange);
  }

  final GetCustomerNotesUseCase _getCustomerNotes;
  final WatchNoteChangesUseCase _watchNoteChanges;
  StreamSubscription<CrmDataChange>? _changesSubscription;

  /// The customer whose notes are shown; null until [load] has run.
  int? _customerId;

  /// Monotonic request token so an older refetch can never overwrite newer
  /// data.
  int _queryToken = 0;

  @override
  Future<void> close() async {
    await _changesSubscription?.cancel();
    await super.close();
  }

  /// Loads notes for `customerId`. Call once per screen; use [refresh] to
  /// reload.
  Future<void> load(int customerId) async {
    _customerId = customerId;
    await _runQuery(customerId);
  }

  /// Re-fetches the same customer's notes (silent refresh keeps data on
  /// screen; failure keeps it and sets `refreshFailure`).
  Future<void> refresh() async {
    final customerId = _customerId;
    if (customerId == null) return;
    await _runQuery(customerId);
  }

  Future<void> _runQuery(int customerId) async {
    emit(CustomerNotesListLoading());
    final token = ++_queryToken;
    final result = await _getCustomerNotes(customerId);
    if (isClosed || token != _queryToken) return;
    result.fold(
      (failure) => emit(CustomerNotesListError(failure)),
      (result) => emit(_loadedState(result.notes, result.total)),
    );
  }

  CustomerNotesListState _loadedState(List<CustomerNote> notes, int total) =>
      notes.isEmpty
      ? CustomerNotesListEmpty()
      : CustomerNotesListSuccess(notes: notes, total: total);

  void _onCrmChange(CrmDataChange change) {
    final relevant =
        change.kind == CrmDataKind.note &&
        (_customerId == null || change.customerId == _customerId);
    if (!relevant || isClosed) return;
    refresh();
  }
}
