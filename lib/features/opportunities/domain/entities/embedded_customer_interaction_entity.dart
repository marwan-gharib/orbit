import 'package:equatable/equatable.dart';

import 'package:orbit/features/interactions/domain/enums/interaction_type.dart';

/// Lighter interaction embedded inside an opportunity: has `employee_name`
/// and no `customer_id`. Uses the shared `InteractionType` enum from core.
final class EmbeddedCustomerInteraction extends Equatable {
  const EmbeddedCustomerInteraction({
    required this.interactionId,
    required this.employeeId,
    required this.employeeName,
    required this.type,
    required this.subject,
    required this.description,
    required this.interactionDate,
    this.contactId,
    this.opportunityId,
  });

  final int interactionId;
  final int employeeId;
  final String employeeName;
  final InteractionType type;
  final String subject;
  final String description;
  final DateTime interactionDate;
  final int? contactId;
  final int? opportunityId;

  @override
  List<Object?> get props => [
    interactionId,
    employeeId,
    employeeName,
    type,
    subject,
    description,
    interactionDate,
    contactId,
    opportunityId,
  ];
}
