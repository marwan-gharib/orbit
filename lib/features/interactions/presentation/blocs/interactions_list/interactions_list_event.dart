import 'package:equatable/equatable.dart';

import 'package:orbit/features/interactions/domain/enums/interaction_type.dart';

/// Events of the interactions list Bloc. Search is debounced/restartable and
/// filters are immediate/restartable — the transformers live on the Bloc.
sealed class InteractionsListEvent extends Equatable {
  const InteractionsListEvent();

  @override
  List<Object?> get props => const [];
}

/// First load; idempotent — later runs after a list exists do nothing.
final class InteractionsListStarted extends InteractionsListEvent {
  const InteractionsListStarted();
}

/// Search-as-you-type; debounce + restartable. Sent as typed — the backend
/// does the `contains` matching.
final class InteractionsListSearchChanged extends InteractionsListEvent {
  const InteractionsListSearchChanged(this.text);

  final String text;

  @override
  List<Object?> get props => [text];
}

/// Filter change; NOT debounced. Replace semantics: a null field clears it.
final class InteractionsListFiltersChanged extends InteractionsListEvent {
  const InteractionsListFiltersChanged({
    this.type,
    this.customerId,
    this.contactId,
    this.opportunityId,
  });

  final InteractionType? type;
  final int? customerId;
  final int? contactId;
  final int? opportunityId;

  @override
  List<Object?> get props => [type, customerId, contactId, opportunityId];
}

/// Manual pull-to-refresh; the Bloc also feeds itself this event when the
/// CRM change signal reports a relevant successful mutation (silent refetch
/// with the same criteria).
final class InteractionsListRefreshed extends InteractionsListEvent {
  const InteractionsListRefreshed();
}
