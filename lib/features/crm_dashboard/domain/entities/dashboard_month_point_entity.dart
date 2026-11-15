import 'package:equatable/equatable.dart';

/// Expected closings of one month: total deal value and its weighted value.
final class DashboardMonthPoint extends Equatable {
  const DashboardMonthPoint({
    required this.month,
    required this.label,
    required this.dealValue,
    required this.weightedValue,
  });

  /// `yyyy-MM`, as sent by the API.
  final String month;

  /// Short month name (e.g. "Aug").
  final String label;
  final double dealValue;
  final double weightedValue;

  @override
  List<Object?> get props => [month, label, dealValue, weightedValue];
}
