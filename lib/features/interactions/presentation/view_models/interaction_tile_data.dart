import 'package:equatable/equatable.dart';

import 'package:orbit/features/interactions/domain/enums/interaction_type.dart';

/// Plain data for one interaction tile (feed + timeline).
final class InteractionTileData extends Equatable {
  const InteractionTileData({
    required this.id,
    required this.type,
    required this.subject,
    required this.description,
    required this.date,
    this.authorName,
    this.customerId,
    this.contactId,
    this.opportunityId,
  });

  final int id;
  final InteractionType type;
  final String subject;
  final String description;
  final DateTime date;
  final String? authorName;
  final int? customerId;
  final int? contactId;
  final int? opportunityId;

  @override
  List<Object?> get props => [
    id,
    type,
    subject,
    description,
    date,
    authorName,
    customerId,
    contactId,
    opportunityId,
  ];
}

/// Contact option for the add-sheet selector.
final class InteractionContactOption extends Equatable {
  const InteractionContactOption({required this.id, required this.label});

  final int id;
  final String label;

  @override
  List<Object?> get props => [id, label];
}

/// Data needed to open the edit sheet (carries only what the edit flow needs).
final class InteractionEditData extends Equatable {
  const InteractionEditData({
    required this.interactionId,
    required this.type,
    required this.subject,
    required this.description,
    required this.date,
    this.customerId,
    this.opportunityId,
  });

  final int interactionId;
  final InteractionType type;
  final String subject;
  final String description;
  final DateTime date;
  final int? customerId;
  final int? opportunityId;

  @override
  List<Object?> get props => [
    interactionId,
    type,
    subject,
    description,
    date,
    customerId,
    opportunityId,
  ];
}

/// Mode for the add/edit sheet.
enum SheetMode { add, edit }
