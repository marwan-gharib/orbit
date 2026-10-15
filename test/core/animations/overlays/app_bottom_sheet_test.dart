import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/animations/animations.dart';

import 'harness.dart';

void main() {
  /// Pumps a button that opens a pick sheet, handing its future to [onSheet]
  /// so the test can await its result.
  Future<void> pumpPickSheet(
    WidgetTester tester, {
    required void Function(Future<String?> sheet) onSheet,
    bool disableAnimations = false,
  }) {
    return pumpOverlays(
      tester,
      Builder(
        builder: (context) => Center(
          child: FilledButton(
            onPressed: () => onSheet(
              AppBottomSheet.show<String>(
                context: context,
                isScrollControlled: true,
                builder: (context) => TextButton(
                  onPressed: () => Navigator.pop(context, 'chosen'),
                  child: const Text('pick'),
                ),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
      disableAnimations: disableAnimations,
    );
  }

  testWidgets(
    'should show a sheet with a drag handle and resolve with its result',
    (tester) async {
      String? result;
      await pumpPickSheet(
        tester,
        onSheet: (sheet) => sheet.then((value) => result = value),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      final BottomSheet sheet = tester.widget<BottomSheet>(
        find.byType(BottomSheet),
      );
      expect(sheet.showDragHandle, isTrue);
      expect(find.text('pick'), findsOneWidget);

      await tester.tap(find.text('pick'));
      await tester.pumpAndSettle();

      expect(result, 'chosen');
      expect(find.byType(BottomSheet), findsNothing);
    },
  );

  testWidgets(
    'should render the final state immediately when animations are disabled',
    (tester) async {
      await pumpPickSheet(tester, onSheet: (_) {}, disableAnimations: true);

      await tester.tap(find.text('open'));
      await tester.pump();

      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.text('pick'), findsOneWidget);
    },
  );
}
