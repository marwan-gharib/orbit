import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/widgets/app_button.dart';

import 'harness.dart';

void main() {
  group('AppButton', () {
    testWidgets('should render FilledButton when variant is filled', (
      tester,
    ) async {
      await pumpWidget(
        tester,
        const AppButton(label: 'Submit', variant: AppButtonVariant.filled),
      );
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('should render ElevatedButton when variant is elevated', (
      tester,
    ) async {
      await pumpWidget(
        tester,
        const AppButton(label: 'Submit', variant: AppButtonVariant.elevated),
      );
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should render OutlinedButton when variant is outlined', (
      tester,
    ) async {
      await pumpWidget(
        tester,
        const AppButton(label: 'Submit', variant: AppButtonVariant.outlined),
      );
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('should render TextButton when variant is text', (
      tester,
    ) async {
      await pumpWidget(
        tester,
        const AppButton(label: 'Submit', variant: AppButtonVariant.text),
      );
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('should call onPressed when tapped and enabled', (
      tester,
    ) async {
      var tapped = false;
      await pumpWidget(
        tester,
        AppButton(label: 'Submit', onPressed: () => tapped = true),
      );
      await tester.tap(find.byType(FilledButton));
      expect(tapped, isTrue);
    });

    testWidgets('should not call onPressed when disabled', (tester) async {
      var tapped = false;
      await pumpWidget(
        tester,
        AppButton(
          label: 'Submit',
          // onPressed is null -> disabled
        ),
      );
      await tester.tap(find.byType(FilledButton));
      expect(tapped, isFalse);
    });

    testWidgets('should show loading spinner when isLoading is true', (
      tester,
    ) async {
      await pumpWidget(
        tester,
        const AppButton(label: 'Submit', isLoading: true),
        settle: false,
      );
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Submit'), findsNothing);
    });

    testWidgets('should show icon when provided', (tester) async {
      await pumpWidget(
        tester,
        const AppButton(label: 'Submit', icon: Icon(Icons.add)),
      );
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should honor a minimumSize override on the label path', (
      tester,
    ) async {
      await pumpWidget(
        tester,
        const AppButton(
          label: 'Go',
          padding: EdgeInsets.zero,
          minimumSize: Size(120, 56),
        ),
      );

      expect(tester.getSize(find.byType(FilledButton)), const Size(120, 56));
    });
  });

  group('AppButton.icon', () {
    testWidgets('should render an IconButton with the semantic label '
        'attached', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpWidget(
        tester,
        AppButton.icon(
          icon: const Icon(Icons.chevron_left),
          semanticLabel: 'Go back',
          onPressed: () {},
        ),
      );

      expect(find.byType(IconButton), findsOneWidget);
      final node = tester
          .getSemantics(find.bySemanticsLabel('Go back'))
          .getSemanticsData();
      expect(node.label, 'Go back');
      expect(node.flagsCollection.isButton, isTrue);
      expect(node.flagsCollection.isEnabled, isNot(Tristate.isFalse));
      handle.dispose();
    });

    testWidgets('should expose the default 48 dp minimum tap target', (
      tester,
    ) async {
      await pumpWidget(
        tester,
        AppButton.icon(
          icon: const Icon(Icons.chevron_left),
          semanticLabel: 'Go back',
          onPressed: () {},
        ),
      );
      await tester.pumpAndSettle();

      final size = tester.getSize(find.byType(IconButton));
      expect(size.height, greaterThanOrEqualTo(48.0));
      expect(size.width, greaterThanOrEqualTo(48.0));
    });

    testWidgets('should disable the tap when onPressed is null', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpWidget(
        tester,
        AppButton.icon(
          icon: const Icon(Icons.chevron_left),
          semanticLabel: 'Go back',
        ),
      );
      await tester.tap(find.byType(IconButton));
      final node = tester
          .getSemantics(find.bySemanticsLabel('Go back'))
          .getSemanticsData();
      expect(node.flagsCollection.isEnabled, Tristate.isFalse);
      handle.dispose();
    });

    testWidgets('should mirror the glyph in RTL when mirrorInRtl is set', (
      tester,
    ) async {
      await pumpWidget(
        tester,
        const Directionality(
          textDirection: TextDirection.rtl,
          child: AppButton.icon(
            icon: Icon(Icons.chevron_left),
            semanticLabel: 'Go back',
            mirrorInRtl: true,
          ),
        ),
      );

      final flip = tester
          .widgetList<Transform>(
            find.descendant(
              of: find.byType(AppButton),
              matching: find.byType(Transform),
            ),
          )
          .first;
      expect(
        flip.transform.storage[0],
        -1.0,
        reason: 'the flip matrix negates x',
      );
    });

    testWidgets('should keep natural orientation in LTR', (tester) async {
      await pumpWidget(
        tester,
        const AppButton.icon(
          icon: Icon(Icons.chevron_left),
          semanticLabel: 'Go back',
        ),
      );

      expect(
        find.descendant(
          of: find.byType(AppButton),
          matching: find.byType(Transform),
        ),
        findsNothing,
      );
    });
  });

  group('AppButton.content', () {
    testWidgets('should render caller content on a variant surface with the '
        'requested overrides', (tester) async {
      await pumpWidget(
        tester,
        AppButton.content(
          content: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [Text('crossfade')],
          ),
          cornerRadius: BorderRadius.circular(12),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
      );

      expect(find.text('crossfade'), findsOneWidget);
      final filled = tester.widget<FilledButton>(find.byType(FilledButton));
      final shape = filled.style?.shape?.resolve(<WidgetState>{});
      expect(
        (shape as RoundedRectangleBorder).borderRadius,
        BorderRadius.circular(12),
      );
      final padding =
          filled.style?.padding?.resolve(<WidgetState>{}) as EdgeInsets?;
      expect(padding!.left, 24);
      expect(padding.right, 24);
    });

    testWidgets('should keep the standard label row reachable from the base '
        'constructor', (tester) async {
      await pumpWidget(tester, const AppButton(label: 'Label row'));
      expect(find.text('Label row'), findsOneWidget);
    });

    testWidgets('should pin caller content to minimumSize', (tester) async {
      await pumpWidget(
        tester,
        const AppButton.content(
          content: SizedBox.square(dimension: 10),
          variant: AppButtonVariant.text,
          padding: EdgeInsets.zero,
          minimumSize: Size.square(48),
        ),
      );

      expect(tester.getSize(find.byType(TextButton)), const Size.square(48));
    });
  });
}
