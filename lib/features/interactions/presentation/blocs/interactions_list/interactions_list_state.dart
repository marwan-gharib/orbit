import 'package:equatable/equatable.dart';

import 'package:orbit/core/errors/failures.dart';

import '../../../domain/entities/interaction_entity.dart';
import '../../../domain/params/interactions_criteria.dart';

/// Sealed state hierarchy of the interactions list.
///
/// All loaded state except [InteractionsListLoading]/[InteractionsListError]
/// carry the active [criteria] they were loaded under — data is never
/// reused across criteria changes. `isRefreshing` and `refreshFailure`
/// describe a silent refetch (refresh keeps the previous data on screen;
/// a failed refresh never reports a mutation as failed — the mutation's own
/// result lives in the form/delete holders).
sealed class InteractionsListState extends Equatable {
  const InteractionsListState({required this.criteria});

  final InteractionsCriteria criteria;

  @override
  List<Object?> get props => [criteria];
}

/// Nothing loaded yet.
final class InteractionsListInitial extends InteractionsListState {
  const InteractionsListInitial({required super.criteria});
}

/// A criteria-driven load in flight; a criteria change always drops the
/// previous items (they belong to different data).
final class InteractionsListLoading extends InteractionsListState {
  const InteractionsListLoading({required super.criteria});
}

/// Data loaded under [criteria] (empty lists surface [InteractionsListEmpty]).
final class InteractionsListSuccess extends InteractionsListState {
  const InteractionsListSuccess({
    required super.criteria,
    required this.interactions,
    this.isRefreshing = false,
    this.refreshFailure,
  });

  final List<Interaction> interactions;
  final bool isRefreshing;
  final Failure? refreshFailure;

  @override
  List<Object?> get props => [
    criteria,
    interactions,
    isRefreshing,
    refreshFailure,
  ];
}

/// The list loaded empty under [criteria].
final class InteractionsListEmpty extends InteractionsListState {
  const InteractionsListEmpty({
    required super.criteria,
    this.isRefreshing = false,
    this.refreshFailure,
  });

  final bool isRefreshing;
  final Failure? refreshFailure;

  @override
  List<Object?> get props => [criteria, isRefreshing, refreshFailure];
}

/// A full (criteria-driven) load failed; copy from `context.failureText`.
final class InteractionsListError extends InteractionsListState {
  const InteractionsListError({required super.criteria, required this.failure});

  final Failure failure;

  @override
  List<Object?> get props => [criteria, failure];
}
