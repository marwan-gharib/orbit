import 'package:equatable/equatable.dart';

/// Share of closed opportunities that were won.
final class DashboardWinRatio extends Equatable {
  const DashboardWinRatio({
    required this.percentage,
    required this.wonCount,
    required this.lostCount,
  });

  /// 0..100, as sent by the API.
  final double percentage;
  final int wonCount;
  final int lostCount;

  @override
  List<Object?> get props => [percentage, wonCount, lostCount];
}
