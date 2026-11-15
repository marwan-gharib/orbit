import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/features/interactions/domain/enums/interaction_type.dart';
import 'package:orbit/core/helpers/wire_dates.dart';

import '../../domain/entities/embedded_customer_interaction_entity.dart';

final class EmbeddedInteractionModel {
  const EmbeddedInteractionModel({
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

  factory EmbeddedInteractionModel.fromJson(Map<String, dynamic> json) =>
      EmbeddedInteractionModel(
        interactionId: json[ApiKeys.interactionIdKey] as int,
        employeeId: json[ApiKeys.employeeIdKey] as int,
        employeeName: json[ApiKeys.employeeNameKey] as String? ?? '',
        type: InteractionType.fromValue(json[ApiKeys.typeKey] as String?),
        subject: json[ApiKeys.subjectKey] as String? ?? '',
        description: json[ApiKeys.descriptionKey] as String? ?? '',
        interactionDate: WireDates.parseDateOnly(
          json[ApiKeys.interactionDateKey] as String? ?? '',
        ),
        contactId: json[ApiKeys.contactIdKey] as int?,
        opportunityId: json[ApiKeys.opportunityIdKey] as int?,
      );

  EmbeddedCustomerInteraction toEntity() => EmbeddedCustomerInteraction(
    interactionId: interactionId,
    employeeId: employeeId,
    employeeName: employeeName,
    type: type,
    subject: subject,
    description: description,
    interactionDate: interactionDate,
    contactId: contactId,
    opportunityId: opportunityId,
  );
}
