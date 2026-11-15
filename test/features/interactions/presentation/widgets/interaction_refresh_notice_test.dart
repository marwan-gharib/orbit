import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/features/interactions/presentation/widgets/interaction_refresh_notice.dart';

import '../../../../core/widgets/harness.dart';

void main() {
  group('InteractionRefreshNotice', () {
    testWidgets('should show the message and the dismiss control', (
      WidgetTester tester,
    ) async {
      var dismissed = false;

      await pumpWidget(
        tester,
        InteractionRefreshNotice(
          message: 'Refresh failed — previous data kept',
          dismissLabel: 'Dismiss',
          onDismiss: () => dismissed = true,
        ),
      );

      expect(find.text('Refresh failed — previous data kept'), findsOneWidget);
      expect(find.byIcon(Icons.sync_problem), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);

      final close = tester.widget<IconButton>(find.byType(IconButton));
      expect(close.tooltip, 'Dismiss');

      await tester.tap(find.byType(IconButton));
      expect(dismissed, isTrue);
    });
  });
}
