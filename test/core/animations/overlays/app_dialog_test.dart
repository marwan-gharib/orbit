import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/animations/animations.dart';
import 'package:orbit/core/widgets/app_dialog.dart';

import 'harness.dart';

void main() {
  /// Pumps a button that opens a confirm dialog, handing the dialog's future
  /// to [onDialog] so the test can await its result.
  Future<void> pumpConfirmDialog(
    WidgetTester tester, {
    required void Function(Future<bool?> dialog) onDialog,
    bool blurBarrier = true,
    bool disableAnimations = false,
  }) {
    return pumpOverlays(
      tester,
      Builder(
        builder: (context) => Center(
          child: FilledButton(
            onPressed: () => onDialog(
              showAppDialog<bool>(
                context: context,
                blurBarrier: blurBarrier,
                builder: (context) => AppDialog(
                  title: const Text('confirm'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('yes'),
                    ),
                  ],
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
    'should show the content with the focus-pull entrance and resolve with its result',
    (tester) async {
      bool? result;
      await pumpConfirmDialog(
        tester,
        onDialog: (dialog) => dialog.then((value) => result = value),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('confirm'), findsOneWidget);
      expect(find.byType(BlurIn), findsOneWidget);
      expect(find.byType(ScaleIn), findsOneWidget);

      await tester.tap(find.text('yes'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
      expect(find.text('confirm'), findsNothing);
    },
  );

  testWidgets('should blur the page behind the barrier while open', (
    tester,
  ) async {
    bool? result;
    await pumpConfirmDialog(
      tester,
      onDialog: (dialog) => dialog.then((value) => result = value),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.byType(BackdropFilter), findsOneWidget);
    // The dialog sits above the blurred barrier, never inside it.
    expect(
      find.descendant(
        of: find.byType(BackdropFilter),
        matching: find.text('confirm'),
      ),
      findsNothing,
    );

    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();

    expect(find.byType(BackdropFilter), findsNothing);
    expect(result, isNull);
  });

  testWidgets('should skip the blur but keep the scrim on request', (
    tester,
  ) async {
    await pumpConfirmDialog(tester, onDialog: (_) {}, blurBarrier: false);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('confirm'), findsOneWidget);
    expect(find.byType(BackdropFilter), findsNothing);
  });

  testWidgets(
    'should render the final state immediately when animations are disabled',
    (tester) async {
      await pumpConfirmDialog(
        tester,
        onDialog: (_) {},
        disableAnimations: true,
      );

      await tester.tap(find.text('open'));
      await tester.pump();

      expect(find.text('confirm'), findsOneWidget);
      // The focus pull is already sharp: no filter on the content.
      expect(find.byType(ImageFiltered), findsNothing);
      // The backdrop blur, however, is at full strength in the final state.
      expect(find.byType(BackdropFilter), findsOneWidget);
    },
  );
}
