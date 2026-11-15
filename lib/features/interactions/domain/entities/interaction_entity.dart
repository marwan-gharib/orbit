import 'package:equatable/equatable.dart';

import 'package:orbit/features/interactions/domain/enums/interaction_type.dart';

/// A CRM interaction as the standalone interactions list shows it
/// (opportunity views use the lighter embedded entity instead).
final class Interaction extends Equatable {
  const Interaction({
    required this.interactionId,
    required this.type,
    required this.subject,
    required this.description,
    required this.interactionDate,
    required this.customerId,
    required this.employeeId,
    this.contactId,
    this.opportunityId,
  });

  final int interactionId;
  final InteractionType type;
  final String subject;

  /// An empty description on the wire is tolerated as `''`.
  final String description;

  /// UTC-normalized calendar date (see `WireDates`).
  final DateTime interactionDate;
  final int customerId;
  final int employeeId;
  final int? contactId;
  final int? opportunityId;

  @override
  List<Object?> get props => [
    interactionId,
    type,
    subject,
    description,
    interactionDate,
    customerId,
    employeeId,
    contactId,
    opportunityId,
  ];
}
