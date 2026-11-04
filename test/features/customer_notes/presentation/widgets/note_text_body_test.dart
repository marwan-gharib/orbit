import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/features/customer_notes/presentation/widgets/note_text_body.dart';

import '../../../../core/widgets/harness.dart';

void main() {
  const shortText = 'Call back next week.';
  const longText =
      'Reviewed the renewal timeline with the customer and agreed to send a '
      'revised proposal before the end of the month. The customer will share '
      'the signed addendum with legal, and we will confirm the kickoff date '
      'once the documents are back. Follow up again in two weeks if nothing '
      'arrives, and keep the account manager in the loop.';

  group('NoteTextBody', () {
    testWidgets('should not offer Show more when the text fits', (
      tester,
    ) async {
      await pumpWidget(
        tester,
        const SizedBox(width: 320, child: NoteTextBody(text: shortText)),
      );

      expect(find.text(shortText), findsOneWidget);
      expect(find.text('Show more'), findsNothing);
    });

    testWidgets('should clamp long text and reveal it on Show more', (
      tester,
    ) async {
      await pumpWidget(
        tester,
        const SizedBox(width: 260, child: NoteTextBody(text: longText)),
      );

      expect(find.text('Show more'), findsOneWidget);
      expect(tester.widget<Text>(find.text(longText)).maxLines, 6);

      await tester.tap(find.text('Show more'));
      await tester.pumpAndSettle();

      expect(find.text('Show less'), findsOneWidget);
      expect(tester.widget<Text>(find.text(longText)).maxLines, isNull);
    });

    testWidgets('should clamp back on Show less', (tester) async {
      await pumpWidget(
        tester,
        const SizedBox(width: 260, child: NoteTextBody(text: longText)),
      );

      await tester.tap(find.text('Show more'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Show less'));
      await tester.pumpAndSettle();

      expect(find.text('Show more'), findsOneWidget);
      expect(tester.widget<Text>(find.text(longText)).maxLines, 6);
    });
  });
}
