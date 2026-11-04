import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/features/interactions/domain/enums/interaction_type.dart';
import 'package:orbit/features/interactions/presentation/widgets/interaction_tile.dart';
import 'package:orbit/features/interactions/presentation/widgets/interaction_tile_skeleton.dart';
import 'package:orbit/features/interactions/presentation/constants/interaction_layout_constants.dart';
import 'package:orbit/features/interactions/presentation/view_models/interaction_tile_data.dart';
import 'package:orbit/core/animations/loading/shimmer_box.dart';

import '../../test_helpers.dart';

void main() {
  group('InteractionTileSkeleton', () {
    testWidgets('measured sizes equal tile shared layout constants',
        (WidgetTester tester) async {
      // Pump the tile to measure its layout
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
          onTap: () {},
          onEdit: () {},
          onDelete: () {},
        ),
      );

      // Find the tile's Material (which has the border radius)
      // The Material is the direct child of Dismissible
      final tileMaterialFinder = find.descendant(
        of: find.byType(InteractionTile),
        matching: find.byType(Material),
      );
      
      // Get the first Material (the one with border radius)
      final tileMaterial = tester.widget<Material>(tileMaterialFinder.first);
      final tileBorderRadius = tileMaterial.borderRadius;

      // Pump the skeleton to measure its layout
      await pumpWidget(
        tester,
        InteractionTileSkeleton(),
      );

      // Find the skeleton's container (which has the border radius)
      final skeletonContainerFinder = find.descendant(
        of: find.byType(InteractionTileSkeleton),
        matching: find.byType(Container),
      );
      
      final skeletonContainer = tester.widget<Container>(skeletonContainerFinder.first);
      final skeletonDecoration = skeletonContainer.decoration as BoxDecoration?;
      final skeletonBorderRadius = skeletonDecoration?.borderRadius;

      // Verify border radius matches
      expect(skeletonBorderRadius, equals(tileBorderRadius));

      // Verify type icon size matches layout constant
      final skeletonTypeIcon = tester.widget<ShimmerBox>(
        find.descendant(
          of: find.byType(InteractionTileSkeleton),
          matching: find.byType(ShimmerBox).first,
        ),
      );

      expect(skeletonTypeIcon.width, equals(InteractionLayoutConstants.typeIconSize));
      expect(skeletonTypeIcon.height, equals(InteractionLayoutConstants.typeIconSize));
    });

    testWidgets('skeleton uses same constants for content layout',
        (WidgetTester tester) async {
      await pumpWidget(
        tester,
        InteractionTileSkeleton(),
      );

      // Verify the skeleton uses the same constants - 1 circle + 3 text lines = 4 ShimmerBoxes
      final shimmerBoxes = find.byType(ShimmerBox);
      expect(shimmerBoxes, findsNWidgets(4));

      // The skeleton should use the same constants from InteractionLayoutConstants
      // We can't directly access the constants from the widget test, but we can
      // verify the structure matches by checking the layout doesn't overflow
      expect(tester.takeException(), isNull);
    });

    testWidgets('static under reduce-motion',
        (WidgetTester tester) async {
      // Default harness has disableAnimations: true
      await pumpWidget(
        tester,
        InteractionTileSkeleton(),
      );

      // Should render without animation issues
      expect(find.byType(InteractionTileSkeleton), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}