import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/features/crm_dashboard/data/models/dashboard_month_point_model.dart';
import 'package:orbit/features/crm_dashboard/domain/entities/dashboard_month_point_entity.dart';

void main() {
  group('DashboardMonthPointModel', () {
    test('should map from JSON', () {
      final model = DashboardMonthPointModel.fromJson({
        ApiKeys.monthKey: '2026-11',
        ApiKeys.labelKey: 'Nov 2026',
        ApiKeys.dealValueKey: 30000,
        ApiKeys.weightedValueKey: 15000,
      });

      expect(model.month, '2026-11');
      expect(model.label, 'Nov 2026');
      expect(model.dealValue, 30000.0);
      expect(model.weightedValue, 15000.0);
    });

    test('should default missing or mistyped fields to neutral values', () {
      final model = DashboardMonthPointModel.fromJson({
        ApiKeys.monthKey: 2026,
        ApiKeys.labelKey: null,
        ApiKeys.dealValueKey: 'x',
      });

      expect(model.month, '');
      expect(model.label, '');
      expect(model.dealValue, 0);
      expect(model.weightedValue, 0);
    });

    test('should convert to entity', () {
      final entity = DashboardMonthPointModel.fromJson({
        ApiKeys.monthKey: '2026-11',
        ApiKeys.labelKey: 'Nov 2026',
        ApiKeys.dealValueKey: 30000,
        ApiKeys.weightedValueKey: 15000,
      }).toEntity();

      expect(entity, isA<DashboardMonthPoint>());
      expect(entity.month, '2026-11');
      expect(entity.label, 'Nov 2026');
      expect(entity.dealValue, 30000.0);
      expect(entity.weightedValue, 15000.0);
    });
  });
}
