import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/features/crm_dashboard/domain/enums/dashboard_stage.dart';

void main() {
  group('DashboardStage', () {
    test('should parse every known wire value', () {
      expect(DashboardStage.fromValue('lead'), DashboardStage.lead);
      expect(DashboardStage.fromValue('qualified'), DashboardStage.qualified);
      expect(DashboardStage.fromValue('proposal'), DashboardStage.proposal);
      expect(
        DashboardStage.fromValue('negotiation'),
        DashboardStage.negotiation,
      );
      expect(DashboardStage.fromValue('closed'), DashboardStage.closed);
    });

    test('should fall back to unknown for null or unrecognised values', () {
      expect(DashboardStage.fromValue(null), DashboardStage.unknown);
      expect(DashboardStage.fromValue(''), DashboardStage.unknown);
      expect(DashboardStage.fromValue('SIGNING'), DashboardStage.unknown);
      expect(
        DashboardStage.fromValue('lead-with-typo'),
        DashboardStage.unknown,
      );
    });
  });
}
