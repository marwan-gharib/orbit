import 'package:orbit/core/constants/api_keys.dart';

import '../../domain/entities/customer_contact_entity.dart';

final class ContactModel {
  const ContactModel({
    required this.contactId,
    required this.name,
    required this.jobTitle,
    required this.email,
    required this.phone,
    required this.isPrimary,
  });

  final int contactId;
  final String name;
  final String jobTitle;
  final String email;
  final String phone;
  final bool isPrimary;

  factory ContactModel.fromJson(Map<String, dynamic> json) => ContactModel(
    contactId: json[ApiKeys.contactIdKey] as int,
    name: json[ApiKeys.nameKey] as String? ?? '',
    jobTitle: json[ApiKeys.jobTitleKey] as String? ?? '',
    email: json[ApiKeys.emailKey] as String? ?? '',
    phone: json[ApiKeys.phoneKey] as String? ?? '',
    isPrimary: json[ApiKeys.isPrimaryKey] as bool? ?? false,
  );

  CustomerContact toEntity() => CustomerContact(
    contactId: contactId,
    name: name,
    jobTitle: jobTitle,
    email: email,
    phone: phone,
    isPrimary: isPrimary,
  );
}
