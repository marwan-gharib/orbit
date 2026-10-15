import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/animations/loading/shimmer_box.dart';
import 'package:orbit/core/animations/loading/skeletons.dart';
import 'package:orbit/core/animations/tokens/app_animation_constants.dart';

import 'harness.dart';

void main() {
  List<PlaceholderShape> shapesOf(WidgetTester tester) => [
    for (final box in tester.widgetList<ShimmerBox>(find.byType(ShimmerBox)))
      box.shape,
  ];

  BoxDecoration? decorationOf(WidgetTester tester) =>
      tester.widget<Container>(find.byType(Container).first).decoration
          as BoxDecoration?;

  testWidgets(
    'should render one avatar and two lines when built as a list tile',
    (tester) async {
      await pumpLoading(tester, const SkeletonListTile());

      expect(shapesOf(tester), <PlaceholderShape>[
        PlaceholderShape.circle,
        PlaceholderShape.textLine,
        PlaceholderShape.textLine,
      ]);
    },
  );

  testWidgets(
    'should render one text line per requested line when built as a block',
    (tester) async {
      await pumpLoading(tester, const SkeletonTextBlock(lines: 4));

      expect(shapesOf(tester), <PlaceholderShape>[
        PlaceholderShape.textLine,
        PlaceholderShape.textLine,
        PlaceholderShape.textLine,
        PlaceholderShape.textLine,
      ]);
    },
  );

  testWidgets(
    'should render the default number of lines when built as a card',
    (tester) async {
      await pumpLoading(tester, const SkeletonCard());

      expect(
        find.descendant(
          of: find.byType(SkeletonCard),
          matching: find.byType(SkeletonTextBlock),
        ),
        findsOneWidget,
      );
      expect(
        shapesOf(tester),
        List.filled(
          AppAnimationConstants.skeletonTextBlockDefaultLines,
          PlaceholderShape.textLine,
        ),
      );
    },
  );

  testWidgets(
    'should paint the card surface at half placeholder emphasis when built',
    (tester) async {
      await pumpLoading(tester, const SkeletonCard());

      expect(
        decorationOf(tester)?.color!.a,
        closeTo(AppAnimationConstants.skeletonCardFillOpacity, 0.0001),
      );
    },
  );

  testWidgets(
    'should round the card surface with the skeleton radius when built',
    (tester) async {
      await pumpLoading(tester, const SkeletonCard());

      expect(
        decorationOf(tester)?.borderRadius,
        BorderRadius.circular(AppAnimationConstants.skeletonCardRadius),
      );
    },
  );

  testWidgets('should fail fast when asked for no lines', (tester) async {
    expect(
      () => pumpLoading(tester, SkeletonTextBlock(lines: 0)),
      throwsA(isA<AssertionError>()),
    );
  });
}
