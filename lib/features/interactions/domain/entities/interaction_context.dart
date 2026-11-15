import 'package:equatable/equatable.dart';

/// Where a mutated interaction lives: which customer (and opportunity, when
/// the record is opportunity-bound) it belongs to.
///
/// Deliberately NOT part of any wire payload — edit must send only its five
/// editable fields; this context exists only so the repository can describe
/// successful mutations on the core CRM change signal.
final class InteractionContext extends Equatable {
  const InteractionContext({required this.customerId, this.opportunityId});

  final int customerId;
  final int? opportunityId;

  @override
  List<Object?> get props => [customerId, opportunityId];
}
