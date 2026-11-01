import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/features/opportunities/domain/enums/opportunity_status.dart';

void main() {
  group('OpportunityStatus', () {
    test('should map every known wire value', () {
      expect(OpportunityStatus.fromValue('open'), OpportunityStatus.open);
      expect(OpportunityStatus.fromValue('won'), OpportunityStatus.won);
      expect(OpportunityStatus.fromValue('lost'), OpportunityStatus.lost);
    });

    test('should fall back to unknown for null or blank', () {
      expect(OpportunityStatus.fromValue(null), OpportunityStatus.unknown);
      expect(OpportunityStatus.fromValue(''), OpportunityStatus.unknown);
    });

    test('should fall back to unknown for unrecognized values', () {
      expect(OpportunityStatus.fromValue('pending'), OpportunityStatus.unknown);
    });

    test('should be case- and whitespace-tolerant', () {
      expect(OpportunityStatus.fromValue('  OPEN  '), OpportunityStatus.open);
      expect(OpportunityStatus.fromValue('Lost'), OpportunityStatus.lost);
    });
  });
}
