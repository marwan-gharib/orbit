import 'package:equatable/equatable.dart';

import 'package:orbit/core/errors/failures.dart';

import '../../../domain/entities/interaction_entity.dart';

/// Sealed state hierarchy of the interaction form (add + edit share it).
sealed class InteractionFormState extends Equatable {
  const InteractionFormState();

  @override
  List<Object?> get props => const [];
}

/// Nothing started yet.
final class InteractionFormInitial extends InteractionFormState {
  const InteractionFormInitial();
}

/// Form open: [existing] is the entity prefilled for an edit (it comes from
/// the already-loaded list state — no fetch), null for an add.
final class InteractionFormReady extends InteractionFormState {
  const InteractionFormReady({required this.existing});

  final Interaction? existing;

  @override
  List<Object?> get props => [existing];
}

/// A submit is in flight; [isEdit] lets the UI keep the right labels.
final class InteractionFormSubmitting extends InteractionFormState {
  const InteractionFormSubmitting({required this.isEdit});

  final bool isEdit;

  @override
  List<Object?> get props => [isEdit];
}

/// One-shot success signoff (the listener closes/navigates; the list is
/// refreshed through the change signal, not here).
final class InteractionFormSuccess extends InteractionFormState {
  const InteractionFormSuccess({required this.isEdit});

  final bool isEdit;

  @override
  List<Object?> get props => [isEdit];
}

/// Submit failed; copy from `context.failureText` (server field errors are
/// in the failure too).
final class InteractionFormSubmitError extends InteractionFormState {
  const InteractionFormSubmitError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
