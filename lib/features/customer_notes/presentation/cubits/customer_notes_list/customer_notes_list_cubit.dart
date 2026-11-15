import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:orbit/core/errors/failures.dart';
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

  /// Re-fetches the same customer's notes. After data has loaded this is a
  /// silent refresh: the previous notes stay on screen flagged
  /// `isRefreshing`, and a failed refresh keeps them and sets
  /// `refreshFailure`. Before any data exists it is a normal load.
  Future<void> refresh() async {
    final customerId = _customerId;
    if (customerId == null) return;
    switch (state) {
      case final CustomerNotesListSuccess current:
        await _runSilentQuery(customerId, current);
      case final CustomerNotesListEmpty current:
        await _runSilentQuery(customerId, current);
      case _:
        await _runQuery(customerId);
    }
  }

  Future<void> _runSilentQuery(
    int customerId,
    CustomerNotesListState current,
  ) async {
    emit(_refreshingState(current));
    final token = ++_queryToken;
    final result = await _getCustomerNotes(customerId);
    if (isClosed || token != _queryToken) return;
    result.fold(
      (failure) => emit(_refreshFailedState(current, failure)),
      (loaded) => emit(_loadedState(loaded.notes, loaded.total)),
    );
  }

  CustomerNotesListState _refreshingState(CustomerNotesListState current) =>
      switch (current) {
        CustomerNotesListSuccess(:final notes, :final total) =>
          CustomerNotesListSuccess(
            notes: notes,
            total: total,
            isRefreshing: true,
          ),
        CustomerNotesListEmpty() => const CustomerNotesListEmpty(
          isRefreshing: true,
        ),
        _ => current,
      };

  CustomerNotesListState _refreshFailedState(
    CustomerNotesListState current,
    Failure failure,
  ) => switch (current) {
    CustomerNotesListSuccess(:final notes, :final total) =>
      CustomerNotesListSuccess(
        notes: notes,
        total: total,
        refreshFailure: failure,
      ),
    CustomerNotesListEmpty() => CustomerNotesListEmpty(refreshFailure: failure),
    _ => current,
  };

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
