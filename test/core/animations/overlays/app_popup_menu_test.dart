import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/animations/animations.dart';

import 'harness.dart';

void main() {
  /// Pumps an overflow anchor inset from its leading edge, so the menu
  /// geometry is predictable in both text directions.
  Future<void> pumpAnchor(
    WidgetTester tester, {
    required void Function(String value) onSelected,
    VoidCallback? onCanceled,
    double inset = 0,
    TextDirection direction = TextDirection.ltr,
    bool disableAnimations = false,
  }) {
    return pumpOverlays(
      tester,
      Align(
        alignment: AlignmentDirectional.topStart,
        child: Padding(
          padding: EdgeInsetsDirectional.only(top: 24, start: inset),
          child: AppPopupMenu<String>(
            onSelected: onSelected,
            onCanceled: onCanceled,
            items: const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'archive', child: Text('Archive')),
            ],
          ),
        ),
      ),
      direction: direction,
      disableAnimations: disableAnimations,
    );
  }

  testWidgets('should open from the anchor and report the picked value', (
    tester,
  ) async {
    String? picked;
    await pumpAnchor(tester, onSelected: (value) => picked = value);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(find.text('Edit'), findsOneWidget);

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(picked, 'edit');
    expect(find.text('Archive'), findsNothing);
  });

  testWidgets('should report a dismissal without a pick as canceled', (
    tester,
  ) async {
    var canceled = false;
    await pumpAnchor(
      tester,
      onSelected: (_) {},
      onCanceled: () => canceled = true,
    );

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(400, 550));
    await tester.pumpAndSettle();

    expect(canceled, isTrue);
  });

  testWidgets('should hang off the anchor edge in LTR', (tester) async {
    await pumpAnchor(tester, onSelected: (_) {}, inset: 300);
    final Rect anchor = tester.getRect(find.byType(IconButton));

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    final Rect menu = tester.getRect(find.byType(SingleChildScrollView));
    expect(menu.left, closeTo(anchor.left, 1.0));
    expect(menu.top, closeTo(anchor.bottom, 1.0));
  });

  testWidgets('should mirror the anchor edge in RTL', (tester) async {
    await pumpAnchor(
      tester,
      onSelected: (_) {},
      inset: 300,
      direction: TextDirection.rtl,
    );
    // The same leading inset now comes from the right, so the anchor sits
    // near the trailing edge and the menu must hang off its right side.
    final Rect anchor = tester.getRect(find.byType(IconButton));

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    final Rect menu = tester.getRect(find.byType(SingleChildScrollView));
    expect(menu.right, closeTo(anchor.right, 1.0));
    expect(menu.top, closeTo(anchor.bottom, 1.0));
  });

  testWidgets(
    'should appear in place immediately when animations are disabled',
    (tester) async {
      await pumpAnchor(tester, onSelected: (_) {}, disableAnimations: true);

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pump();

      expect(find.text('Edit'), findsOneWidget);
    },
  );
}
