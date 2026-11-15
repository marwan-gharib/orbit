import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/core/network/base_api_client.dart';
import 'package:orbit/features/crm_dashboard/data/models/dashboard_overview_model.dart';
import 'package:orbit/features/crm_dashboard/domain/entities/dashboard_metric_entity.dart';
import 'package:orbit/features/crm_dashboard/domain/entities/dashboard_month_point_entity.dart';
import 'package:orbit/features/crm_dashboard/domain/entities/dashboard_overview_entity.dart';
import 'package:orbit/features/crm_dashboard/domain/entities/dashboard_salesperson_entity.dart';
import 'package:orbit/features/crm_dashboard/domain/entities/dashboard_stage_slice_entity.dart';
import 'package:orbit/features/crm_dashboard/domain/entities/dashboard_win_ratio_entity.dart';
import 'package:orbit/features/crm_dashboard/domain/enums/dashboard_stage.dart';
import 'package:orbit/features/crm_dashboard/domain/repositories/dashboard_repository.dart';
import 'package:orbit/features/crm_dashboard/domain/usecases/get_dashboard_overview_usecase.dart';
import 'package:orbit/features/crm_dashboard/presentation/cubits/dashboard/dashboard_cubit.dart';
import 'package:orbit/features/crm_dashboard/presentation/cubits/dashboard/dashboard_state.dart';

class MockBaseApiClient extends Mock implements BaseApiClient {}

class MockDashboardRepository extends Mock implements DashboardRepository {}

class MockGetDashboardOverviewUseCase extends Mock
    implements GetDashboardOverviewUseCase {}

class MockDashboardCubit extends MockCubit<DashboardState>
    implements DashboardCubit {}

/// Registers mocktail fallbacks once for all dashboard tests.
void registerDashboardFallbacks() {
  registerFallbackValue(tOverview());
}

/// An overview with live-looking data.
DashboardOverview tOverview({double openValue = 100000, int openCount = 4}) =>
    DashboardOverview(
      currency: 'EGP',
      openPipeline: DashboardMetric(value: openValue, count: openCount),
      weightedForecast: 50000,
      won: const DashboardMetric(value: 200000, count: 10),
      winRatio: const DashboardWinRatio(
        percentage: 60,
        wonCount: 6,
        lostCount: 4,
      ),
      pastExpectedCloseCount: 2,
      stages: [
        DashboardStageSlice(
          stage: DashboardStage.lead,
          label: 'Lead',
          value: 40000,
          count: 2,
        ),
        DashboardStageSlice(
          stage: DashboardStage.negotiation,
          label: 'Negotiation',
          value: 60000,
          count: 2,
        ),
      ],
      months: [
        DashboardMonthPoint(
          month: '2026-11',
          label: 'Nov 2026',
          dealValue: 30000,
          weightedValue: 15000,
        ),
        DashboardMonthPoint(
          month: '2026-12',
          label: 'Dec 2026',
          dealValue: 70000,
          weightedValue: 35000,
        ),
      ],
      salesTeam: [
        DashboardSalesperson(
          employeeId: 22,
          employeeName: 'Omar Mohammed',
          wonValue: 120000,
          wonCount: 5,
        ),
        DashboardSalesperson(
          employeeId: 31,
          employeeName: 'Hana Adel',
          wonValue: 80000,
          wonCount: 5,
        ),
      ],
    );

/// A brand-new CRM: everything at zero.
DashboardOverview tEmptyOverview() => DashboardOverview(
  currency: 'EGP',
  openPipeline: const DashboardMetric(value: 0, count: 0),
  weightedForecast: 0,
  won: const DashboardMetric(value: 0, count: 0),
  winRatio: const DashboardWinRatio(percentage: 0, wonCount: 0, lostCount: 0),
  pastExpectedCloseCount: 0,
  stages: const [
    DashboardStageSlice(
      stage: DashboardStage.lead,
      label: 'Lead',
      value: 0,
      count: 0,
    ),
  ],
  months: const [
    DashboardMonthPoint(
      month: '2026-11',
      label: 'Nov 2026',
      dealValue: 0,
      weightedValue: 0,
    ),
  ],
  salesTeam: const [],
);

/// The wire shape of [tOverview].
Map<String, dynamic> tOverviewJson({
  Object? pipelineByStage = const [
    {
      ApiKeys.stageKey: 'lead',
      ApiKeys.labelKey: 'Lead',
      ApiKeys.valueKey: 40000,
      ApiKeys.countKey: 2,
    },
    {
      ApiKeys.stageKey: 'negotiation',
      ApiKeys.labelKey: 'Negotiation',
      ApiKeys.valueKey: 60000,
      ApiKeys.countKey: 2,
    },
  ],
  Object? salesTeam = const [
    {
      ApiKeys.employeeIdKey: 22,
      ApiKeys.employeeNameKey: 'Omar Mohammed',
      ApiKeys.wonValueKey: 120000,
      ApiKeys.wonCountKey: 5,
    },
  ],
}) => <String, dynamic>{
  ApiKeys.currencyKey: 'EGP',
  ApiKeys.openPipelineKey: {ApiKeys.valueKey: 100000, ApiKeys.countKey: 4},
  ApiKeys.weightedForecastKey: {ApiKeys.valueKey: 50000},
  ApiKeys.wonKey: {ApiKeys.valueKey: 200000, ApiKeys.countKey: 10},
  ApiKeys.winRatioKey: {
    ApiKeys.percentageKey: 60,
    ApiKeys.wonCountKey: 6,
    ApiKeys.lostCountKey: 4,
  },
  ApiKeys.pastExpectedCloseKey: {ApiKeys.countKey: 2},
  ApiKeys.pipelineByStageKey: pipelineByStage,
  ApiKeys.expectedClosingsByMonthKey: const [
    {
      ApiKeys.monthKey: '2026-11',
      ApiKeys.labelKey: 'Nov 2026',
      ApiKeys.dealValueKey: 30000,
      ApiKeys.weightedValueKey: 15000,
    },
  ],
  ApiKeys.salesTeamKey: salesTeam,
};

/// The parsed model of [tOverviewJson].
DashboardOverviewModel tOverviewModel() =>
    DashboardOverviewModel.fromJson(tOverviewJson());

/// Failure used across dashboard tests.
ServerFailure tDashboardFailure() => ServerFailure(message: 'down');
