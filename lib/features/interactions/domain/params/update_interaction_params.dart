import 'package:equatable/equatable.dart';

import 'package:orbit/features/interactions/domain/enums/interaction_type.dart';

/// Input of the edit-interaction flow: EXACTLY the fields the PATCH body
/// carries (`interaction_id`, `type`, `subject`, `description`,
/// `interaction_date`). The owning ids are immutable — they are not part of
/// this class, so no code path can ever send them.
final class UpdateInteractionParams extends Equatable {
  const UpdateInteractionParams({
    required this.interactionId,
    required this.type,
    required this.subject,
    required this.description,
    required this.interactionDate,
  });

  final int interactionId;
  final InteractionType type;
  final String subject;
  final String description;

  /// UTC-normalized calendar date from the picker (serialized `yyyy-MM-dd`).
  final DateTime interactionDate;

  @override
  List<Object?> get props => [
    interactionId,
    type,
    subject,
    description,
    interactionDate,
  ];
}
