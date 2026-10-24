import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/features/auth/domain/enums/employment_status.dart';
import 'package:orbit/features/auth/presentation/widgets/pending_stepper.dart';

import '../../../../core/widgets/harness.dart';

void main() {
  group('PendingStepper', () {
    testWidgets('should start only the submitted step while pending', (
      tester,
    ) async {
      await pumpWidget(
        tester,
        const PendingStepper(status: EmploymentStatus.pending),
      );

      expect(find.text(t.auth.pending.stepper.submitted), findsOneWidget);
      expect(find.text(t.auth.pending.stepper.review), findsOneWidget);
      expect(find.text(t.auth.pending.stepper.decision), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsNothing);
    });

    testWidgets('should finish every step when the decision is approved', (
      tester,
    ) async {
      await pumpWidget(
        tester,
        const PendingStepper(status: EmploymentStatus.approved),
      );

      expect(find.byIcon(Icons.check_rounded), findsNWidgets(3));
      expect(find.byIcon(Icons.close_rounded), findsNothing);
    });

    testWidgets('should show the cross icon for a rejected decision', (
      tester,
    ) async {
      await pumpWidget(
        tester,
        const PendingStepper(status: EmploymentStatus.rejected),
      );

      expect(find.byIcon(Icons.check_rounded), findsNWidgets(2));
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });

    testWidgets('should announce the approval progress through semantics', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpWidget(
        tester,
        const PendingStepper(status: EmploymentStatus.pending),
      );

      // The stepper merges its children into one container node; its label
      // is announced alongside the merged child text (joined with newlines).
      final node = tester.getSemantics(find.byType(PendingStepper));
      expect(node.label, contains(t.auth.pending.a11y.stepper));
      handle.dispose();
    });
  });
}
