import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/features/opportunities/data/models/contact_model.dart';

void main() {
  group('ContactModel', () {
    const json = <String, dynamic>{
      ApiKeys.contactIdKey: 5,
      ApiKeys.nameKey: 'Hana Adel',
      ApiKeys.jobTitleKey: 'CTO',
      ApiKeys.emailKey: 'hana@pwc.com',
      ApiKeys.phoneKey: '01000000000',
      ApiKeys.isPrimaryKey: true,
    };

    test('should map from JSON', () {
      final model = ContactModel.fromJson(json);

      expect(model.contactId, 5);
      expect(model.name, 'Hana Adel');
      expect(model.jobTitle, 'CTO');
      expect(model.email, 'hana@pwc.com');
      expect(model.phone, '01000000000');
      expect(model.isPrimary, isTrue);
    });

    test('should default missing strings to empty and isPrimary to false', () {
      final model = ContactModel.fromJson({ApiKeys.contactIdKey: 1});

      expect(model.name, '');
      expect(model.jobTitle, '');
      expect(model.email, '');
      expect(model.phone, '');
      expect(model.isPrimary, isFalse);
    });

    test('should convert to entity', () {
      final entity = ContactModel.fromJson(json).toEntity();

      expect(entity.contactId, 5);
      expect(entity.name, 'Hana Adel');
      expect(entity.jobTitle, 'CTO');
      expect(entity.email, 'hana@pwc.com');
      expect(entity.phone, '01000000000');
      expect(entity.isPrimary, isTrue);
    });
  });
}
