import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/get_dashboard_overview_usecase.dart';
import 'dashboard_state.dart';

/// Loads the CRM dashboard overview. One cubit instance per screen.
class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({required this._getOverview})
    : super(const DashboardInitial());

  final GetDashboardOverviewUseCase _getOverview;
  int _requestToken = 0;

  /// First load: shows the loading state. Does nothing once content exists
  /// (use [refresh]); retries after an error.
  Future<void> load() async {
    if (state is DashboardSuccess || state is DashboardLoading) return;
    await _fetch(silent: false);
  }

  /// Reloads without hiding what is on screen; falls back to a full load when
  /// there is nothing to keep (initial or error state).
  Future<void> refresh() => _fetch(silent: true);

  Future<void> _fetch({required bool silent}) async {
    final token = ++_requestToken;
    final prior = state;

    if (silent && prior is DashboardSuccess) {
      emit(DashboardSuccess(overview: prior.overview, isRefreshing: true));
    } else {
      emit(const DashboardLoading());
    }

    final result = await _getOverview();
    if (isClosed || token != _requestToken) return;

    result.fold((failure) {
      if (silent && prior is DashboardSuccess) {
        emit(
          DashboardSuccess(overview: prior.overview, refreshFailure: failure),
        );
      } else {
        emit(DashboardError(failure));
      }
    }, (overview) => emit(DashboardSuccess(overview: overview)));
  }
}
