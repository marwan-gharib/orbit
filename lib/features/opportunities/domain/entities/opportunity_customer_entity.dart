import 'package:equatable/equatable.dart';

import 'customer_contact_entity.dart';
import 'embedded_customer_interaction_entity.dart';
import 'embedded_customer_note_entity.dart';

/// Customer aggregate nested inside an opportunity. Its notes/interactions
/// are the lighter embedded shapes; this entity is not shared with the
/// standalone notes or interactions features.
final class OpportunityCustomer extends Equatable {
  const OpportunityCustomer({
    required this.customerId,
    required this.customerCode,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.companyName,
    required this.email,
    required this.address,
    this.leadSource,
    required this.createdAt,
    required this.updatedAt,
    required this.contacts,
    required this.notes,
    required this.interactions,
  });

  final int customerId;
  final String customerCode;
  final String firstName;
  final String lastName;
  final String phone;
  final String companyName;
  final String email;
  final String address;
  final String? leadSource;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<CustomerContact> contacts;
  final List<EmbeddedCustomerNote> notes;
  final List<EmbeddedCustomerInteraction> interactions;

  @override
  List<Object?> get props => [
    customerId,
    customerCode,
    firstName,
    lastName,
    phone,
    companyName,
    email,
    address,
    leadSource,
    createdAt,
    updatedAt,
    contacts,
    notes,
    interactions,
  ];
}
