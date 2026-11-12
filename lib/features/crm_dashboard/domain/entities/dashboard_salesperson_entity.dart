import 'package:equatable/equatable.dart';

/// One employee of the sales team ranking (won deals).
final class DashboardSalesperson extends Equatable {
  const DashboardSalesperson({
    required this.employeeId,
    required this.employeeName,
    required this.wonValue,
    required this.wonCount,
  });

  final int employeeId;
  final String employeeName;
  final double wonValue;
  final int wonCount;

  @override
  List<Object?> get props => [employeeId, employeeName, wonValue, wonCount];
}
