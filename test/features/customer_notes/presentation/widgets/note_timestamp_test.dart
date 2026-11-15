import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/features/customer_notes/presentation/widgets/note_timestamp.dart';

import '../../../../core/widgets/harness.dart';

void main() {
  final now = DateTime.utc(2026, 11, 4, 12);

  group('NoteTimestamp', () {
    testWidgets('should render the localized relative bucket', (tester) async {
      await pumpWidget(
        tester,
        NoteTimestamp(createdAt: DateTime.utc(2026, 11, 4, 11, 55), now: now),
      );

      expect(find.text('5 minutes ago'), findsOneWidget);
    });

    testWidgets('should use singular copy for exactly one minute', (
      tester,
    ) async {
      await pumpWidget(
        tester,
        NoteTimestamp(createdAt: DateTime.utc(2026, 11, 4, 11, 59), now: now),
      );

      expect(find.text('1 minute ago'), findsOneWidget);
    });

    testWidgets('should expose the absolute CRM date as tooltip', (
      tester,
    ) async {
      await pumpWidget(
        tester,
        NoteTimestamp(createdAt: DateTime.utc(2026, 10, 19), now: now),
      );

      expect(find.text('19 Oct 2026'), findsNothing);
      expect(find.byTooltip('19 Oct 2026'), findsOneWidget);
    });

    testWidgets('should read the relative and absolute time together', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpWidget(
        tester,
        NoteTimestamp(createdAt: DateTime.utc(2026, 11, 4, 11, 55), now: now),
      );

      expect(
        find.bySemanticsLabel('5 minutes ago, 4 Nov 2026'),
        findsOneWidget,
      );
      handle.dispose();
    });
  });
}
