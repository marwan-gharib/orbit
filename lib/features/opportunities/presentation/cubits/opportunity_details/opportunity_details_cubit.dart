import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:orbit/core/services/crm_data_change.dart';

import '../../../domain/usecases/get_opportunity_usecase.dart';
import '../../../domain/usecases/watch_crm_changes_usecase.dart';
import 'opportunity_details_state.dart';

/// Drives the read-only opportunity detail: load through the list endpoint
/// (`opportunity_id`), plus silent reload when the CRM change signal
/// reports a relevant note/interaction mutation for this opportunity.
///
/// The embedded notes/interactions go stale when any note or interaction
/// on this opportunity's customer (or the opportunity itself) changes.
class OpportunityDetailsCubit extends Cubit<OpportunityDetailsState> {
  OpportunityDetailsCubit({
    required this._getOpportunity,
    required this._watchCrmChanges,
  }) : super(OpportunityDetailsInitial()) {
    _changesSubscription = _watchCrmChanges().listen(_onCrmChange);
  }

  final GetOpportunityUseCase _getOpportunity;
  final WatchCrmChangesUseCase _watchCrmChanges;
  StreamSubscription<CrmDataChange>? _changesSubscription;

  int? _opportunityId;
  int _queryToken = 0;

  @override
  Future<void> close() async {
    await _changesSubscription?.cancel();
    await super.close();
  }

  /// Loads the opportunity. Call once per screen.
  Future<void> load(int opportunityId) async {
    _opportunityId = opportunityId;
    await _runQuery(opportunityId);
  }

  /// Silent re-fetch of the same opportunity (keeps data on screen;
  /// failure keeps it and sets `refreshFailure`).
  Future<void> refresh() async {
    final id = _opportunityId;
    if (id == null) return;
    await _runQuery(id);
  }

  Future<void> _runQuery(int opportunityId) async {
    emit(OpportunityDetailsLoading());
    final token = ++_queryToken;
    final result = await _getOpportunity(opportunityId);
    if (isClosed || token != _queryToken) return;
    result.fold(
      (failure) => emit(OpportunityDetailsError(failure)),
      (opportunity) =>
          emit(OpportunityDetailsSuccess(opportunity: opportunity)),
    );
  }

  void _onCrmChange(CrmDataChange change) {
    final id = _opportunityId;
    if (id == null || isClosed) return;

    final relevant =
        change.kind == CrmDataKind.note && change.opportunityId == id;

    if (!relevant) return;
    refresh();
  }
}
