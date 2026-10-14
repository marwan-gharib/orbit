import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/animations/loading/shimmer_box.dart';
import 'package:orbit/core/animations/tokens/app_animation_constants.dart';

import 'harness.dart';

void main() {
  BoxDecoration? decorationOf(WidgetTester tester) =>
      tester.widget<Container>(find.byType(Container)).decoration
          as BoxDecoration?;

  testWidgets(
    'should paint the theme placeholder color when no color is given',
    (tester) async {
      await pumpLoading(tester, const ShimmerBox(height: 20));

      final scheme = ThemeData().colorScheme;
      final expected = Color.alphaBlend(
        scheme.onSurface.withValues(
          alpha: AppAnimationConstants.placeholderBaseOpacity,
        ),
        scheme.surface,
      );
      expect(decorationOf(tester)?.color, expected);
    },
  );

  testWidgets('should paint a circle when the shape is circle', (tester) async {
    await pumpLoading(tester, const ShimmerBox.circle());

    expect(decorationOf(tester)?.shape, BoxShape.circle);
    final container = tester.widget<Container>(find.byType(Container));
    expect(
      container.constraints,
      BoxConstraints.tightFor(
        width: AppAnimationConstants.skeletonAvatarSize,
        height: AppAnimationConstants.skeletonAvatarSize,
      ),
    );
  });

  testWidgets('should use the skeleton radius when the shape is a rectangle', (
    tester,
  ) async {
    await pumpLoading(tester, const ShimmerBox(height: 20));

    expect(
      decorationOf(tester)?.borderRadius,
      BorderRadius.circular(AppAnimationConstants.skeletonBoxRadius),
    );
  });

  testWidgets('should pill the line when the shape is textLine', (
    tester,
  ) async {
    await pumpLoading(tester, const ShimmerBox.textLine(width: 100));

    expect(
      decorationOf(tester)?.borderRadius,
      BorderRadius.circular(AppAnimationConstants.skeletonTextLineHeight / 2),
    );
  });

  testWidgets('should honour a custom color when one is given', (tester) async {
    const custom = Color(0xFF123456);

    await pumpLoading(tester, const ShimmerBox(height: 20, color: custom));

    expect(decorationOf(tester)?.color, custom);
  });
}
