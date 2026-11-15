import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/features/opportunities/domain/enums/opportunity_stage.dart';

void main() {
  group('OpportunityStage', () {
    test('should map every known wire value', () {
      expect(OpportunityStage.fromValue('lead'), OpportunityStage.lead);
      expect(
        OpportunityStage.fromValue('qualified'),
        OpportunityStage.qualified,
      );
      expect(OpportunityStage.fromValue('proposal'), OpportunityStage.proposal);
      expect(
        OpportunityStage.fromValue('negotiation'),
        OpportunityStage.negotiation,
      );
      expect(OpportunityStage.fromValue('closed'), OpportunityStage.closed);
    });

    test('should fall back to unknown for null or blank', () {
      expect(OpportunityStage.fromValue(null), OpportunityStage.unknown);
      expect(OpportunityStage.fromValue(''), OpportunityStage.unknown);
      expect(OpportunityStage.fromValue('  '), OpportunityStage.unknown);
    });

    test('should fall back to unknown for unrecognized values', () {
      expect(OpportunityStage.fromValue('won'), OpportunityStage.unknown);
      expect(OpportunityStage.fromValue('ARCHIVED'), OpportunityStage.unknown);
    });

    test('should be case- and whitespace-tolerant', () {
      expect(OpportunityStage.fromValue('  LEAD  '), OpportunityStage.lead);
      expect(OpportunityStage.fromValue('Closed'), OpportunityStage.closed);
    });

    test('should have pipeline order as declaration order', () {
      expect(OpportunityStage.values.indexOf(OpportunityStage.lead), 0);
      expect(OpportunityStage.values.indexOf(OpportunityStage.qualified), 1);
      expect(OpportunityStage.values.indexOf(OpportunityStage.proposal), 2);
      expect(OpportunityStage.values.indexOf(OpportunityStage.negotiation), 3);
      expect(OpportunityStage.values.indexOf(OpportunityStage.closed), 4);
    });
  });
}
