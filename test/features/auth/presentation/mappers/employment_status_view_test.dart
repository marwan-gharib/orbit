import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/widgets/status_badge.dart';
import 'package:orbit/features/auth/domain/enums/employment_status.dart';
import 'package:orbit/features/auth/presentation/mappers/employment_status_view.dart';

import '../../../../core/widgets/harness.dart';

/// Pumps an inert subtree and returns its live context, so the extension
/// methods can resolve localized copy inside a real widget tree.
Future<BuildContext> pumpProbe(WidgetTester tester) async {
  final probeKey = UniqueKey();
  await pumpWidget(
    tester,
    KeyedSubtree(key: probeKey, child: const SizedBox.shrink()),
  );
  return tester.element(find.byKey(probeKey));
}

void main() {
  group('EmploymentStatusView', () {
    test('should treat approved and rejected as terminal', () {
      expect(EmploymentStatus.pending.isTerminal, isFalse);
      expect(EmploymentStatus.unknown.isTerminal, isFalse);
      expect(EmploymentStatus.approved.isTerminal, isTrue);
      expect(EmploymentStatus.rejected.isTerminal, isTrue);
    });

    testWidgets('should expose the localized label for every status', (
      tester,
    ) async {
      final context = await pumpProbe(tester);

      expect(
        EmploymentStatus.pending.label(context),
        t.auth.pending.statuses.pending,
      );
      expect(
        EmploymentStatus.approved.label(context),
        t.auth.pending.statuses.approved,
      );
      expect(
        EmploymentStatus.rejected.label(context),
        t.auth.pending.statuses.rejected,
      );
      expect(
        EmploymentStatus.unknown.label(context),
        t.auth.pending.statuses.unknown,
      );
    });

    test('should expose the badge severity for every status', () {
      expect(EmploymentStatus.pending.badgeStatus, AppStatus.warning);
      expect(EmploymentStatus.unknown.badgeStatus, AppStatus.info);
      expect(EmploymentStatus.approved.badgeStatus, AppStatus.success);
      expect(EmploymentStatus.rejected.badgeStatus, AppStatus.error);
    });
  });
}
