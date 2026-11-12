import 'package:equatable/equatable.dart';
import 'package:orbit/core/errors/failures.dart';

import '../../../domain/entities/dashboard_overview_entity.dart';

sealed class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => const [];
}

final class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

/// First load (or a retry after an error): nothing to show yet.
final class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

/// The overview is on screen. A pull-to-refresh keeps it visible
/// ([isRefreshing]); a failed refresh keeps it too and sets [refreshFailure].
final class DashboardSuccess extends DashboardState {
  const DashboardSuccess({
    required this.overview,
    this.isRefreshing = false,
    this.refreshFailure,
  });

  final DashboardOverview overview;
  final bool isRefreshing;
  final Failure? refreshFailure;

  @override
  List<Object?> get props => [overview, isRefreshing, refreshFailure];
}

final class DashboardError extends DashboardState {
  const DashboardError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
