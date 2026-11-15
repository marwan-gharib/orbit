import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/features/opportunities/data/models/opportunity_model.dart';
import 'package:orbit/features/opportunities/domain/enums/opportunity_stage.dart';
import 'package:orbit/features/opportunities/domain/enums/opportunity_status.dart';

import '../../opportunities_test_mocks.dart';

void main() {
  group('OpportunityModel', () {
    test('should map from JSON', () {
      final model = OpportunityModel.fromJson(tOpportunityJson());

      expect(model.opportunityId, 1);
      expect(model.title, 'ERP license - 50 seats');
      expect(model.estimatedValue, 250000);
      expect(model.currency, 'EGP');
      expect(model.stage, OpportunityStage.fromValue('lead'));
      expect(model.probability, 10);
      expect(model.status, OpportunityStatus.fromValue('open'));
      expect(model.lostReason, '');
      expect(model.customer.customerId, 1);
      expect(model.employee.employeeId, 22);
    });

    test('should map estimated_value as num (int or double)', () {
      final intModel = OpportunityModel.fromJson(tOpportunityJson());
      expect(intModel.estimatedValue, isA<int>());

      final doubleJson = tOpportunityJson()..['estimated_value'] = 250000.50;
      final doubleModel = OpportunityModel.fromJson(doubleJson);
      expect(doubleModel.estimatedValue, isA<double>());
    });

    test('should map probability as int from num', () {
      final model = OpportunityModel.fromJson(tOpportunityJson());
      expect(model.probability, 10);
      expect(model.probability, isA<int>());
    });

    test('should convert to entity', () {
      final model = OpportunityModel.fromJson(tOpportunityJson());
      final entity = model.toEntity();

      expect(entity.opportunityId, 1);
      expect(entity.title, 'ERP license - 50 seats');
      expect(entity.probability, 10);
    });

    test('should handle nullable closed_at', () {
      final json = tOpportunityJson()..['closed_at'] = null;
      final model = OpportunityModel.fromJson(json);
      expect(model.closedAt, isNull);
    });
  });
}
