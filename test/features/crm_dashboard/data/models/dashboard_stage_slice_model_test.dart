import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/features/crm_dashboard/data/models/dashboard_stage_slice_model.dart';
import 'package:orbit/features/crm_dashboard/domain/entities/dashboard_stage_slice_entity.dart';
import 'package:orbit/features/crm_dashboard/domain/enums/dashboard_stage.dart';

void main() {
  group('DashboardStageSliceModel', () {
    test('should map from JSON', () {
      final model = DashboardStageSliceModel.fromJson({
        ApiKeys.stageKey: 'negotiation',
        ApiKeys.labelKey: 'Negotiation',
        ApiKeys.valueKey: 60000,
        ApiKeys.countKey: 2,
      });

      expect(model.stage, 'negotiation');
      expect(model.label, 'Negotiation');
      expect(model.value, 60000.0);
      expect(model.count, 2);
    });

    test('should default missing or mistyped fields to neutral values', () {
      final model = DashboardStageSliceModel.fromJson({
        ApiKeys.stageKey: 'SIGNING',
        ApiKeys.labelKey: null,
        ApiKeys.valueKey: 'x',
        ApiKeys.countKey: null,
      });

      expect(model.stage, 'SIGNING');
      expect(model.label, '');
      expect(model.value, 0);
      expect(model.count, 0);
    });

    test('should convert to entity', () {
      final entity = DashboardStageSliceModel.fromJson({
        ApiKeys.stageKey: 'lead',
        ApiKeys.labelKey: 'Lead',
        ApiKeys.valueKey: 40000,
        ApiKeys.countKey: 2,
      }).toEntity();

      expect(entity, isA<DashboardStageSlice>());
      expect(entity.stage, DashboardStage.lead);
      expect(entity.label, 'Lead');
      expect(entity.value, 40000.0);
      expect(entity.count, 2);
    });
  });
}
