import '../../domain/entities/dashboard_month_point_entity.dart';
import '../../domain/entities/dashboard_overview_entity.dart';
import '../../domain/entities/dashboard_salesperson_entity.dart';
import '../../domain/entities/dashboard_stage_slice_entity.dart';

/// Display-only derivations of the overview. Nothing here is business logic:
/// every figure comes from the API, these only reshape it for the charts.

/// Weighted forecast as a share (0..1) of the open pipeline value.
double forecastCoverage(DashboardOverview overview) {
  final open = overview.openPipeline.value;
  if (open <= 0) return 0;
  return (overview.weightedForecast / open).clamp(0.0, 1.0);
}

/// Open pipeline value per open opportunity (0 when there are none).
double averageOpenDeal(DashboardOverview overview) {
  final count = overview.openPipeline.count;
  return count <= 0 ? 0 : overview.openPipeline.value / count;
}

/// [part] as a share (0..1) of [total]; 0 when [total] is not positive.
double shareOf(double part, double total) =>
    total <= 0 ? 0 : (part / total).clamp(0.0, 1.0);

/// Sales team ordered by won value, highest first. Ties keep a stable order
/// (more won deals first, then by name).
List<DashboardSalesperson> rankSalesTeam(List<DashboardSalesperson> team) {
  final ranked = [...team];
  ranked.sort((a, b) {
    final byValue = b.wonValue.compareTo(a.wonValue);
    if (byValue != 0) return byValue;
    final byCount = b.wonCount.compareTo(a.wonCount);
    if (byCount != 0) return byCount;
    return a.employeeName.compareTo(b.employeeName);
  });
  return ranked;
}

/// Index of the month with the highest deal value, or null when every month
/// is empty.
int? bestMonthIndex(List<DashboardMonthPoint> months) {
  int? best;
  var bestValue = 0.0;
  for (final (i, month) in months.indexed) {
    if (month.dealValue > bestValue) {
      bestValue = month.dealValue;
      best = i;
    }
  }
  return best;
}

/// The value or the count of a stage, depending on the chosen metric.
double stageMetric(DashboardStageSlice slice, {required bool byValue}) =>
    byValue ? slice.value : slice.count.toDouble();

/// True when there is nothing to chart at all (a brand-new CRM).
bool hasNoDashboardData(DashboardOverview overview) =>
    overview.openPipeline.count == 0 &&
    overview.won.count == 0 &&
    overview.winRatio.wonCount == 0 &&
    overview.winRatio.lostCount == 0 &&
    overview.pastExpectedCloseCount == 0 &&
    overview.stages.every((s) => s.value == 0 && s.count == 0) &&
    overview.months.every((m) => m.dealValue == 0 && m.weightedValue == 0) &&
    overview.salesTeam.isEmpty;
