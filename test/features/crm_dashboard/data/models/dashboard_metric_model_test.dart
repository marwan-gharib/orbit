import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/features/crm_dashboard/data/models/dashboard_metric_model.dart';
import 'package:orbit/features/crm_dashboard/domain/entities/dashboard_metric_entity.dart';

void main() {
  group('DashboardMetricModel', () {
    test('should map from JSON, coercing an int value to double', () {
      final model = DashboardMetricModel.fromJson({
        ApiKeys.valueKey: 100000,
        ApiKeys.countKey: 4,
      });

      expect(model.value, 100000.0);
      expect(model.value, isA<double>());
      expect(model.count, 4);
    });

    test('should default missing or mistyped fields to neutral values', () {
      final model = DashboardMetricModel.fromJson({
        ApiKeys.valueKey: 'not a number',
        ApiKeys.countKey: null,
      });

      expect(model.value, 0);
      expect(model.count, 0);
    });

    test('should convert to entity', () {
      final entity = DashboardMetricModel.fromJson({
        ApiKeys.valueKey: 100000,
        ApiKeys.countKey: 4,
      }).toEntity();

      expect(entity, isA<DashboardMetric>());
      expect(entity.value, 100000.0);
      expect(entity.count, 4);
    });
  });
}
