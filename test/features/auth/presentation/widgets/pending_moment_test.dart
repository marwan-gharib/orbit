import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/features/auth/domain/enums/employment_status.dart';
import 'package:orbit/features/auth/presentation/widgets/pending_moment.dart';

import '../../../../core/widgets/harness.dart';

void main() {
  group('PendingMoment', () {
    testWidgets('should show the approved message with a check icon', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpWidget(
        tester,
        const PendingMoment(status: EmploymentStatus.approved),
      );

      expect(find.text(t.auth.pending.moments.approved), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      expect(
        find.bySemanticsLabel(t.auth.pending.moments.approved),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('should show the rejected message with a close icon', (
      tester,
    ) async {
      await pumpWidget(
        tester,
        const PendingMoment(status: EmploymentStatus.rejected),
      );

      expect(find.text(t.auth.pending.moments.rejected), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });
  });
}
