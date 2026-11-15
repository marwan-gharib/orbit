import 'package:equatable/equatable.dart';

import 'package:orbit/core/errors/failures.dart';

import '../../../domain/entities/opportunity_entity.dart';

/// Sealed state hierarchy of the opportunity detail (read-only).
sealed class OpportunityDetailsState extends Equatable {
  const OpportunityDetailsState();

  @override
  List<Object?> get props => const [];
}

/// Nothing loaded yet.
final class OpportunityDetailsInitial extends OpportunityDetailsState {}

/// A load is in flight.
final class OpportunityDetailsLoading extends OpportunityDetailsState {}

/// Data loaded.
final class OpportunityDetailsSuccess extends OpportunityDetailsState {
  const OpportunityDetailsSuccess({
    required this.opportunity,
    this.isRefreshing = false,
    this.refreshFailure,
  });

  final Opportunity opportunity;
  final bool isRefreshing;
  final Failure? refreshFailure;

  @override
  List<Object?> get props => [opportunity, isRefreshing, refreshFailure];
}

/// A load failed; copy from `context.failureText`.
final class OpportunityDetailsError extends OpportunityDetailsState {
  const OpportunityDetailsError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
