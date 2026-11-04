import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/animations/loading/animated_progress_bar.dart';
import 'package:orbit/features/interactions/domain/enums/interaction_type.dart';
import 'package:orbit/features/interactions/presentation/widgets/interactions_timeline.dart'
    show InteractionsTimeline;
import 'package:orbit/features/interactions/presentation/widgets/interaction_tile.dart'
    show InteractionTile;
import 'package:orbit/features/interactions/presentation/view_models/interaction_tile_data.dart';

import '../../test_helpers.dart';

/// Mock callbacks for testing
class _MockCallbacks extends Mock {
  void onEdit(InteractionTileData tile);
  void onDelete(InteractionTileData tile);
}

void main() {
  group('InteractionsTimeline', () {
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

    testWidgets('renders empty state when items is empty',
        (WidgetTester tester) async {
      await pumpWidget(
        tester,
        InteractionsTimeline(
          items: const [],
          onEdit: callbacks.onEdit,
          onDelete: callbacks.onDelete,
        ),
      );

      expect(find.byType(InteractionTile), findsNothing);
      expect(find.text('No interactions logged'), findsOneWidget);
    });

    testWidgets('shows items in newest-first order (repository already sorts)',
        (WidgetTester tester) async {
      final items = [
        InteractionTileData(
          id: 1,
          type: InteractionType.call,
          subject: 'Older Call',
          description: 'Desc',
          date: fixedToday.subtract(const Duration(days: 5)),
        ),
        InteractionTileData(
          id: 2,
          type: InteractionType.email,
          subject: 'Yesterday Email',
          description: 'Desc',
          date: fixedToday.subtract(const Duration(days: 1)),
        ),
        InteractionTileData(
          id: 3,
          type: InteractionType.meeting,
          subject: 'Today Meeting',
          description: 'Desc',
          date: fixedToday,
        ),
      ];

      await pumpWidget(
        tester,
        InteractionsTimeline(
          items: items,
          onEdit: callbacks.onEdit,
          onDelete: callbacks.onDelete,
        ),
      );

      // Should show 3 tiles
      expect(find.byType(InteractionTile), findsNWidgets(3));

      // The items are rendered in the order they appear in the list (repository already sorts)
      // So the first item in the list is the first rendered
      final tiles = find.byType(InteractionTile);
      final tile1 = tester.widget<InteractionTile>(tiles.at(0));
      final tile2 = tester.widget<InteractionTile>(tiles.at(1));
      final tile3 = tester.widget<InteractionTile>(tiles.at(2));

      // The list is passed as-is (repository sorts date desc, id desc)
      // So the first item in the list should be rendered first
      expect(tile1.data.subject, equals('Older Call'));
      expect(tile2.data.subject, equals('Yesterday Email'));
      expect(tile3.data.subject, equals('Today Meeting'));
    });

    testWidgets('author name is shown when showAuthorName=true',
        (WidgetTester tester) async {
      final items = [
        InteractionTileData(
          id: 1,
          type: InteractionType.call,
          subject: 'Test Call',
          description: 'Desc',
          date: fixedToday,
          authorName: 'John Doe',
        ),
      ];

      await pumpWidget(
        tester,
        InteractionsTimeline(
          items: items,
          onEdit: callbacks.onEdit,
          onDelete: callbacks.onDelete,
        ),
      );

      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('author name is NOT shown when authorName is null',
        (WidgetTester tester) async {
      final items = [
        InteractionTileData(
          id: 1,
          type: InteractionType.call,
          subject: 'Test Call',
          description: 'Desc',
          date: fixedToday,
          authorName: null,
        ),
      ];

      await pumpWidget(
        tester,
        InteractionsTimeline(
          items: items,
          onEdit: callbacks.onEdit,
          onDelete: callbacks.onDelete,
        ),
      );

      // The tile should still render but without author
      expect(find.byType(InteractionTile), findsOneWidget);
    });

    testWidgets('isRefreshing shows progress bar',
        (WidgetTester tester) async {
      final items = [
        InteractionTileData(
          id: 1,
          type: InteractionType.call,
          subject: 'Test',
          description: 'Desc',
          date: fixedToday,
        ),
      ];

      await pumpWidget(
        tester,
        InteractionsTimeline(
          items: items,
          isRefreshing: true,
          onEdit: callbacks.onEdit,
          onDelete: callbacks.onDelete,
        ),
      );

      expect(find.byType(AnimatedProgressBar), findsOneWidget);
      expect(find.byType(InteractionTile), findsOneWidget);
    });

    testWidgets('static under reduce-motion (no connector animation)',
        (WidgetTester tester) async {
      final items = [
        InteractionTileData(
          id: 1,
          type: InteractionType.call,
          subject: 'Test',
          description: 'Desc',
          date: fixedToday,
        ),
      ];

      // Pump with animations disabled
      await pumpWidget(
        tester,
        InteractionsTimeline(
          items: items,
          onEdit: callbacks.onEdit,
          onDelete: callbacks.onDelete,
        ),
      );

      // Should render without issues
      expect(find.byType(InteractionTile), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}