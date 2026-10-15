import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/widgets/app_card.dart';

import 'harness.dart';

void main() {
  group('AppCard', () {
    testWidgets('should render Card with child', (tester) async {
      await pumpWidget(tester, const AppCard(child: Text('Card content')));
      expect(find.byType(Card), findsOneWidget);
      expect(find.text('Card content'), findsOneWidget);
    });

    testWidgets('should apply custom padding when provided', (tester) async {
      await pumpWidget(
        tester,
        const AppCard(padding: EdgeInsets.all(32), child: Text('Card content')),
      );
      final card = tester.widget<Card>(find.byType(Card));
      final padding = card.child as Padding;
      expect(padding.padding, equals(const EdgeInsets.all(32)));
    });

    testWidgets('should call onTap when tapped and onTap is provided', (
      tester,
    ) async {
      var tapped = false;
      await pumpWidget(
        tester,
        AppCard(onTap: () => tapped = true, child: const Text('Card content')),
      );
      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });

    testWidgets(
      'should call onLongPress when long pressed and onLongPress is provided',
      (tester) async {
        var longPressed = false;
        await pumpWidget(
          tester,
          AppCard(
            onLongPress: () => longPressed = true,
            child: const Text('Card content'),
          ),
        );
        await tester.longPress(find.byType(InkWell));
        expect(longPressed, isTrue);
      },
    );

    testWidgets('should not wrap in InkWell when no callbacks provided', (
      tester,
    ) async {
      await pumpWidget(tester, const AppCard(child: Text('Card content')));
      expect(find.byType(InkWell), findsNothing);
    });
  });
}
