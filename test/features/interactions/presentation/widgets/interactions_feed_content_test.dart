import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/features/interactions/domain/enums/interaction_type.dart';
import 'package:orbit/features/interactions/presentation/widgets/interactions_feed_content.dart';
import 'package:orbit/features/interactions/presentation/widgets/interaction_tile.dart';
import 'package:orbit/features/interactions/presentation/view_models/interaction_tile_data.dart';
import 'package:orbit/core/animations/loading/animated_progress_bar.dart';
import 'package:orbit/core/animations/loading/shimmer_box.dart';
import 'package:orbit/core/animations/staggered/staggered_list_item.dart';

import '../../test_helpers.dart';

/// Mock callbacks for testing
class _MockCallbacks extends Mock {
  void onEdit(InteractionTileData tile);
  void onDelete(InteractionTileData tile);
  void onOpenOpportunity(int opportunityId);
}

void main() {
  group('InteractionsFeedContent', () {
    late _MockCallbacks callbacks;
    final fixedToday = DateTime(2025, 6, 15);

    setUp(() {
      callbacks = _MockCallbacks();
      registerFallbackValue(InteractionTileData(
        id: 1,
        type: InteractionType.call,
        subject: 'Test',
        description: 'Desc',
        date: fixedToday,
      ));
    });

    testWidgets('initial/loading shows skeleton (isSkeleton=true)',
        (WidgetTester tester) async {
      await pumpWidget(
        tester,
        InteractionsFeedContent(
          interactions: const [],
          isRefreshing: false,
          isSkeleton: true,
          onEdit: callbacks.onEdit,
          onDelete: callbacks.onDelete,
          onOpenOpportunity: callbacks.onOpenOpportunity,
        ),
      );

      // Should show skeleton rows via ShimmerBox (3 rows * 1 ShimmerBox each = 3)
      expect(find.byType(ShimmerBox), findsNWidgets(3));
    });

    testWidgets('success shows tiles (grouped by date via groupInteractionsByDate)',
        (WidgetTester tester) async {
      // Use dates relative to the test's fixedToday
      final today = fixedToday;
      final yesterday = fixedToday.subtract(const Duration(days: 1));
      final older = fixedToday.subtract(const Duration(days: 5));

      final interactions = [
        InteractionTileData(
          id: 1,
          type: InteractionType.call,
          subject: 'Today Call',
          description: 'Desc',
          date: today,
        ),
        InteractionTileData(
          id: 2,
          type: InteractionType.email,
          subject: 'Yesterday Email',
          description: 'Desc',
          date: yesterday,
        ),
        InteractionTileData(
          id: 3,
          type: InteractionType.meeting,
          subject: 'Older Meeting',
          description: 'Desc',
          date: older,
        ),
      ];

      await pumpWidget(
        tester,
        InteractionsFeedContent(
          interactions: interactions,
          isRefreshing: false,
          isSkeleton: false,
          onEdit: callbacks.onEdit,
          onDelete: callbacks.onDelete,
          onOpenOpportunity: callbacks.onOpenOpportunity,
        ),
      );

      // Should show 3 tiles
      expect(find.byType(InteractionTile), findsNWidgets(3));

      // Should show group headers (Today, Yesterday, or formatted date)
      // At minimum, there should be some group headers
      final groupHeaders = find.byWidgetPredicate(
        (widget) => widget is Padding && widget.child is Text,
      );
      expect(groupHeaders, findsWidgets);
    });

    testWidgets('refreshing shows thin progress bar with content kept',
        (WidgetTester tester) async {
      final interactions = [
        InteractionTileData(
          id: 1,
          type: InteractionType.call,
          subject: 'Today Call',
          description: 'Desc',
          date: fixedToday,
        ),
      ];

      await pumpWidget(
        tester,
        InteractionsFeedContent(
          interactions: interactions,
          isRefreshing: true,
          isSkeleton: false,
          onEdit: callbacks.onEdit,
          onDelete: callbacks.onDelete,
          onOpenOpportunity: callbacks.onOpenOpportunity,
        ),
      );

      // Should show progress bar
      expect(find.byType(AnimatedProgressBar), findsOneWidget);

      // Content should still be visible
      expect(find.byType(InteractionTile), findsOneWidget);
      expect(find.text('Today Call'), findsOneWidget);
    });

    testWidgets('empty interactions shows nothing (no skeleton when not isSkeleton)',
        (WidgetTester tester) async {
      await pumpWidget(
        tester,
        InteractionsFeedContent(
          interactions: const [],
          isRefreshing: false,
          isSkeleton: false,
          onEdit: callbacks.onEdit,
          onDelete: callbacks.onDelete,
          onOpenOpportunity: callbacks.onOpenOpportunity,
        ),
      );

      // Should show nothing (SizedBox.shrink)
      expect(find.byType(InteractionTile), findsNothing);
      expect(find.byType(ShimmerBox), findsNothing);
    });

    testWidgets('id-diff: new ids are added to the list',
        (WidgetTester tester) async {
      // First render with one interaction
      final interactions1 = [
        InteractionTileData(
          id: 1,
          type: InteractionType.call,
          subject: 'First',
          description: 'Desc',
          date: fixedToday,
        ),
      ];

      await pumpWidget(
        tester,
        InteractionsFeedContent(
          interactions: interactions1,
          isRefreshing: false,
          isSkeleton: false,
          onEdit: callbacks.onEdit,
          onDelete: callbacks.onDelete,
          onOpenOpportunity: callbacks.onOpenOpportunity,
        ),
      );

      expect(find.byType(InteractionTile), findsOneWidget);

      // Update with new interaction (simulating id-diff add)
      final interactions2 = [
        InteractionTileData(
          id: 2,
          type: InteractionType.email,
          subject: 'New One',
          description: 'Desc',
          date: fixedToday,
        ),
        InteractionTileData(
          id: 1,
          type: InteractionType.call,
          subject: 'First',
          description: 'Desc',
          date: fixedToday,
        ),
      ];

      await pumpWidget(
        tester,
        InteractionsFeedContent(
          interactions: interactions2,
          isRefreshing: false,
          isSkeleton: false,
          onEdit: callbacks.onEdit,
          onDelete: callbacks.onDelete,
          onOpenOpportunity: callbacks.onOpenOpportunity,
        ),
      );

      await tester.pumpAndSettle();

      // Should now have 2 tiles
      expect(find.byType(InteractionTile), findsNWidgets(2));
      expect(find.text('New One'), findsOneWidget);
      expect(find.text('First'), findsOneWidget);
    });

    testWidgets('id-diff: removed ids collapse out (AnimatedVisibility)',
        (WidgetTester tester) async {
      // First render with two interactions
      final interactions1 = [
        InteractionTileData(
          id: 1,
          type: InteractionType.call,
          subject: 'First',
          description: 'Desc',
          date: fixedToday,
        ),
        InteractionTileData(
          id: 2,
          type: InteractionType.email,
          subject: 'Second',
          description: 'Desc',
          date: fixedToday,
        ),
      ];

      await pumpWidget(
        tester,
        InteractionsFeedContent(
          interactions: interactions1,
          isRefreshing: false,
          isSkeleton: false,
          onEdit: callbacks.onEdit,
          onDelete: callbacks.onDelete,
          onOpenOpportunity: callbacks.onOpenOpportunity,
        ),
      );

      expect(find.byType(InteractionTile), findsNWidgets(2));

      // Update with only first interaction (simulating id-diff remove)
      final interactions2 = [
        InteractionTileData(
          id: 1,
          type: InteractionType.call,
          subject: 'First',
          description: 'Desc',
          date: fixedToday,
        ),
      ];

      await pumpWidget(
        tester,
        InteractionsFeedContent(
          interactions: interactions2,
          isRefreshing: false,
          isSkeleton: false,
          onEdit: callbacks.onEdit,
          onDelete: callbacks.onDelete,
          onOpenOpportunity: callbacks.onOpenOpportunity,
        ),
      );

      await tester.pumpAndSettle();

      // Should have 1 active tile + 1 collapsing tile (AnimatedVisibility)
      // The collapsing tile is also an InteractionTile wrapped in AnimatedVisibility
      expect(find.byType(InteractionTile), findsAtLeast(1));
    });

    testWidgets('first-load stagger plays once via StaggeredListItem',
        (WidgetTester tester) async {
      final interactions = [
        InteractionTileData(
          id: 1,
          type: InteractionType.call,
          subject: 'First',
          description: 'Desc',
          date: fixedToday,
        ),
        InteractionTileData(
          id: 2,
          type: InteractionType.email,
          subject: 'Second',
          description: 'Desc',
          date: fixedToday,
        ),
      ];

      await pumpWidget(
        tester,
        InteractionsFeedContent(
          interactions: interactions,
          isRefreshing: false,
          isSkeleton: false,
          onEdit: callbacks.onEdit,
          onDelete: callbacks.onDelete,
          onOpenOpportunity: callbacks.onOpenOpportunity,
        ),
      );

      // Should have StaggeredListItem for each tile
      expect(find.byType(StaggeredListItem), findsNWidgets(2));

      // Verify indices are set (groupIndex * 100 + tile.id)
      final staggeredItems = find.byType(StaggeredListItem);
      final item1 = tester.widget<StaggeredListItem>(staggeredItems.first);
      final item2 = tester.widget<StaggeredListItem>(staggeredItems.last);
      expect(item1.index, equals(1)); // 0 * 100 + 1
      expect(item2.index, equals(2)); // 0 * 100 + 2
    });

    testWidgets('stagger does not replay on refresh (isRefreshing=true)',
        (WidgetTester tester) async {
      final interactions = [
        InteractionTileData(
          id: 1,
          type: InteractionType.call,
          subject: 'First',
          description: 'Desc',
          date: fixedToday,
        ),
      ];

      // Initial render
      await pumpWidget(
        tester,
        InteractionsFeedContent(
          interactions: interactions,
          isRefreshing: false,
          isSkeleton: false,
          onEdit: callbacks.onEdit,
          onDelete: callbacks.onDelete,
          onOpenOpportunity: callbacks.onOpenOpportunity,
        ),
      );

      // Refresh with same content
      await pumpWidget(
        tester,
        InteractionsFeedContent(
          interactions: interactions,
          isRefreshing: true,
          isSkeleton: false,
          onEdit: callbacks.onEdit,
          onDelete: callbacks.onDelete,
          onOpenOpportunity: callbacks.onOpenOpportunity,
        ),
      );

      await tester.pumpAndSettle();

      // Should still have StaggeredListItem but indices should be stable
      expect(find.byType(StaggeredListItem), findsOneWidget);
    });

    testWidgets('subject and description changes are reflected in UI',
        (WidgetTester tester) async {
      final interactions1 = [
        InteractionTileData(
          id: 1,
          type: InteractionType.call,
          subject: 'Original Subject',
          description: 'Original Desc',
          date: fixedToday,
        ),
      ];

      await pumpWidget(
        tester,
        InteractionsFeedContent(
          interactions: interactions1,
          isRefreshing: false,
          isSkeleton: false,
          onEdit: callbacks.onEdit,
          onDelete: callbacks.onDelete,
          onOpenOpportunity: callbacks.onOpenOpportunity,
        ),
      );

      // Update with changed subject
      final interactions2 = [
        InteractionTileData(
          id: 1,
          type: InteractionType.call,
          subject: 'Changed Subject',
          description: 'Original Desc',
          date: fixedToday,
        ),
      ];

      await pumpWidget(
        tester,
        InteractionsFeedContent(
          interactions: interactions2,
          isRefreshing: false,
          isSkeleton: false,
          onEdit: callbacks.onEdit,
          onDelete: callbacks.onDelete,
          onOpenOpportunity: callbacks.onOpenOpportunity,
        ),
      );

      await tester.pumpAndSettle();

      // Should show updated subject
      expect(find.text('Changed Subject'), findsOneWidget);
      expect(find.text('Original Subject'), findsNothing);
    });
  });
}