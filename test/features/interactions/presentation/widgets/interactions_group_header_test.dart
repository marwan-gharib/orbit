import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/features/interactions/presentation/constants/interaction_layout_constants.dart';
import 'package:orbit/features/interactions/presentation/widgets/interactions_group_header.dart';

import '../../../../core/widgets/harness.dart';

void main() {
  group('InteractionsGroupHeaderDelegate', () {
    test('should keep min and max extent at the shared header height', () {
      const delegate = InteractionsGroupHeaderDelegate(
        label: 'Today',
        count: 3,
      );

      expect(delegate.minExtent, InteractionLayoutConstants.groupHeaderHeight);
      expect(delegate.maxExtent, InteractionLayoutConstants.groupHeaderHeight);
    });

    testWidgets('should render Today, Yesterday and raw labels with count', (
      WidgetTester tester,
    ) async {
      await pumpWidget(
        tester,
        CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: const InteractionsGroupHeaderDelegate(
                label: 'crm.common.today',
                count: 2,
              ),
            ),
          ],
        ),
      );

      expect(find.text('Today'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today_rounded), findsOneWidget);
    });

    testWidgets('should pass a plain date label through untouched', (
      WidgetTester tester,
    ) async {
      await pumpWidget(
        tester,
        CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: const InteractionsGroupHeaderDelegate(
                label: '12 Nov 2026',
                count: 1,
              ),
            ),
          ],
        ),
      );

      expect(find.text('12 Nov 2026'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('should highlight the pill when the content overlaps', (
      WidgetTester tester,
    ) async {
      const delegate = InteractionsGroupHeaderDelegate(
        label: 'crm.common.yesterday',
        count: 4,
      );

      await pumpWidget(
        tester,
        CustomScrollView(
          slivers: [SliverPersistentHeader(pinned: true, delegate: delegate)],
        ),
      );
      expect(find.text('Yesterday'), findsOneWidget);

      final context = tester.element(find.byType(SliverPersistentHeader));
      final idleColor = context.colors.surfaceVariant;
      final overlapColor = context.colors.primaryContainer;
      // Build both variants while the captured context is still active; only
      // then pump them one by one to inspect their decorations.
      final idleWidget = delegate.build(context, 0, false);
      final overlapWidget = delegate.build(context, 0, true);

      final idlePill = await pumpBuiltPill(tester, idleWidget);
      final overlapPill = await pumpBuiltPill(tester, overlapWidget);

      expect((idlePill.decoration as BoxDecoration).color, idleColor);
      expect((overlapPill.decoration as BoxDecoration).color, overlapColor);
    });
  });
}

/// Pumps a delegate-built widget and returns its pill [DecoratedBox] — the
/// only one in the built tree that has a border radius (the outer one only
/// paints the row background).
Future<DecoratedBox> pumpBuiltPill(WidgetTester tester, Widget built) async {
  await pumpWidget(tester, built);
  return tester.widget<DecoratedBox>(
    find.byWidgetPredicate(
      (widget) =>
          widget is DecoratedBox &&
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).borderRadius != null,
    ),
  );
}
