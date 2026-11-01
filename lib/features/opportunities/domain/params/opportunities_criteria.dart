import 'package:equatable/equatable.dart';

import '../enums/opportunity_stage.dart';
import '../enums/opportunity_status.dart';

/// Active filters of the opportunities list; a null field means unfiltered.
///
/// `opportunity_id` is NOT here — it belongs to the detail path only.
/// `employee_id` is NOT here — it is not sent as a query param (Edit 4).
final class OpportunitiesCriteria extends Equatable {
  const OpportunitiesCriteria({
    this.title,
    this.stage,
    this.status,
    this.customerId,
  });

  /// Free-text search; the backend does `contains` matching on `title`.
  final String? title;
  final OpportunityStage? stage;
  final OpportunityStatus? status;
  final int? customerId;

  @override
  List<Object?> get props => [title, stage, status, customerId];

  OpportunitiesCriteria copyWith({
    String? title,
    OpportunityStage? stage,
    OpportunityStatus? status,
    int? customerId,
  }) {
    return OpportunitiesCriteria(
      title: title ?? this.title,
      stage: stage ?? this.stage,
      status: status ?? this.status,
      customerId: customerId ?? this.customerId,
    );
  }
}
