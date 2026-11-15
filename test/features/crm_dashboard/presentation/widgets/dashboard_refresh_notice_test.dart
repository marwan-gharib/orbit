import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/features/crm_dashboard/presentation/widgets/dashboard_refresh_notice.dart';

import '../../../../core/widgets/harness.dart';

void main() {
  testWidgets('should explain that the previous data stays on screen', (
    tester,
  ) async {
    await pumpWidget(tester, DashboardRefreshNotice(onDismiss: () {}));

    expect(find.text(t.crm.common.refreshFailedNotice), findsOneWidget);
  });

  testWidgets('should call onDismiss when Dismiss is tapped', (tester) async {
    var dismissed = false;
    await pumpWidget(
      tester,
      DashboardRefreshNotice(onDismiss: () => dismissed = true),
    );

    await tester.tap(find.text(t.crm.common.dismiss));
    await tester.pump();

    expect(dismissed, isTrue);
  });
}
