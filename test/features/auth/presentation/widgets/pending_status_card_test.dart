import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/features/auth/domain/enums/employment_status.dart';
import 'package:orbit/features/auth/presentation/widgets/pending_status_card.dart';

import '../../../../core/widgets/harness.dart';

void main() {
  group('PendingStatusCard', () {
    testWidgets('should show only the email before the first check', (
      tester,
    ) async {
      await pumpWidget(
        tester,
        const PendingStatusCard(
          email: 'adam@orbit.app',
          status: EmploymentStatus.pending,
          lastCheckedAt: null,
        ),
      );

      expect(find.text(t.auth.pending.emailLabel), findsOneWidget);
      expect(find.text('adam@orbit.app'), findsOneWidget);
      expect(find.text(t.auth.pending.statuses.pending), findsOneWidget);
      expect(find.text(t.auth.pending.lastCheckedNever), findsOneWidget);
      expect(find.text(t.auth.pending.greeting(name: 'Adam')), findsNothing);
    });

    testWidgets(
      'should add the greeting and the last-checked time after a check',
      (tester) async {
        await pumpWidget(
          tester,
          PendingStatusCard(
            email: 'adam@orbit.app',
            status: EmploymentStatus.pending,
            lastCheckedAt: DateTime(2026, 1, 2, 15, 30),
            firstName: 'Adam',
          ),
        );

        expect(
          find.text(t.auth.pending.greeting(name: 'Adam')),
          findsOneWidget,
        );
        expect(find.text(t.auth.pending.lastCheckedNever), findsNothing);
        expect(find.textContaining('Last checked:'), findsOneWidget);
      },
    );

    testWidgets('should surface the approved badge after an approval', (
      tester,
    ) async {
      await pumpWidget(
        tester,
        const PendingStatusCard(
          email: 'adam@orbit.app',
          status: EmploymentStatus.approved,
          lastCheckedAt: null,
        ),
      );

      expect(find.text(t.auth.pending.statuses.approved), findsOneWidget);
    });
  });
}
