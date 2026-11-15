import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/animations/tokens/app_curves.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/features/interactions/presentation/constants/interaction_layout_constants.dart';
import 'package:orbit/features/interactions/presentation/widgets/interaction_swipe_background.dart';

import '../../../../core/widgets/harness.dart';

void main() {
  const accent = Color(0xFF123456);

  double expectedScale(double progress) {
    final t = AppCurves.standard.transform(progress.clamp(0.0, 1.0));
    return InteractionLayoutConstants.swipeIconMinScale +
        (InteractionLayoutConstants.swipeIconMaxScale -
                InteractionLayoutConstants.swipeIconMinScale) *
            t;
  }

  group('InteractionSwipeBackground', () {
    testWidgets(
      'should start on the idle surface color with the minimum icon scale',
      (WidgetTester tester) async {
        final progress = ValueNotifier<double>(0);

        await pumpWidget(
          tester,
          InteractionSwipeBackground(
            progress: progress,
            alignment: AlignmentDirectional.centerStart,
            icon: Icons.edit_outlined,
            color: accent,
            iconColor: accent,
          ),
        );

        final context = tester.element(find.byType(InteractionSwipeBackground));
        final colors = context.colors;

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(InteractionSwipeBackground),
            matching: find.byType(Container),
          ),
        );
        expect(
          (container.decoration as BoxDecoration).color,
          colors.surfaceVariant,
        );
        expect(
          (container.decoration as BoxDecoration).borderRadius,
          InteractionLayoutConstants.tileBorderRadius,
        );

        final scale = tester.widget<Transform>(
          find.descendant(
            of: find.byType(InteractionSwipeBackground),
            matching: find.byType(Transform),
          ),
        );
        expect(scale.transform.storage[0], moreOrLessEquals(expectedScale(0)));
      },
    );

    testWidgets(
      'should reach the action color and the maximum scale at full drag',
      (WidgetTester tester) async {
        final progress = ValueNotifier<double>(1);

        await pumpWidget(
          tester,
          InteractionSwipeBackground(
            progress: progress,
            alignment: AlignmentDirectional.centerEnd,
            icon: Icons.delete_outline_rounded,
            color: accent,
            iconColor: accent,
          ),
        );

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(InteractionSwipeBackground),
            matching: find.byType(Container),
          ),
        );
        expect((container.decoration as BoxDecoration).color, accent);

        final scale = tester.widget<Transform>(
          find.descendant(
            of: find.byType(InteractionSwipeBackground),
            matching: find.byType(Transform),
          ),
        );
        expect(scale.transform.storage[0], moreOrLessEquals(expectedScale(1)));
      },
    );

    testWidgets('should follow progress changes live', (
      WidgetTester tester,
    ) async {
      final progress = ValueNotifier<double>(0);

      await pumpWidget(
        tester,
        InteractionSwipeBackground(
          progress: progress,
          alignment: AlignmentDirectional.centerStart,
          icon: Icons.edit_outlined,
          color: accent,
          iconColor: accent,
        ),
      );

      progress.value = 0.5;
      await tester.pump();

      final scale = tester.widget<Transform>(
        find.descendant(
          of: find.byType(InteractionSwipeBackground),
          matching: find.byType(Transform),
        ),
      );
      expect(scale.transform.storage[0], moreOrLessEquals(expectedScale(0.5)));
    });
  });
}
