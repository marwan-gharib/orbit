import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/features/opportunities/domain/entities/customer_contact_entity.dart';
import 'package:orbit/features/opportunities/presentation/pure/contact_to_interaction_option.dart';

void main() {
  CustomerContact contact({
    int id = 1,
    String name = 'Hana Adel',
    String jobTitle = 'CTO',
    String email = 'hana@pwc.com',
    String phone = '01000000000',
  }) => CustomerContact(
    contactId: id,
    name: name,
    jobTitle: jobTitle,
    email: email,
    phone: phone,
    isPrimary: false,
  );

  group('contactToInteractionOption', () {
    test('should map one contact to an option labelled by its name', () {
      final option = contactToInteractionOption(contact());

      expect(option.id, 1);
      expect(option.label, 'Hana Adel');
    });
  });

  group('contactsToInteractionOptions', () {
    test('should pass unique names through untouched, in order', () {
      final options = contactsToInteractionOptions([
        contact(id: 1, name: 'Hana Adel'),
        contact(id: 2, name: 'Omar Ibrahim'),
      ]);

      expect(options.map((o) => o.label), ['Hana Adel', 'Omar Ibrahim']);
      expect(options.map((o) => o.id), [1, 2]);
    });

    test('should append the job title when two contacts share a name and one '
        'has a job title', () {
      final options = contactsToInteractionOptions([
        contact(id: 1, name: 'Hana Adel', jobTitle: 'CTO'),
        contact(id: 2, name: 'Hana Adel', jobTitle: ''),
      ]);

      expect(options.map((o) => o.label), ['Hana Adel · CTO', 'Hana Adel']);
    });

    test('should append a distinguisher when same-name contacts still collide '
        'after the job titles', () {
      final options = contactsToInteractionOptions([
        contact(id: 1, name: 'Hana Adel', jobTitle: 'CTO', phone: '010111'),
        contact(id: 2, name: 'Hana Adel', jobTitle: 'CTO', phone: '010222'),
      ]);

      expect(options.map((o) => o.label), [
        'Hana Adel · CTO · 010111',
        'Hana Adel · CTO · 010222',
      ]);
    });

    test('should fall back to email, then the id, when phone is empty', () {
      final options = contactsToInteractionOptions([
        contact(
          id: 1,
          name: 'Hana Adel',
          jobTitle: 'CTO',
          phone: '',
          email: 'hana@pwc.com',
        ),
        contact(
          id: 7,
          name: 'Hana Adel',
          jobTitle: 'CTO',
          phone: '',
          email: '',
        ),
      ]);

      expect(options.map((o) => o.label), [
        'Hana Adel · CTO · hana@pwc.com',
        'Hana Adel · CTO · #7',
      ]);
    });

    test('should handle an empty list', () {
      expect(contactsToInteractionOptions(const []), isEmpty);
    });
  });
}
