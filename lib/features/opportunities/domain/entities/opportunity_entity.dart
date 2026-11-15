import 'package:equatable/equatable.dart';

import '../enums/opportunity_stage.dart';
import '../enums/opportunity_status.dart';
import 'opportunity_customer_entity.dart';
import 'opportunity_employee_entity.dart';

/// A CRM opportunity as the standalone list shows it. Read-only on mobile:
/// no create/edit/stage-move. Embedded notes/interactions use the lighter
/// entities declared here in their nested customer aggregate.
final class Opportunity extends Equatable {
  const Opportunity({
    required this.opportunityId,
    required this.title,
    required this.estimatedValue,
    required this.currency,
    required this.stage,
    required this.probability,
    required this.expectedCloseDate,
    required this.status,
    required this.lostReason,
    required this.createdAt,
    this.closedAt,
    required this.customer,
    required this.employee,
  });

  final int opportunityId;
  final String title;
  final num estimatedValue;
  final String currency;

  /// Typed with `unknown` fallback for values the backend hasn't told us
  /// about. Declaration order is the documented pipeline order.
  final OpportunityStage stage;

  /// Server-provided percentage based on `stage`; display data only.
  /// Never mapped client-side.
  final int probability;

  /// UTC-normalized calendar date (see `WireDates`).
  final DateTime expectedCloseDate;

  final OpportunityStatus status;

  /// Meaningful only when `status` is `lost`; may be `''` otherwise.
  final String lostReason;

  final DateTime createdAt;
  final DateTime? closedAt;

  final OpportunityCustomer customer;
  final OpportunityEmployee employee;

  @override
  List<Object?> get props => [
    opportunityId,
    title,
    estimatedValue,
    currency,
    stage,
    probability,
    expectedCloseDate,
    status,
    lostReason,
    createdAt,
    closedAt,
    customer,
    employee,
  ];
}
