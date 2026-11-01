import 'package:equatable/equatable.dart';

import 'package:orbit/features/interactions/domain/enums/interaction_type.dart';

/// Input of the add-interaction flow: the five editable fields plus the
/// owning record ids. No employee id — it is resolved from the signed-in
/// session by `AddInteractionUseCase` (the caller can never spoof it).
final class AddInteractionParams extends Equatable {
  const AddInteractionParams({
    required this.type,
    required this.subject,
    required this.description,
    required this.interactionDate,
    required this.customerId,
    this.contactId,
    this.opportunityId,
  });

  final InteractionType type;
  final String subject;
  final String description;

  /// UTC-normalized calendar date from the picker (serialized `yyyy-MM-dd`).
  final DateTime interactionDate;
  final int customerId;
  final int? contactId;
  final int? opportunityId;

  @override
  List<Object?> get props => [
    type,
    subject,
    description,
    interactionDate,
    customerId,
    contactId,
    opportunityId,
  ];
}
