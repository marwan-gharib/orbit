import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:orbit/core/constants/app_consts.dart';
import 'package:orbit/core/services/crm_data_change.dart';

import '../../../domain/entities/opportunity_entity.dart';
import '../../../domain/params/get_opportunities_params.dart';
import '../../../domain/params/opportunities_criteria.dart';
import '../../../domain/usecases/get_opportunities_usecase.dart';
import 'opportunities_list_event.dart';
import 'opportunities_list_state.dart';

/// Drives the paginated opportunities list: debounced title search, immediate
/// filters, first-load/refresh/load-more, all server-side. Bloc (not Cubit)
/// because per-event transformers are required (STATE-1).
///
/// `hasMore` is derived from `next != null` only — `count` is display-only.
/// Server order is preserved; never re-sorted across pages (OQ-6).
///
/// This Bloc is intentionally NOT subscribed to the CRM change signal:
/// list items never render embedded notes or interactions, so mutations on
/// notes/interactions cannot affect what this screen shows (Edit 5 #3).
class OpportunitiesListBloc
    extends Bloc<OpportunitiesListEvent, OpportunitiesListState> {
  OpportunitiesListBloc({
    required this._getOpportunities,
    this._pageSize = AppConsts.crmOpportunitiesPageSize,
    this._searchDebounce = AppConsts.crmSearchDebounce,
  }) : super(
         const OpportunitiesListInitial(criteria: OpportunitiesCriteria()),
       ) {
    on<OpportunitiesListStarted>(_onStarted, transformer: restartable());
    on<OpportunitiesListSearchChanged>(
      _onSearchChanged,
      transformer: (events, mapper) =>
          events.debounce(_searchDebounce).switchMap(mapper),
    );
    on<OpportunitiesListFiltersChanged>(
      _onFiltersChanged,
      transformer: restartable(),
    );
    on<OpportunitiesListRefreshed>(_onRefreshed, transformer: restartable());
    on<OpportunitiesListLoadMoreRequested>(
      _onLoadMoreRequested,
      transformer: droppable(),
    );

    _changesSubscription = null; // deliberately not subscribed (see class doc)
  }

  final GetOpportunitiesUseCase _getOpportunities;
  final int _pageSize;
  final Duration _searchDebounce;
  OpportunitiesCriteria? _criteria;

  /// The page behind the currently displayed items.
  int _currentPage = 0;

  /// Monotonic query token so an older response can never overwrite newer
  /// data across event types.
  int _queryToken = 0;

  StreamSubscription<CrmDataChange>? _changesSubscription;

  @override
  Future<void> close() async {
    await _changesSubscription?.cancel();
    await super.close();
  }

  Future<void> _onStarted(
    OpportunitiesListStarted event,
    Emitter<OpportunitiesListState> emit,
  ) async {
    final criteria = _criteria ?? const OpportunitiesCriteria();
    await _loadPage(criteria, page: 1, emit: emit, replace: true);
  }

  Future<void> _onSearchChanged(
    OpportunitiesListSearchChanged event,
    Emitter<OpportunitiesListState> emit,
  ) async {
    final current = _criteria ?? const OpportunitiesCriteria();
    final criteria = current.copyWith(title: event.text);
    await _loadPage(criteria, page: 1, emit: emit, replace: true);
  }

  Future<void> _onFiltersChanged(
    OpportunitiesListFiltersChanged event,
    Emitter<OpportunitiesListState> emit,
  ) async {
    final current = _criteria ?? const OpportunitiesCriteria();
    final criteria = current.copyWith(
      stage: event.stage,
      status: event.status,
      customerId: event.customerId,
    );
    await _loadPage(criteria, page: 1, emit: emit, replace: true);
  }

  Future<void> _onRefreshed(
    OpportunitiesListRefreshed event,
    Emitter<OpportunitiesListState> emit,
  ) async {
    final criteria = _criteria ?? const OpportunitiesCriteria();
    await _loadPage(criteria, page: 1, emit: emit, replace: true);
  }

  Future<void> _onLoadMoreRequested(
    OpportunitiesListLoadMoreRequested event,
    Emitter<OpportunitiesListState> emit,
  ) async {
    final current = state;
    if (current is! OpportunitiesListSuccess) return;
    if (!current.hasMore || current.isLoadingMore) return;

    // Show a loading state inside the footer while the next page is in flight
    // so the Retry button can show its loading state and the list never spins
    // forever without a terminal state.
    emit(
      OpportunitiesListSuccess(
        criteria: current.criteria,
        items: current.items,
        hasMore: current.hasMore,
        nextPage: current.nextPage,
        totalCount: current.totalCount,
        isRefreshing: current.isRefreshing,
        isLoadingMore: true,
        loadMoreFailure: current.loadMoreFailure,
        refreshFailure: current.refreshFailure,
      ),
    );

    final criteria = _criteria ?? const OpportunitiesCriteria();
    await _loadPage(
      criteria,
      page: current.nextPage ?? (_currentPage + 1),
      emit: emit,
      replace: false,
      previousItems: current.items,
    );
  }

  Future<void> _loadPage(
    OpportunitiesCriteria criteria, {
    required int page,
    required Emitter<OpportunitiesListState> emit,
    required bool replace,
    List<Opportunity> previousItems = const [],
  }) async {
    _criteria = criteria;
    _currentPage = page;

    final token = ++_queryToken;
    final isFirstLoad =
        state is OpportunitiesListInitial || state is OpportunitiesListError;

    if (replace && isFirstLoad) {
      emit(OpportunitiesListLoading(criteria: criteria));
    }

    final result = await _getOpportunities(
      GetOpportunitiesParams(
        criteria: criteria,
        page: page,
        pageSize: _pageSize,
      ),
    );

    if (emit.isDone || token != _queryToken) return;

    result.fold(
      (failure) {
        if (replace) {
          emit(OpportunitiesListError(criteria: criteria, failure: failure));
        } else {
          // Load-more failure: keep items, surface failure, allow retry.
          final current = state;
          if (current is OpportunitiesListSuccess) {
            emit(
              OpportunitiesListSuccess(
                criteria: current.criteria,
                items: current.items,
                hasMore: current.hasMore,
                nextPage: current.nextPage,
                totalCount: current.totalCount,
                isRefreshing: current.isRefreshing,
                isLoadingMore: false,
                loadMoreFailure: failure,
                refreshFailure: current.refreshFailure,
              ),
            );
          }
        }
      },
      (paged) {
        final items = replace
            ? paged.items
            : [...previousItems, ...paged.items];
        final hasMore = paged.hasMore;
        final nextPage = hasMore ? page + 1 : null;

        if (items.isEmpty) {
          emit(
            OpportunitiesListEmpty(
              criteria: criteria,
              totalCount: paged.totalItems ?? 0,
              isRefreshing: false,
            ),
          );
        } else {
          emit(
            OpportunitiesListSuccess(
              criteria: criteria,
              items: items,
              hasMore: hasMore,
              nextPage: nextPage,
              totalCount: paged.totalItems ?? 0,
              isRefreshing: false,
              isLoadingMore: false,
            ),
          );
        }
      },
    );
  }
}
