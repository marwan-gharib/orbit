import 'package:orbit/core/constants/api_keys.dart';

import '../../domain/entities/note_customer_details_entity.dart';

/// `customer_details` inside a note.
final class NoteCustomerDetailsModel {
  const NoteCustomerDetailsModel({
    required this.customerId,
    required this.customerCode,
    required this.name,
    required this.companyName,
  });

  final int customerId;
  final String customerCode;
  final String name;
  final String companyName;

  factory NoteCustomerDetailsModel.fromJson(Map<String, dynamic> json) =>
      NoteCustomerDetailsModel(
        customerId: json[ApiKeys.customerIdKey] as int,
        customerCode: json[ApiKeys.customerCodeKey] as String? ?? '',
        name: json[ApiKeys.nameKey] as String? ?? '',
        companyName: json[ApiKeys.companyNameKey] as String? ?? '',
      );

  NoteCustomerDetails toEntity() => NoteCustomerDetails(
    customerId: customerId,
    customerCode: customerCode,
    name: name,
    companyName: companyName,
  );
}
