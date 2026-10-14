import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/animations/animations.dart';

import 'harness.dart';

void main() {
  /// Pumps a button that shows a snackbar, handing its future to [onShow] so
  /// the test can await why it closed.
  Future<void> pumpSnackbarButton(
    WidgetTester tester, {
    required void Function(Future<AppSnackbarResult> snackbar) onShow,
    AppSnackbarType type = AppSnackbarType.info,
    ({String label, VoidCallback onPressed})? action,
    String message = 'Saved',
    bool disableAnimations = false,
  }) {
    return pumpOverlays(
      tester,
      Builder(
        builder: (context) => Center(
          child: FilledButton(
            onPressed: () => onShow(
              AppSnackbar.show(
                context,
                message: message,
                type: type,
                action: action,
              ),
            ),
            child: const Text('show'),
          ),
        ),
      ),
      disableAnimations: disableAnimations,
    );
  }

  /// Runs the auto-dismiss timer out, so no timer is left pending at the end
  /// of the test.
  Future<void> letItDismiss(WidgetTester tester) async {
    await tester.pumpAndSettle();
    await tester.pump(AppDurations.messageVisible);
    await tester.pumpAndSettle();
  }

  testWidgets('should tint the icon with the type color of the theme', (
    tester,
  ) async {
    await pumpSnackbarButton(
      tester,
      onShow: (_) {},
      type: AppSnackbarType.success,
    );

    await tester.tap(find.text('show'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Saved'), findsOneWidget);
    final Icon icon = tester.widget<Icon>(
      find.byIcon(Icons.check_circle_outline),
    );
    expect(icon.color, ThemeData().colorScheme.tertiary);

    await letItDismiss(tester);
  });

  testWidgets('should auto-dismiss after the visible token and report it', (
    tester,
  ) async {
    AppSnackbarResult? result;
    await pumpSnackbarButton(
      tester,
      onShow: (snackbar) => snackbar.then((value) => result = value),
    );

    await tester.tap(find.text('show'));
    await tester.pumpAndSettle();
    expect(find.text('Saved'), findsOneWidget);

    await tester.pump(AppDurations.messageVisible);
    await tester.pumpAndSettle();

    expect(find.text('Saved'), findsNothing);
    expect(result, AppSnackbarResult.autoDismissed);
  });

  testWidgets('should replace the current message instead of queueing', (
    tester,
  ) async {
    await pumpOverlays(
      tester,
      Builder(
        builder: (context) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton(
                onPressed: () =>
                    AppSnackbar.show(context, message: 'First message'),
                child: const Text('first'),
              ),
              FilledButton(
                onPressed: () =>
                    AppSnackbar.show(context, message: 'Second message'),
                child: const Text('second'),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('first'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('second'));
    await tester.pumpAndSettle();

    expect(find.text('First message'), findsNothing);
    expect(find.text('Second message'), findsOneWidget);

    await letItDismiss(tester);
  });

  testWidgets('should report the action press', (tester) async {
    AppSnackbarResult? result;
    await pumpSnackbarButton(
      tester,
      onShow: (snackbar) => snackbar.then((value) => result = value),
      action: (label: 'Undo', onPressed: () {}),
    );

    await tester.tap(find.text('show'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(result, AppSnackbarResult.actionInvoked);
    expect(find.text('Saved'), findsNothing);
  });

  testWidgets('should appear immediately when animations are disabled', (
    tester,
  ) async {
    await pumpSnackbarButton(tester, onShow: (_) {}, disableAnimations: true);

    await tester.tap(find.text('show'));
    await tester.pump();

    expect(find.text('Saved'), findsOneWidget);

    await letItDismiss(tester);
  });
}
