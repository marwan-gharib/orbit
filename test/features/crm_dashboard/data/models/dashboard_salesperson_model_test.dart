import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/features/crm_dashboard/data/models/dashboard_salesperson_model.dart';
import 'package:orbit/features/crm_dashboard/domain/entities/dashboard_salesperson_entity.dart';

void main() {
  group('DashboardSalespersonModel', () {
    test('should map from JSON', () {
      final model = DashboardSalespersonModel.fromJson({
        ApiKeys.employeeIdKey: 22,
        ApiKeys.employeeNameKey: 'Omar Mohammed',
        ApiKeys.wonValueKey: 120000,
        ApiKeys.wonCountKey: 5,
      });

      expect(model.employeeId, 22);
      expect(model.employeeName, 'Omar Mohammed');
      expect(model.wonValue, 120000.0);
      expect(model.wonCount, 5);
    });

    test('should default missing or mistyped fields to neutral values', () {
      final model = DashboardSalespersonModel.fromJson({
        ApiKeys.employeeIdKey: null,
        ApiKeys.employeeNameKey: 42,
        ApiKeys.wonValueKey: null,
        ApiKeys.wonCountKey: 'x',
      });

      expect(model.employeeId, 0);
      expect(model.employeeName, '');
      expect(model.wonValue, 0);
      expect(model.wonCount, 0);
    });

    test('should convert to entity', () {
      final entity = DashboardSalespersonModel.fromJson({
        ApiKeys.employeeIdKey: 22,
        ApiKeys.employeeNameKey: 'Omar Mohammed',
        ApiKeys.wonValueKey: 120000,
        ApiKeys.wonCountKey: 5,
      }).toEntity();

      expect(entity, isA<DashboardSalesperson>());
      expect(entity.employeeId, 22);
      expect(entity.employeeName, 'Omar Mohammed');
      expect(entity.wonValue, 120000.0);
      expect(entity.wonCount, 5);
    });
  });
}
