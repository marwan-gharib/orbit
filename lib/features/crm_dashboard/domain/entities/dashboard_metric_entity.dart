import 'package:equatable/equatable.dart';

/// A money total together with how many opportunities it covers.
final class DashboardMetric extends Equatable {
  const DashboardMetric({required this.value, required this.count});

  final double value;
  final int count;

  @override
  List<Object?> get props => [value, count];
}
