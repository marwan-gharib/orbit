import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/features/crm_dashboard/domain/entities/dashboard_month_point_entity.dart';
import 'package:orbit/features/crm_dashboard/domain/entities/dashboard_overview_entity.dart';
import 'package:orbit/features/crm_dashboard/domain/entities/dashboard_salesperson_entity.dart';
import 'package:orbit/features/crm_dashboard/domain/entities/dashboard_win_ratio_entity.dart';
import 'package:orbit/features/crm_dashboard/presentation/pure/dashboard_insights.dart';

import '../../crm_dashboard_test_mocks.dart';

void main() {
  group('forecastCoverage', () {
    test('should return the weighted share of the open pipeline', () {
      expect(forecastCoverage(tOverview()), closeTo(0.5, 0.0001));
    });

    test('should clamp shares above one to one', () {
      final overview = tOverview(openValue: 1000);
      expect(forecastCoverage(overview), 1.0);
    });

    test('should return zero when the open pipeline is empty', () {
      expect(forecastCoverage(tEmptyOverview()), 0);
    });
  });

  group('averageOpenDeal', () {
    test('should divide the open pipeline value by its count', () {
      expect(averageOpenDeal(tOverview()), 25000);
    });

    test('should return zero when no deals are open', () {
      expect(averageOpenDeal(tEmptyOverview()), 0);
    });
  });

  group('shareOf', () {
    test('should return the share of the total', () {
      expect(shareOf(30, 120), closeTo(0.25, 0.0001));
    });

    test('should return zero for a non-positive total', () {
      expect(shareOf(30, 0), 0);
      expect(shareOf(30, -5), 0);
    });

    test('should clamp shares above one to one', () {
      expect(shareOf(150, 100), 1.0);
    });
  });

  group('rankSalesTeam', () {
    test('should order the team by won value, highest first', () {
      final ranked = rankSalesTeam(tOverview().salesTeam);

      expect(ranked.map((s) => s.employeeName), ['Omar Mohammed', 'Hana Adel']);
    });

    test('should not mutate the input list', () {
      final team = tOverview().salesTeam;
      rankSalesTeam(team);

      expect(team.first.employeeName, 'Omar Mohammed');
    });

    test('should break value ties by won count, then keep alphabetical name '
        'order for exact ties', () {
      final ranked = rankSalesTeam([
        const DashboardSalesperson(
          employeeId: 1,
          employeeName: 'Ziad',
          wonValue: 100,
          wonCount: 2,
        ),
        const DashboardSalesperson(
          employeeId: 2,
          employeeName: 'Amr',
          wonValue: 100,
          wonCount: 2,
        ),
        const DashboardSalesperson(
          employeeId: 3,
          employeeName: 'Nada',
          wonValue: 100,
          wonCount: 5,
        ),
        const DashboardSalesperson(
          employeeId: 4,
          employeeName: 'Basel',
          wonValue: 300,
          wonCount: 1,
        ),
      ]);

      expect(ranked.map((s) => s.employeeName), [
        'Basel',
        'Nada',
        'Amr',
        'Ziad',
      ]);
    });
  });

  group('bestMonthIndex', () {
    test('should return the index of the highest-deal month', () {
      expect(bestMonthIndex(tOverview().months), 1);
    });

    test('should return null when every month is empty', () {
      final empty = tEmptyOverview().months;
      expect(bestMonthIndex(empty), isNull);
    });

    test('should keep the first month on a tie of zero values', () {
      final months = [
        DashboardMonthPoint(
          month: '2026-11',
          label: 'Nov 2026',
          dealValue: 0,
          weightedValue: 0,
        ),
      ];
      expect(bestMonthIndex(months), isNull);
    });
  });

  group('stageMetric', () {
    test('should return the value when ranking by value', () {
      final slice = tOverview().stages.first;
      expect(stageMetric(slice, byValue: true), 40000.0);
    });

    test('should return the count when ranking by count', () {
      final slice = tOverview().stages.first;
      expect(stageMetric(slice, byValue: false), 2.0);
    });
  });

  group('hasNoDashboardData', () {
    test('should be true for a brand-new CRM', () {
      expect(hasNoDashboardData(tEmptyOverview()), isTrue);
    });

    test('should be false when anything has data', () {
      expect(hasNoDashboardData(tOverview()), isFalse);
    });

    test('should be false when only the win ratio counts are non-zero', () {
      final overview = tEmptyOverview();
      final hasWon = DashboardOverview(
        currency: overview.currency,
        openPipeline: overview.openPipeline,
        weightedForecast: overview.weightedForecast,
        won: overview.won,
        winRatio: const DashboardWinRatio(
          percentage: 0,
          wonCount: 3,
          lostCount: 0,
        ),
        pastExpectedCloseCount: overview.pastExpectedCloseCount,
        stages: overview.stages,
        months: overview.months,
        salesTeam: overview.salesTeam,
      );
      expect(hasNoDashboardData(hasWon), isFalse);
    });
  });
}
