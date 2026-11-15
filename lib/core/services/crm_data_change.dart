import 'package:equatable/equatable.dart';

/// Which CRM record family a successful mutation touched. Repositories
/// publish; screen holders filter by it.
enum CrmDataKind { interaction, note }

/// One successful CRM mutation for [customerId] (and [opportunityId] when
/// the record is opportunity-bound). Holders decide themselves whether the
/// change is relevant to what they show right now and silently refetch.
final class CrmDataChange extends Equatable {
  const CrmDataChange({
    required this.kind,
    required this.customerId,
    this.opportunityId,
  });

  final CrmDataKind kind;
  final int customerId;

  /// Set only when the changed record belongs to an opportunity.
  final int? opportunityId;

  @override
  List<Object?> get props => [kind, customerId, opportunityId];
}
