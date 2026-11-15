import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/core/helpers/wire_dates.dart';

import '../../domain/entities/opportunity_customer_entity.dart';
import 'contact_model.dart';
import 'embedded_interaction_model.dart';
import 'embedded_note_model.dart';

final class OpportunityCustomerModel {
  const OpportunityCustomerModel({
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
  final List<ContactModel> contacts;
  final List<EmbeddedNoteModel> notes;
  final List<EmbeddedInteractionModel> interactions;

  factory OpportunityCustomerModel.fromJson(Map<String, dynamic> json) {
    final rawContacts = json[ApiKeys.contactsRootKey];
    final rawNotes = json[ApiKeys.notesRootKey];
    final rawInteractions = json[ApiKeys.interactionsRootKey];
    return OpportunityCustomerModel(
      customerId: json[ApiKeys.customerIdKey] as int,
      customerCode: json[ApiKeys.customerCodeKey] as String? ?? '',
      firstName: json[ApiKeys.firstNameKey] as String? ?? '',
      lastName: json[ApiKeys.lastNameKey] as String? ?? '',
      phone: json[ApiKeys.phoneKey] as String? ?? '',
      companyName: json[ApiKeys.companyNameKey] as String? ?? '',
      email: json[ApiKeys.emailKey] as String? ?? '',
      address: json[ApiKeys.addressKey] as String? ?? '',
      leadSource: json[ApiKeys.leadSourceKey] as String?,
      createdAt: WireDates.parseDateOnly(
        json[ApiKeys.createdAtKey] as String? ?? '',
      ),
      updatedAt: WireDates.parseDateOnly(
        json[ApiKeys.updatedAtKey] as String? ?? '',
      ),
      contacts: _list(rawContacts, ContactModel.fromJson),
      notes: _list(rawNotes, EmbeddedNoteModel.fromJson),
      interactions: _list(rawInteractions, EmbeddedInteractionModel.fromJson),
    );
  }

  static List<T> _list<T>(
    Object? raw,
    T Function(Map<String, dynamic>) mapper,
  ) {
    if (raw is! List) return <T>[];
    return [
      for (final item in raw)
        if (item is Map) mapper(Map<String, dynamic>.from(item)),
    ];
  }

  OpportunityCustomer toEntity() => OpportunityCustomer(
    customerId: customerId,
    customerCode: customerCode,
    firstName: firstName,
    lastName: lastName,
    phone: phone,
    companyName: companyName,
    email: email,
    address: address,
    leadSource: leadSource,
    createdAt: createdAt,
    updatedAt: updatedAt,
    contacts: contacts.map((m) => m.toEntity()).toList(),
    notes: notes.map((m) => m.toEntity()).toList(),
    interactions: interactions.map((m) => m.toEntity()).toList(),
  );
}
