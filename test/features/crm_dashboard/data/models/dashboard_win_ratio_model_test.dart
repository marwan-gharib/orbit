import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/features/crm_dashboard/data/models/dashboard_win_ratio_model.dart';
import 'package:orbit/features/crm_dashboard/domain/entities/dashboard_win_ratio_entity.dart';

void main() {
  group('DashboardWinRatioModel', () {
    test('should map from JSON', () {
      final model = DashboardWinRatioModel.fromJson({
        ApiKeys.percentageKey: 60,
        ApiKeys.wonCountKey: 6,
        ApiKeys.lostCountKey: 4,
      });

      expect(model.percentage, 60.0);
      expect(model.wonCount, 6);
      expect(model.lostCount, 4);
    });

    test('should default missing or mistyped fields to neutral values', () {
      final model = DashboardWinRatioModel.fromJson({
        ApiKeys.percentageKey: null,
        ApiKeys.wonCountKey: 'x',
      });

      expect(model.percentage, 0);
      expect(model.wonCount, 0);
      expect(model.lostCount, 0);
    });

    test('should convert to entity', () {
      final entity = DashboardWinRatioModel.fromJson({
        ApiKeys.percentageKey: 60,
        ApiKeys.wonCountKey: 6,
        ApiKeys.lostCountKey: 4,
      }).toEntity();

      expect(entity, isA<DashboardWinRatio>());
      expect(entity.percentage, 60.0);
      expect(entity.wonCount, 6);
      expect(entity.lostCount, 4);
    });
  });
}
