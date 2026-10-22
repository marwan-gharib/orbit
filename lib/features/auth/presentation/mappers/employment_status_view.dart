import 'package:flutter/widgets.dart';

import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/widgets/status_badge.dart';

import '../../domain/enums/employment_status.dart';

/// Presentation mapping for [EmploymentStatus]: localized copy and the badge
/// severity that goes with it. The domain enum stays copy- and Flutter-free.
extension EmploymentStatusView on EmploymentStatus {
  /// A decision has been made; the pending flow must end after its moment.
  bool get isTerminal =>
      this == EmploymentStatus.approved || this == EmploymentStatus.rejected;

  /// Localized status label shown in the badge.
  String label(BuildContext context) => switch (this) {
    EmploymentStatus.pending => context.t.auth.pending.statuses.pending,
    EmploymentStatus.approved => context.t.auth.pending.statuses.approved,
    EmploymentStatus.rejected => context.t.auth.pending.statuses.rejected,
    EmploymentStatus.unknown => context.t.auth.pending.statuses.unknown,
  };

  /// Badge severity for the current status.
  AppStatus get badgeStatus => switch (this) {
    EmploymentStatus.pending => AppStatus.warning,
    EmploymentStatus.approved => AppStatus.success,
    EmploymentStatus.rejected => AppStatus.error,
    EmploymentStatus.unknown => AppStatus.info,
  };
}
