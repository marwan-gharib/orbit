import 'package:equatable/equatable.dart';

import 'package:orbit/core/errors/failures.dart';

/// Sealed state hierarchy of the note delete (confirm-driven, its own
/// one-shot lifecycle).
sealed class CustomerNoteDeleteState extends Equatable {
  const CustomerNoteDeleteState();

  @override
  List<Object?> get props => const [];
}

/// Nothing deleting at the moment.
final class CustomerNoteDeleteInitial extends CustomerNoteDeleteState {}

/// A delete is in flight for [noteId].
final class CustomerNoteDeleteInProgress extends CustomerNoteDeleteState {
  const CustomerNoteDeleteInProgress(this.noteId);

  final int noteId;

  @override
  List<Object?> get props => [noteId];
}

/// One-shot success signoff; the row disappears when the change signal
/// drives the silent refetch, not here.
final class CustomerNoteDeleteSuccess extends CustomerNoteDeleteState {
  const CustomerNoteDeleteSuccess(this.noteId);

  final int noteId;

  @override
  List<Object?> get props => [noteId];
}

/// Delete failed for [noteId]; copy from `context.failureText`.
final class CustomerNoteDeleteFailure extends CustomerNoteDeleteState {
  const CustomerNoteDeleteFailure(this.noteId, this.failure);

  final int noteId;
  final Failure failure;

  @override
  List<Object?> get props => [noteId, failure];
}
