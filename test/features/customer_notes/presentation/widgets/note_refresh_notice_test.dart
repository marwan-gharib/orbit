import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/features/customer_notes/presentation/widgets/note_refresh_notice.dart';

import '../../../../core/widgets/harness.dart';

void main() {
  const message = 'Could not refresh notes. Showing the previous list.';
  const dismissLabel = 'Dismiss';

  group('NoteRefreshNotice', () {
    testWidgets('should render the failure copy with a dismiss control', (
      tester,
    ) async {
      await pumpWidget(
        tester,
        NoteRefreshNotice(
          message: message,
          dismissLabel: dismissLabel,
          onDismiss: () {},
        ),
      );

      expect(find.text(message), findsOneWidget);
      expect(find.byTooltip(dismissLabel), findsOneWidget);
    });

    testWidgets('should call onDismiss when the user dismisses the notice', (
      tester,
    ) async {
      var dismissed = 0;
      await pumpWidget(
        tester,
        NoteRefreshNotice(
          message: message,
          dismissLabel: dismissLabel,
          onDismiss: () => dismissed++,
        ),
      );

      await tester.tap(find.byTooltip(dismissLabel));
      await tester.pump();

      expect(dismissed, 1);
    });
  });
}
