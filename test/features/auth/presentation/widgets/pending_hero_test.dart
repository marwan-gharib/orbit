import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/features/auth/domain/enums/employment_status.dart';
import 'package:orbit/features/auth/presentation/widgets/pending_hero.dart';

import '../../../../core/widgets/harness.dart';

void main() {
  group('PendingHero', () {
    testWidgets('should hold the hourglass badge for a pending status', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpWidget(
        tester,
        const PendingHero(status: EmploymentStatus.pending),
      );

      expect(find.byIcon(Icons.hourglass_top_rounded), findsOneWidget);
      expect(find.bySemanticsLabel(t.auth.pending.a11y.hero), findsOneWidget);
      handle.dispose();
    });

    testWidgets('should show the check badge once approved', (tester) async {
      await pumpWidget(
        tester,
        const PendingHero(status: EmploymentStatus.approved, active: false),
      );

      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      expect(find.byIcon(Icons.hourglass_top_rounded), findsNothing);
    });

    testWidgets('should show the close badge once rejected', (tester) async {
      await pumpWidget(
        tester,
        const PendingHero(status: EmploymentStatus.rejected, active: false),
      );

      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });

    testWidgets('should show the inspection badge for an unknown status', (
      tester,
    ) async {
      await pumpWidget(
        tester,
        const PendingHero(status: EmploymentStatus.unknown),
      );

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });
  });
}
