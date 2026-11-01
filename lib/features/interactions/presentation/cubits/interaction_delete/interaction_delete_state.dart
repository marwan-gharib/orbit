import 'package:equatable/equatable.dart';

import 'package:orbit/core/errors/failures.dart';

/// Sealed state hierarchy of the interaction delete (swipe/confirm-driven,
/// its own one-shot lifecycle next to the form).
sealed class InteractionDeleteState extends Equatable {
  const InteractionDeleteState();

  @override
  List<Object?> get props => const [];
}

/// Nothing deleting at the moment.
final class InteractionDeleteInitial extends InteractionDeleteState {
  const InteractionDeleteInitial();
}

/// A delete is in flight for [interactionId].
final class InteractionDeleteInProgress extends InteractionDeleteState {
  const InteractionDeleteInProgress(this.interactionId);

  final int interactionId;

  @override
  List<Object?> get props => [interactionId];
}

/// One-shot success signoff; the list row disappears when the change signal
/// drives the silent refetch, not here.
final class InteractionDeleteSuccess extends InteractionDeleteState {
  const InteractionDeleteSuccess(this.interactionId);

  final int interactionId;

  @override
  List<Object?> get props => [interactionId];
}

/// Delete failed for [interactionId]; copy from `context.failureText`.
final class InteractionDeleteFailure extends InteractionDeleteState {
  const InteractionDeleteFailure(this.interactionId, this.failure);

  final int interactionId;
  final Failure failure;

  @override
  List<Object?> get props => [interactionId, failure];
}
