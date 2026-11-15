import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/animations/loading/animated_progress_bar.dart';
import 'package:orbit/features/interactions/domain/enums/interaction_type.dart';
import 'package:orbit/features/interactions/presentation/view_models/interaction_tile_data.dart';
import 'package:orbit/features/interactions/presentation/widgets/interaction_tile.dart';
import 'package:orbit/features/interactions/presentation/widgets/interaction_tile_skeleton.dart';
import 'package:orbit/features/interactions/presentation/widgets/interactions_feed_content.dart';

import '../../test_helpers.dart';

/// Mock callbacks for testing
class _MockCallbacks extends Mock {
  void onEdit(InteractionTileData tile);
  void onDelete(InteractionTileData tile);
  void onOpenOpportunity(int opportunityId);
}

/// The feed content builds slivers, so it must live inside a scroll view.
Widget _host(Widget sliver) => CustomScrollView(slivers: [sliver]);

void main() {
  group('InteractionsFeedContent static rendering', () {
    late _MockCallbacks callbacks;
    final fixedToday = DateTime(2025, 6, 15);

    setUp(() {
      callbacks = _MockCallbacks();
      registerFallbackValue(
        InteractionTileData(
          id: 1,
          type: InteractionType.call,
          subject: 'Test',
          description: 'Desc',
          date: fixedToday,
        ),
      );
    });

    InteractionTileData tile(int id, String subject, {DateTime? date}) =>
        InteractionTileData(
          id: id,
          type: InteractionType.call,
          subject: subject,
          description: 'Desc',
          date: date ?? fixedToday,
        );

    testWidgets(
      'should show the skeleton twin groups when isSkeleton is true',
      (WidgetTester tester) async {
        await pumpWidget(
          tester,
          _host(
            InteractionsFeedContent(
              interactions: const [],
              isRefreshing: false,
              isSkeleton: true,
              onEdit: callbacks.onEdit,
              onDelete: callbacks.onDelete,
              onOpenOpportunity: callbacks.onOpenOpportunity,
            ),
          ),
        );

        // Two date groups: header skeleton + a tile list each (2 and 3 rows).
        expect(find.byType(InteractionGroupHeaderSkeleton), findsNWidgets(2));
        final lists = find.byType(InteractionTileSkeletonList);
        expect(lists, findsNWidgets(2));
        expect(
          tester.widget<InteractionTileSkeletonList>(lists.first).count,
          equals(2),
        );
        expect(
          tester.widget<InteractionTileSkeletonList>(lists.last).count,
          equals(3),
        );
        expect(find.byType(InteractionTile), findsNothing);
      },
    );

    testWidgets(
      'should show one pinned header and tile per date group when interactions exist',
      (WidgetTester tester) async {
        final interactions = [
          tile(1, 'Today Call', date: fixedToday),
          tile(
            2,
            'Yesterday Email',
            date: fixedToday.subtract(const Duration(days: 1)),
          ),
          tile(
            3,
            'Older Meeting',
            date: fixedToday.subtract(const Duration(days: 5)),
          ),
        ];

        await pumpWidget(
          tester,
          _host(
            InteractionsFeedContent(
              interactions: interactions,
              isRefreshing: false,
              onEdit: callbacks.onEdit,
              onDelete: callbacks.onDelete,
              onOpenOpportunity: callbacks.onOpenOpportunity,
            ),
          ),
        );

        expect(find.byType(InteractionTile), findsNWidgets(3));
        expect(find.text('Today Call'), findsOneWidget);
        expect(find.text('Yesterday Email'), findsOneWidget);
        expect(find.text('Older Meeting'), findsOneWidget);
        // One pinned header per group.
        expect(find.byType(SliverPersistentHeader), findsNWidgets(3));
      },
    );

    testWidgets('should show a progress bar and keep tiles when refreshing', (
      WidgetTester tester,
    ) async {
      await pumpWidget(
        tester,
        _host(
          InteractionsFeedContent(
            interactions: [tile(1, 'Today Call')],
            isRefreshing: true,
            onEdit: callbacks.onEdit,
            onDelete: callbacks.onDelete,
            onOpenOpportunity: callbacks.onOpenOpportunity,
          ),
        ),
      );

      expect(find.byType(AnimatedProgressBar), findsOneWidget);
      expect(find.byType(InteractionTile), findsOneWidget);
      expect(find.text('Today Call'), findsOneWidget);
    });

    testWidgets('should render nothing when the list is empty (not skeleton)', (
      WidgetTester tester,
    ) async {
      await pumpWidget(
        tester,
        _host(
          InteractionsFeedContent(
            interactions: const [],
            isRefreshing: false,
            onEdit: callbacks.onEdit,
            onDelete: callbacks.onDelete,
            onOpenOpportunity: callbacks.onOpenOpportunity,
          ),
        ),
      );

      expect(find.byType(InteractionTile), findsNothing);
      expect(find.byType(InteractionTileSkeleton), findsNothing);
    });
  });
}
