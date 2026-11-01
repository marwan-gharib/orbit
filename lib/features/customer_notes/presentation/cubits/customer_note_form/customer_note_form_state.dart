import 'package:equatable/equatable.dart';

import 'package:orbit/core/errors/failures.dart';

import '../../../domain/entities/customer_note_entity.dart';

/// Sealed state hierarchy of the customer-note form (add + edit share it).
sealed class CustomerNoteFormState extends Equatable {
  const CustomerNoteFormState();

  @override
  List<Object?> get props => const [];
}

/// Nothing started yet.
final class CustomerNoteFormInitial extends CustomerNoteFormState {}

/// Form open: [existing] is the note prefilled for an edit (from the
/// already-loaded list state — no fetch), null for an add.
final class CustomerNoteFormReady extends CustomerNoteFormState {
  const CustomerNoteFormReady({required this.existing});

  final CustomerNote? existing;

  @override
  List<Object?> get props => [existing];
}

/// A submit is in flight; [isEdit] lets the UI keep the right labels.
final class CustomerNoteFormSubmitting extends CustomerNoteFormState {
  const CustomerNoteFormSubmitting({required this.isEdit});

  final bool isEdit;

  @override
  List<Object?> get props => [isEdit];
}

/// One-shot success signoff; the list is refreshed through the change
/// signal, not here.
final class CustomerNoteFormSuccess extends CustomerNoteFormState {
  const CustomerNoteFormSuccess({required this.isEdit});

  final bool isEdit;

  @override
  List<Object?> get props => [isEdit];
}

/// Submit failed; copy from `context.failureText`.
final class CustomerNoteFormSubmitError extends CustomerNoteFormState {
  const CustomerNoteFormSubmitError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
