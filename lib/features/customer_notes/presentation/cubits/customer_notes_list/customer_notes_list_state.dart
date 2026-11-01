import 'package:equatable/equatable.dart';

import 'package:orbit/core/errors/failures.dart';

import '../../../domain/entities/customer_note_entity.dart';

/// Sealed state hierarchy of the customer-notes list.
///
/// All loaded state carries `notes`/`total` under its `customerId` — data is
/// never reused across customers. `isRefreshing`/`refreshFailure` describe
/// a silent refetch; a failed refresh keeps previous data and never reports
/// a mutation as failed.
sealed class CustomerNotesListState extends Equatable {
  const CustomerNotesListState();

  @override
  List<Object?> get props => const [];
}

/// Nothing loaded yet.
final class CustomerNotesListInitial extends CustomerNotesListState {}

/// A load is in flight.
final class CustomerNotesListLoading extends CustomerNotesListState {}

/// Data loaded (empty lists surface `CustomerNotesListEmpty`).
final class CustomerNotesListSuccess extends CustomerNotesListState {
  const CustomerNotesListSuccess({
    required this.notes,
    required this.total,
    this.isRefreshing = false,
    this.refreshFailure,
  });

  final List<CustomerNote> notes;
  final int total;
  final bool isRefreshing;
  final Failure? refreshFailure;

  @override
  List<Object?> get props => [notes, total, isRefreshing, refreshFailure];
}

/// The list loaded empty.
final class CustomerNotesListEmpty extends CustomerNotesListState {
  const CustomerNotesListEmpty({
    this.isRefreshing = false,
    this.refreshFailure,
  });

  final bool isRefreshing;
  final Failure? refreshFailure;

  @override
  List<Object?> get props => [isRefreshing, refreshFailure];
}

/// A full load failed; copy from `context.failureText`.
final class CustomerNotesListError extends CustomerNotesListState {
  const CustomerNotesListError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
