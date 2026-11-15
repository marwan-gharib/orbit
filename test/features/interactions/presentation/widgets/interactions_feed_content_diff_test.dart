import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/animations/loading/animated_progress_bar.dart';
import 'package:orbit/core/animations/staggered/staggered_list_item.dart';
import 'package:orbit/core/animations/tokens/app_durations.dart';
import 'package:orbit/features/interactions/domain/enums/interaction_type.dart';
import 'package:orbit/features/interactions/presentation/view_models/interaction_tile_data.dart';
import 'package:orbit/features/interactions/presentation/widgets/interaction_tile.dart';
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
  group('InteractionsFeedContent silent refresh and entrance', () {
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

    /// Fires the one-shot stagger timer so no timer is left pending.
    Future<void> pumpPastStagger(WidgetTester tester) =>
        tester.pump(AppDurations.extraSlow + const Duration(milliseconds: 1));

    InteractionTileData tile(int id, String subject, {DateTime? date}) =>
        InteractionTileData(
          id: id,
          type: InteractionType.call,
          subject: subject,
          description: 'Desc',
          date: date ?? fixedToday,
        );

    testWidgets('should add new tiles after a silent refresh (id-diff)', (
      WidgetTester tester,
    ) async {
      await pumpWidget(
        tester,
        _host(
          InteractionsFeedContent(
            interactions: [tile(1, 'First')],
            isRefreshing: false,
            onEdit: callbacks.onEdit,
            onDelete: callbacks.onDelete,
            onOpenOpportunity: callbacks.onOpenOpportunity,
          ),
        ),
      );
      await pumpPastStagger(tester);

      await pumpWidget(
        tester,
        _host(
          InteractionsFeedContent(
            interactions: [tile(2, 'New One'), tile(1, 'First')],
            isRefreshing: false,
            onEdit: callbacks.onEdit,
            onDelete: callbacks.onDelete,
            onOpenOpportunity: callbacks.onOpenOpportunity,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(InteractionTile), findsNWidgets(2));
      expect(find.text('New One'), findsOneWidget);
      expect(find.text('First'), findsOneWidget);
    });

    testWidgets(
      'should collapse out removed tiles after a silent refresh (id-diff)',
      (WidgetTester tester) async {
        await pumpWidget(
          tester,
          _host(
            InteractionsFeedContent(
              interactions: [tile(1, 'First'), tile(2, 'Second')],
              isRefreshing: false,
              onEdit: callbacks.onEdit,
              onDelete: callbacks.onDelete,
              onOpenOpportunity: callbacks.onOpenOpportunity,
            ),
          ),
        );
        await pumpPastStagger(tester);

        await pumpWidget(
          tester,
          _host(
            InteractionsFeedContent(
              interactions: [tile(1, 'First')],
              isRefreshing: false,
              onEdit: callbacks.onEdit,
              onDelete: callbacks.onDelete,
              onOpenOpportunity: callbacks.onOpenOpportunity,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // The surviving tile stays; the removed one collapses out.
        expect(find.text('First'), findsOneWidget);
        expect(find.text('Second'), findsNothing);
        expect(find.byType(InteractionTile), findsOneWidget);
      },
    );

    testWidgets(
      'should stagger first-load tiles once through StaggeredListItem',
      (WidgetTester tester) async {
        await pumpWidget(
          tester,
          _host(
            InteractionsFeedContent(
              interactions: [tile(1, 'First'), tile(2, 'Second')],
              isRefreshing: false,
              onEdit: callbacks.onEdit,
              onDelete: callbacks.onDelete,
              onOpenOpportunity: callbacks.onOpenOpportunity,
            ),
          ),
        );

        final staggered = find.byType(StaggeredListItem);
        expect(staggered, findsNWidgets(2));
        expect(tester.widget<StaggeredListItem>(staggered.first).index, 0);
        expect(tester.widget<StaggeredListItem>(staggered.last).index, 1);

        // After the stagger window the plain rows remain.
        await pumpPastStagger(tester);
        expect(find.byType(StaggeredListItem), findsNothing);
        expect(find.byType(InteractionTile), findsNWidgets(2));
      },
    );

    testWidgets('should not re-stagger on refresh (isRefreshing=true)', (
      WidgetTester tester,
    ) async {
      await pumpWidget(
        tester,
        _host(
          InteractionsFeedContent(
            interactions: [tile(1, 'First')],
            isRefreshing: false,
            onEdit: callbacks.onEdit,
            onDelete: callbacks.onDelete,
            onOpenOpportunity: callbacks.onOpenOpportunity,
          ),
        ),
      );
      await pumpPastStagger(tester);

      await pumpWidget(
        tester,
        _host(
          InteractionsFeedContent(
            interactions: [tile(1, 'First')],
            isRefreshing: true,
            onEdit: callbacks.onEdit,
            onDelete: callbacks.onDelete,
            onOpenOpportunity: callbacks.onOpenOpportunity,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Refresh keeps the settled rows; no stagger replays.
      expect(find.byType(StaggeredListItem), findsNothing);
      expect(find.byType(AnimatedProgressBar), findsOneWidget);
      expect(find.byType(InteractionTile), findsOneWidget);
    });

    testWidgets('should show the changed subject of an edited tile', (
      WidgetTester tester,
    ) async {
      await pumpWidget(
        tester,
        _host(
          InteractionsFeedContent(
            interactions: [tile(1, 'Original Subject')],
            isRefreshing: false,
            onEdit: callbacks.onEdit,
            onDelete: callbacks.onDelete,
            onOpenOpportunity: callbacks.onOpenOpportunity,
          ),
        ),
      );
      await pumpPastStagger(tester);

      await pumpWidget(
        tester,
        _host(
          InteractionsFeedContent(
            interactions: [tile(1, 'Changed Subject')],
            isRefreshing: false,
            onEdit: callbacks.onEdit,
            onDelete: callbacks.onDelete,
            onOpenOpportunity: callbacks.onOpenOpportunity,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Changed Subject'), findsOneWidget);
      expect(find.text('Original Subject'), findsNothing);
      expect(find.byType(InteractionTile), findsOneWidget);
    });
  });
}
