import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/features/crm_dashboard/data/models/dashboard_overview_model.dart';

import '../../crm_dashboard_test_mocks.dart';

void main() {
  group('DashboardOverviewModel', () {
    test('should map the whole response body from JSON', () {
      final model = DashboardOverviewModel.fromJson(tOverviewJson());

      expect(model.currency, 'EGP');
      expect(model.openPipeline.value, 100000.0);
      expect(model.openPipeline.count, 4);
      expect(model.weightedForecast, 50000.0);
      expect(model.won.value, 200000.0);
      expect(model.won.count, 10);
      expect(model.winRatio.percentage, 60.0);
      expect(model.winRatio.wonCount, 6);
      expect(model.winRatio.lostCount, 4);
      expect(model.pastExpectedCloseCount, 2);
      expect(model.stages, hasLength(2));
      expect(model.stages[0].stage, 'lead');
      expect(model.months.single.month, '2026-11');
      expect(model.salesTeam.single.employeeId, 22);
    });

    test('should default missing keys to neutral values', () {
      final model = DashboardOverviewModel.fromJson(<String, dynamic>{});

      expect(model.currency, '');
      expect(model.openPipeline.value, 0);
      expect(model.openPipeline.count, 0);
      expect(model.weightedForecast, 0);
      expect(model.won.value, 0);
      expect(model.winRatio.percentage, 0);
      expect(model.pastExpectedCloseCount, 0);
      expect(model.stages, isEmpty);
      expect(model.months, isEmpty);
      expect(model.salesTeam, isEmpty);
    });

    test('should throw FormatException when a list field holds a non-list '
        'value', () {
      expect(
        () => DashboardOverviewModel.fromJson(
          tOverviewJson(pipelineByStage: 'not a list'),
        ),
        throwsFormatException,
      );
    });

    test('should throw FormatException when a list item is not an object', () {
      expect(
        () => DashboardOverviewModel.fromJson(
          tOverviewJson(salesTeam: const ['oops']),
        ),
        throwsFormatException,
      );
    });

    test('should treat a null list field as an empty list', () {
      final model = DashboardOverviewModel.fromJson(
        tOverviewJson(pipelineByStage: null),
      );

      expect(model.stages, isEmpty);
    });

    test('should convert to entity with every child mapped', () {
      final entity = DashboardOverviewModel.fromJson(tOverviewJson())
          .toEntity();

      expect(entity.currency, 'EGP');
      expect(entity.openPipeline.value, 100000.0);
      expect(entity.weightedForecast, 50000.0);
      expect(entity.won.count, 10);
      expect(entity.winRatio.wonCount, 6);
      expect(entity.pastExpectedCloseCount, 2);
      expect(entity.stages, hasLength(2));
      expect(entity.months, hasLength(1));
      expect(entity.salesTeam.single.wonValue, 120000.0);
    });
  });
}
