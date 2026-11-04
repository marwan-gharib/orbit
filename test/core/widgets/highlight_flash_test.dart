import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/animations/tokens/app_durations.dart';
import 'package:orbit/core/theme/app_theme.dart';
import 'package:orbit/core/widgets/highlight_flash.dart';

void main() {
  Future<void> pumpFlash(
    WidgetTester tester, {
    required Object? token,
    bool disableAnimations = false,
  }) async {
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Center(
              child: HighlightFlash(
                token: token,
                child: const SizedBox(width: 200, height: 80),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color flashColor(WidgetTester tester) {
    final box = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(HighlightFlash),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    return (box.decoration as BoxDecoration).color!;
  }

  group('HighlightFlash', () {
    testWidgets('should paint a highlight that decays to transparent', (
      tester,
    ) async {
      await pumpFlash(tester, token: 'note-1');
      expect(flashColor(tester).a, closeTo(1, 0.001));

      await tester.pump(AppDurations.extraSlow ~/ 2);
      expect(flashColor(tester).a, lessThan(1));

      await tester.pump(AppDurations.extraSlow);
      expect(flashColor(tester).a, closeTo(0, 0.001));
    });

    testWidgets('should replay when the token changes', (tester) async {
      await pumpFlash(tester, token: 'note-1');
      await tester.pump(AppDurations.extraSlow * 2);
      expect(flashColor(tester).a, closeTo(0, 0.001));

      await pumpFlash(tester, token: 'note-2');
      expect(flashColor(tester).a, closeTo(1, 0.001));
    });

    testWidgets('should not flash when animations are disabled', (
      tester,
    ) async {
      await pumpFlash(tester, token: 'note-1', disableAnimations: true);
      expect(flashColor(tester).a, closeTo(0, 0.001));
    });

    testWidgets('should not flash when the token is null', (tester) async {
      await pumpFlash(tester, token: null);
      expect(flashColor(tester).a, closeTo(0, 0.001));
    });
  });
}
