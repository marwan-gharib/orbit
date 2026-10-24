import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/features/auth/presentation/widgets/pending_info_notice.dart';

import '../../../../core/widgets/harness.dart';

void main() {
  group('PendingInfoNotice', () {
    testWidgets('should render the message with an info icon', (tester) async {
      await pumpWidget(
        tester,
        const PendingInfoNotice(message: 'No change yet. Still under review.'),
      );

      expect(find.text('No change yet. Still under review.'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('should announce the message through semantics', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpWidget(
        tester,
        const PendingInfoNotice(message: 'No change yet. Still under review.'),
      );

      expect(
        find.bySemanticsLabel('No change yet. Still under review.'),
        findsOneWidget,
      );
      handle.dispose();
    });
  });
}
