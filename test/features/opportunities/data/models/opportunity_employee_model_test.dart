import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/features/opportunities/data/models/opportunity_employee_model.dart';

void main() {
  group('OpportunityEmployeeModel', () {
    test('should map from JSON', () {
      final model = OpportunityEmployeeModel.fromJson({
        ApiKeys.employeeIdKey: 22,
        ApiKeys.employeeNameKey: 'Omar Mohammed',
      });

      expect(model.employeeId, 22);
      expect(model.employeeName, 'Omar Mohammed');
    });

    test('should default a missing employee_name to an empty string', () {
      final model = OpportunityEmployeeModel.fromJson({
        ApiKeys.employeeIdKey: 3,
      });

      expect(model.employeeId, 3);
      expect(model.employeeName, '');
    });

    test('should convert to entity', () {
      final entity = OpportunityEmployeeModel.fromJson({
        ApiKeys.employeeIdKey: 22,
        ApiKeys.employeeNameKey: 'Omar Mohammed',
      }).toEntity();

      expect(entity.employeeId, 22);
      expect(entity.employeeName, 'Omar Mohammed');
    });
  });
}
