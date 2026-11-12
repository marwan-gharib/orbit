import 'package:equatable/equatable.dart';

import '../enums/dashboard_stage.dart';

/// Open pipeline value and count of one stage.
final class DashboardStageSlice extends Equatable {
  const DashboardStageSlice({
    required this.stage,
    required this.label,
    required this.value,
    required this.count,
  });

  final DashboardStage stage;

  /// Display name sent by the API (e.g. "Prospecting").
  final String label;
  final double value;
  final int count;

  @override
  List<Object?> get props => [stage, label, value, count];
}
