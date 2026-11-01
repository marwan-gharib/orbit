import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/core/helpers/wire_dates.dart';

import '../../domain/entities/opportunity_entity.dart';
import '../../domain/enums/opportunity_stage.dart';
import '../../domain/enums/opportunity_status.dart';
import 'opportunity_customer_model.dart';
import 'opportunity_employee_model.dart';

final class OpportunityModel {
  const OpportunityModel({
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
  final OpportunityStage stage;
  final int probability;
  final DateTime expectedCloseDate;
  final OpportunityStatus status;
  final String lostReason;
  final DateTime createdAt;
  final DateTime? closedAt;
  final OpportunityCustomerModel customer;
  final OpportunityEmployeeModel employee;

  factory OpportunityModel.fromJson(Map<String, dynamic> json) =>
      OpportunityModel(
        opportunityId: json[ApiKeys.opportunityIdKey] as int,
        title: json[ApiKeys.titleKey] as String? ?? '',
        estimatedValue: json[ApiKeys.estimatedValueKey] as num,
        currency: json[ApiKeys.currencyKey] as String? ?? '',
        stage: OpportunityStage.fromValue(json[ApiKeys.stageKey] as String?),
        probability: (json[ApiKeys.probabilityKey] as num?)?.toInt() ?? 0,
        expectedCloseDate: WireDates.parseDateOnly(
          json[ApiKeys.expectedCloseDateKey] as String? ?? '',
        ),
        status: OpportunityStatus.fromValue(json[ApiKeys.statusKey] as String?),
        lostReason: json[ApiKeys.lostReasonKey] as String? ?? '',
        createdAt: _parseInstant(json[ApiKeys.createdAtKey])!,
        closedAt: _parseInstant(json[ApiKeys.closedAtKey]),
        customer: OpportunityCustomerModel.fromJson(
          Map<String, dynamic>.from(
            json[ApiKeys.customerRootKey] as Map? ?? <String, dynamic>{},
          ),
        ),
        employee: OpportunityEmployeeModel.fromJson(
          Map<String, dynamic>.from(
            json[ApiKeys.employeeRootKey] as Map? ?? <String, dynamic>{},
          ),
        ),
      );

  Opportunity toEntity() => Opportunity(
    opportunityId: opportunityId,
    title: title,
    estimatedValue: estimatedValue,
    currency: currency,
    stage: stage,
    probability: probability,
    expectedCloseDate: expectedCloseDate,
    status: status,
    lostReason: lostReason,
    createdAt: createdAt,
    closedAt: closedAt,
    customer: customer.toEntity(),
    employee: employee.toEntity(),
  );

  static DateTime? _parseInstant(Object? raw) {
    if (raw == null) return null;
    final parsed = DateTime.tryParse(raw as String);
    return parsed;
  }
}
