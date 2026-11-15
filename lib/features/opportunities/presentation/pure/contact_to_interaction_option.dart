import 'package:orbit/features/interactions/presentation/view_models/interaction_tile_data.dart';
import 'package:orbit/features/opportunities/domain/entities/customer_contact_entity.dart';

/// Maps one customer contact to an option (label = the contact's name).
InteractionContactOption contactToInteractionOption(CustomerContact contact) =>
    InteractionContactOption(id: contact.contactId, label: contact.name);

/// Maps the customer's contacts to sheet options, making every label unique.
///
/// A label is the contact's name. Contacts that share a name get their job
/// title appended; if they still read the same, their phone (else email, else
/// id) is appended too, so the user can always tell them apart.
List<InteractionContactOption> contactsToInteractionOptions(
  List<CustomerContact> contacts,
) {
  final byName = _countBy(contacts, (c) => c.name);
  final withJob = [
    for (final c in contacts)
      byName[c.name]! > 1 && c.jobTitle.isNotEmpty
          ? '${c.name} \u00b7 ${c.jobTitle}'
          : c.name,
  ];
  final byLabel = <String, int>{};
  for (final label in withJob) {
    byLabel.update(label, (n) => n + 1, ifAbsent: () => 1);
  }
  return [
    for (final (i, c) in contacts.indexed)
      InteractionContactOption(
        id: c.contactId,
        label: byLabel[withJob[i]]! > 1
            ? '${withJob[i]} \u00b7 ${_distinguisher(c)}'
            : withJob[i],
      ),
  ];
}

Map<String, int> _countBy(
  List<CustomerContact> contacts,
  String Function(CustomerContact) key,
) {
  final counts = <String, int>{};
  for (final c in contacts) {
    counts.update(key(c), (n) => n + 1, ifAbsent: () => 1);
  }
  return counts;
}

String _distinguisher(CustomerContact contact) {
  if (contact.phone.isNotEmpty) return contact.phone;
  if (contact.email.isNotEmpty) return contact.email;
  return '#${contact.contactId}';
}
