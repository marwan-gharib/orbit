import 'package:equatable/equatable.dart';

import '../../../domain/enums/opportunity_stage.dart';
import '../../../domain/enums/opportunity_status.dart';

/// Events of the opportunities list Bloc.
///
/// Search is debounced + restartable; filters and refresh are immediate +
/// restartable; load-more is droppable (repeats while in flight are ignored).
sealed class OpportunitiesListEvent extends Equatable {
  const OpportunitiesListEvent();

  @override
  List<Object?> get props => const [];
}

/// First load; idempotent — later runs after a list exists do nothing.
final class OpportunitiesListStarted extends OpportunitiesListEvent {}

/// Search-as-you-type on `title`; debounce 300 ms + restartable.
final class OpportunitiesListSearchChanged extends OpportunitiesListEvent {
  const OpportunitiesListSearchChanged(this.text);

  final String text;

  @override
  List<Object?> get props => [text];
}

/// Filter change; NOT debounced. Replace semantics: a null field clears it.
final class OpportunitiesListFiltersChanged extends OpportunitiesListEvent {
  const OpportunitiesListFiltersChanged({
    this.stage,
    this.status,
    this.customerId,
  });

  final OpportunityStage? stage;
  final OpportunityStatus? status;
  final int? customerId;

  @override
  List<Object?> get props => [stage, status, customerId];
}

/// Manual pull-to-refresh; also fed by the CRM change signal for relevant
/// mutations on opportunities this list might touch (conservatively always
/// refreshes — the signal carries customer/opportunity ids that may not
/// match list filters).
final class OpportunitiesListRefreshed extends OpportunitiesListEvent {}

/// Request the next page; droppable so repeats while one is in flight are
/// ignored.
final class OpportunitiesListLoadMoreRequested extends OpportunitiesListEvent {}
