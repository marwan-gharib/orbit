import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:orbit/core/constants/app_consts.dart';
import 'package:orbit/core/services/crm_data_change.dart';

import '../../../domain/entities/interaction_entity.dart';
import '../../../domain/params/interactions_criteria.dart';
import '../../../domain/usecases/get_interactions_usecase.dart';
import '../../../domain/usecases/watch_interaction_changes_usecase.dart';
import 'interactions_list_event.dart';
import 'interactions_list_state.dart';

/// Drives the interactions list: debounced search + immediate filters +
/// full reloads, all restartable, and a silent refresh fed by the CRM change
/// signal (successful mutations anywhere silently refetch this list under
/// its active criteria — a deleted row disappears through the refetch, never
/// by local patching).
///
/// Bloc (not Cubit): search debounce and reload concurrency need per-event
/// transformers exactly once, which `bloc_concurrency` + `stream_transform`
/// provide; a Cubit has no per-event transformer seam.
class InteractionsListBloc
    extends Bloc<InteractionsListEvent, InteractionsListState> {
  InteractionsListBloc(
    this._getInteractions,
    WatchInteractionChangesUseCase watchInteractionChanges, {
    this.searchDebounce = AppConsts.crmSearchDebounce,
  }) : super(const InteractionsListInitial(criteria: InteractionsCriteria())) {
    on<InteractionsListStarted>(_onStarted, transformer: restartable());
    on<InteractionsListSearchChanged>(
      _onSearchChanged,
      transformer: (events, mapper) =>
          events.debounce(searchDebounce).switchMap(mapper),
    );
    on<InteractionsListFiltersChanged>(
      _onFiltersChanged,
      transformer: restartable(),
    );
    on<InteractionsListRefreshed>(_onRefreshed, transformer: restartable());

    // The subscription lives for the Bloc's life (screen scope) and is
    // canceled in close(); the use case filters the signal to interaction
    // changes only.
    _changesSubscription = watchInteractionChanges().listen(_onCrmChange);
  }

  final GetInteractionsUseCase _getInteractions;

  /// Injected so tests pass a zero wait and never sleep in real time.
  final Duration searchDebounce;

  StreamSubscription<CrmDataChange>? _changesSubscription;

  /// Monotonic query token: after every await the emitting handler confirms
  /// it still runs the newest query — a cross-event-type stale response
  /// (restartable cancels only its own handler type) can never overwrite
  /// newer data.
  int _queryToken = 0;

  @override
  Future<void> close() async {
    await _changesSubscription?.cancel();
    await super.close();
  }

  Future<void> _onStarted(
    InteractionsListStarted event,
    Emitter<InteractionsListState> emit,
  ) async {
    if (state is! InteractionsListInitial) return;
    await _runQuery(state.criteria, emit);
  }

  Future<void> _onSearchChanged(
    InteractionsListSearchChanged event,
    Emitter<InteractionsListState> emit,
  ) async {
    final current = state.criteria;
    await _runQuery(
      InteractionsCriteria(
        searchText: event.text,
        type: current.type,
        customerId: current.customerId,
        contactId: current.contactId,
        opportunityId: current.opportunityId,
      ),
      emit,
    );
  }

  Future<void> _onFiltersChanged(
    InteractionsListFiltersChanged event,
    Emitter<InteractionsListState> emit,
  ) async {
    final current = state.criteria;
    // Replace semantics: the event carries the whole filter set; null clears.
    await _runQuery(
      InteractionsCriteria(
        searchText: current.searchText,
        type: event.type,
        customerId: event.customerId,
        contactId: event.contactId,
        opportunityId: event.opportunityId,
      ),
      emit,
    );
  }

  Future<void> _onRefreshed(
    InteractionsListRefreshed event,
    Emitter<InteractionsListState> emit,
  ) async {
    final current = state;
    final criteria = current.criteria;
    if (current is! InteractionsListSuccess &&
        current is! InteractionsListEmpty) {
      await _runQuery(criteria, emit);
      return;
    }

    // Silent refresh: the previous data stays on screen until the refetch
    // arrives; a failed refetch keeps it (non-destructive) and only sets
    // refreshFailure — a mutation is never reported as failed this way.
    final (
      bool isDataState,
      List<Interaction> previousInteractions,
    ) = switch (current) {
      InteractionsListSuccess(:final interactions) => (true, interactions),
      _ => (false, const <Interaction>[]),
    };
    emit(
      isDataState
          ? InteractionsListSuccess(
              criteria: criteria,
              interactions: previousInteractions,
              isRefreshing: true,
            )
          : InteractionsListEmpty(criteria: criteria, isRefreshing: true),
    );

    final token = ++_queryToken;
    final result = await _getInteractions(criteria);
    if (emit.isDone || token != _queryToken) return;
    result.fold(
      (failure) => emit(
        isDataState
            ? InteractionsListSuccess(
                criteria: criteria,
                interactions: previousInteractions,
                isRefreshing: false,
                refreshFailure: failure,
              )
            : InteractionsListEmpty(
                criteria: criteria,
                isRefreshing: false,
                refreshFailure: failure,
              ),
      ),
      (interactions) => emit(_loadedState(criteria, interactions)),
    );
  }

  Future<void> _runQuery(
    InteractionsCriteria criteria,
    Emitter<InteractionsListState> emit,
  ) async {
    emit(InteractionsListLoading(criteria: criteria));
    final token = ++_queryToken;
    final result = await _getInteractions(criteria);
    if (emit.isDone || token != _queryToken) return;
    result.fold(
      (failure) =>
          emit(InteractionsListError(criteria: criteria, failure: failure)),
      (interactions) => emit(_loadedState(criteria, interactions)),
    );
  }

  InteractionsListState _loadedState(
    InteractionsCriteria criteria,
    List<Interaction> interactions,
  ) => interactions.isEmpty
      ? InteractionsListEmpty(criteria: criteria)
      : InteractionsListSuccess(criteria: criteria, interactions: interactions);

  /// Whether the change is relevant for the current criteria: same customer
  /// (any customer when unfiltered) and, when the list is bound to an
  /// opportunity, the same opportunity. Contact/type filters refresh
  /// conservatively — the signal does not carry those fields, and a refetch
  /// under the filters is always correct.
  void _onCrmChange(CrmDataChange change) {
    final criteria = state.criteria;
    final relevant =
        (criteria.customerId == null ||
            change.customerId == criteria.customerId) &&
        (criteria.opportunityId == null ||
            change.opportunityId == criteria.opportunityId);
    if (!relevant || isClosed) return;
    add(const InteractionsListRefreshed());
  }
}
