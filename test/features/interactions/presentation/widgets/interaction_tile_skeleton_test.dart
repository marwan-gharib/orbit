import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/animations/loading/shimmer_box.dart';
import 'package:orbit/core/theme/app_radius.dart';
import 'package:orbit/features/interactions/domain/enums/interaction_type.dart';
import 'package:orbit/features/interactions/presentation/constants/interaction_layout_constants.dart';
import 'package:orbit/features/interactions/presentation/view_models/interaction_tile_data.dart';
import 'package:orbit/features/interactions/presentation/widgets/interaction_tile.dart';
import 'package:orbit/features/interactions/presentation/widgets/interaction_tile_skeleton.dart';

import '../../test_helpers.dart';

void main() {
  group('InteractionTileSkeleton', () {
    testWidgets(
      'should mirror the tile surface: same radius, square icon twin, full-round chip',
      (WidgetTester tester) async {
        // Pump the tile to read its real surface shape.
        await pumpWidget(
          tester,
          InteractionTile(
            data: InteractionTileData(
              id: 1,
              type: InteractionType.call,
              subject: 'Subject',
              description: 'Description',
              date: DateTime(2025, 6, 1),
            ),
            onEdit: () {},
            onDelete: () {},
          ),
        );

        final tileMaterial = tester.widget<Material>(
          find
              .descendant(
                of: find.byType(InteractionTile),
                matching: find.byType(Material),
              )
              .first,
        );
        final tileRadius =
            (tileMaterial.shape as RoundedRectangleBorder).borderRadius;

        // Pump the skeleton twin.
        await pumpWidget(tester, const InteractionTileSkeleton());

        final skeletonDecoration =
            tester
                    .widget<DecoratedBox>(
                      find
                          .descendant(
                            of: find.byType(InteractionTileSkeleton),
                            matching: find.byType(DecoratedBox),
                          )
                          .first,
                    )
                    .decoration
                as BoxDecoration;

        // Shared corner radius between the tile and its loading twin.
        expect(skeletonDecoration.borderRadius, equals(tileRadius));
        expect(
          skeletonDecoration.borderRadius,
          equals(InteractionLayoutConstants.tileBorderRadius),
        );

        // The icon placeholder is a square twin of the tile's type icon row.
        final circle = tester.widget<ShimmerBox>(find.byType(ShimmerBox).first);
        expect(circle.width, circle.height);
        expect(circle.width, isPositive);

        // The chip placeholder keeps the full-round pill shape.
        final chipDecorations = tester.widgetList<Container>(
          find.descendant(
            of: find.byType(InteractionTileSkeleton),
            matching: find.byType(Container),
          ),
        );
        expect(
          chipDecorations.map((c) => c.decoration as BoxDecoration?),
          anyElement(
            predicate<BoxDecoration?>(
              (d) => d?.borderRadius == AppRadius.borderFull,
              'has a borderFull pill',
            ),
          ),
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'should build one placeholder set per tile: circle, subject, two lines, chip',
      (WidgetTester tester) async {
        await pumpWidget(tester, const InteractionTileSkeleton());

        // 1 icon circle + subject + 2 description lines + 1 chip = 5.
        expect(find.byType(ShimmerBox), findsNWidgets(5));
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'should render the requested twin count with the shared gap via InteractionTileSkeletonList',
      (WidgetTester tester) async {
        await pumpWidget(tester, const InteractionTileSkeletonList(count: 3));

        expect(find.byType(InteractionTileSkeleton), findsNWidgets(3));

        // Two gaps between the three rows, sized by the shared constant.
        final listColumn = tester.widget<Column>(
          find
              .ancestor(
                of: find.byType(InteractionTileSkeleton).first,
                matching: find.byType(Column),
              )
              .first,
        );
        final gaps = listColumn.children
            .whereType<SizedBox>()
            .where(
              (sizedBox) =>
                  sizedBox.height ==
                  InteractionLayoutConstants.tileVerticalPadding,
            )
            .toList();
        expect(gaps, hasLength(2));
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('static under reduce-motion', (WidgetTester tester) async {
      // Default harness has disableAnimations: true
      await pumpWidget(tester, const InteractionTileSkeleton());

      // Should render without animation issues
      expect(find.byType(InteractionTileSkeleton), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
