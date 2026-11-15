import 'package:equatable/equatable.dart';

import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/features/interactions/domain/enums/interaction_type.dart';
import 'package:orbit/core/helpers/wire_dates.dart';

import '../../domain/entities/interaction_entity.dart';

/// One interaction on the wire (`Interactions` list item; mutation
/// responses are 2xx-only and parsed by nobody).
final class InteractionModel extends Equatable {
  const InteractionModel({
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
  final String description;

  /// Parsed from the wire date (`2006-10-14T00:00:00Z` — instant or
  /// date-only) into a UTC-normalized calendar day; a wrong shape fails the
  /// whole response parse.
  final DateTime interactionDate;
  final int customerId;
  final int employeeId;
  final int? contactId;
  final int? opportunityId;

  factory InteractionModel.fromJson(Map<String, dynamic> json) =>
      InteractionModel(
        interactionId: json[ApiKeys.interactionIdKey] as int,
        type: InteractionType.fromValue(json[ApiKeys.typeKey] as String?),
        subject: json[ApiKeys.subjectKey] as String? ?? '',
        description: json[ApiKeys.descriptionKey] as String? ?? '',
        interactionDate: WireDates.parseDateOnly(
          json[ApiKeys.interactionDateKey] as String? ?? '',
        ),
        customerId: json[ApiKeys.customerIdKey] as int,
        employeeId: json[ApiKeys.employeeIdKey] as int,
        contactId: json[ApiKeys.contactIdKey] as int?,
        opportunityId: json[ApiKeys.opportunityIdKey] as int?,
      );

  Interaction toEntity() => Interaction(
    interactionId: interactionId,
    type: type,
    subject: subject,
    description: description,
    interactionDate: interactionDate,
    customerId: customerId,
    employeeId: employeeId,
    contactId: contactId,
    opportunityId: opportunityId,
  );

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
