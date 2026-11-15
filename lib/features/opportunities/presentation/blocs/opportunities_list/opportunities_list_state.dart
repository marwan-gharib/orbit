import 'package:equatable/equatable.dart';

import 'package:orbit/core/errors/failures.dart';

import '../../../domain/entities/opportunity_entity.dart';
import '../../../domain/params/opportunities_criteria.dart';

/// Sealed state hierarchy of the opportunities list.
///
/// Paginated: `Success` carries `items`, `hasMore`, `nextPage` plus
/// `isRefreshing`/`isLoadingMore` and their failures. A failed load-more
/// keeps already-loaded items and allows retry.
sealed class OpportunitiesListState extends Equatable {
  const OpportunitiesListState({required this.criteria});

  final OpportunitiesCriteria criteria;

  @override
  List<Object?> get props => [criteria];
}

/// Nothing loaded yet.
final class OpportunitiesListInitial extends OpportunitiesListState {
  const OpportunitiesListInitial({required super.criteria});
}

/// A criteria-driven load in flight; drops previous items.
final class OpportunitiesListLoading extends OpportunitiesListState {
  const OpportunitiesListLoading({required super.criteria});
}

/// Data loaded under `criteria`.
final class OpportunitiesListSuccess extends OpportunitiesListState {
  const OpportunitiesListSuccess({
    required super.criteria,
    required this.items,
    required this.hasMore,
    required this.nextPage,
    required this.totalCount,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.loadMoreFailure,
    this.refreshFailure,
  });

  final List<Opportunity> items;
  final bool hasMore;
  final int? nextPage;

  /// Total matching rows from the API envelope (`count`). Display-only —
  /// paging logic never uses it.
  final int totalCount;
  final bool isRefreshing;
  final bool isLoadingMore;
  final Failure? loadMoreFailure;
  final Failure? refreshFailure;

  @override
  List<Object?> get props => [
    criteria,
    items,
    hasMore,
    nextPage,
    totalCount,
    isRefreshing,
    isLoadingMore,
    loadMoreFailure,
    refreshFailure,
  ];
}

/// The list loaded empty under `criteria`.
final class OpportunitiesListEmpty extends OpportunitiesListState {
  const OpportunitiesListEmpty({
    required super.criteria,
    required this.totalCount,
    this.isRefreshing = false,
    this.refreshFailure,
  });

  /// Total matching rows from the API envelope (`count`). Display-only —
  /// paging logic never uses it.
  final int totalCount;
  final bool isRefreshing;
  final Failure? refreshFailure;

  @override
  List<Object?> get props => [
    criteria,
    totalCount,
    isRefreshing,
    refreshFailure,
  ];
}

/// A full load failed; copy from `context.failureText`.
final class OpportunitiesListError extends OpportunitiesListState {
  const OpportunitiesListError({
    required super.criteria,
    required this.failure,
  });

  final Failure failure;

  @override
  List<Object?> get props => [criteria, failure];
}
