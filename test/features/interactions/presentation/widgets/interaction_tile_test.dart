import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/animations/overlays/app_popup_menu.dart';
import 'package:orbit/features/interactions/domain/enums/interaction_type.dart';
import 'package:orbit/features/interactions/presentation/widgets/interaction_tile.dart'
    show InteractionTile, InteractionTileAction;
import 'package:orbit/features/interactions/presentation/view_models/interaction_tile_data.dart';

import '../../test_helpers.dart';

/// Mock callbacks for testing
class _MockCallbacks extends Mock {
  void onTap();
  void onEdit();
  void onDelete();
  void onOpenOpportunity();
}

void main() {
  group('InteractionTile', () {
    late _MockCallbacks callbacks;
    final testDate = DateTime(2025, 6, 1);

    setUp(() {
      callbacks = _MockCallbacks();
      registerFallbackValue(InteractionTileData(
        id: 1,
        type: InteractionType.call,
        subject: 'Test Subject',
        description: 'Test Description',
        date: testDate,
      ));
    });

    testWidgets('whole-surface tap fires onTap; chip calls onOpenOpportunity',
        (WidgetTester tester) async {
      final tileData = InteractionTileData(
        id: 1,
        type: InteractionType.call,
        subject: 'Subject',
        description: 'Description',
        date: testDate,
        opportunityId: 42,
      );

      await pumpWidget(
        tester,
        InteractionTile(
          data: tileData,
          onTap: callbacks.onTap,
          onEdit: callbacks.onEdit,
          onDelete: callbacks.onDelete,
          onOpenOpportunity: callbacks.onOpenOpportunity,
        ),
      );

      // Tap the tile surface - tap on the Dismissible which wraps the whole tile
      final tileFinder = find.byType(InteractionTile);
      await tester.tap(tileFinder);
      verify(() => callbacks.onTap()).called(1);

      // Tap on the "Open opportunity" chip - should fire onOpenOpportunity
      final chipFinder = find.byType(ActionChip);
      expect(chipFinder, findsOneWidget);
      await tester.tap(chipFinder);
      verify(() => callbacks.onOpenOpportunity()).called(1);

      // Verify onEdit and onDelete were NOT called
      verifyNever(() => callbacks.onEdit());
      verifyNever(() => callbacks.onDelete());
    });

    testWidgets(
        '"Open opportunity" chip appears only when opportunityId is non-null and calls onOpenOpportunity exactly once',
        (WidgetTester tester) async {
      // With opportunityId - chip should appear
      final tileDataWithOpportunity = InteractionTileData(
        id: 1,
        type: InteractionType.call,
        subject: 'Subject',
        description: 'Description',
        date: testDate,
        opportunityId: 42,
      );

      await pumpWidget(
        tester,
        InteractionTile(
          data: tileDataWithOpportunity,
          onTap: () {},
          onEdit: callbacks.onEdit,
          onDelete: callbacks.onDelete,
          onOpenOpportunity: callbacks.onOpenOpportunity,
        ),
      );

      expect(find.byType(ActionChip), findsOneWidget);
      await tester.tap(find.byType(ActionChip));
      verify(() => callbacks.onOpenOpportunity()).called(1);

      // Reset
      clearInteractions(callbacks);

      // Without opportunityId - chip should NOT appear
      final tileDataWithoutOpportunity = InteractionTileData(
        id: 1,
        type: InteractionType.call,
        subject: 'Subject',
        description: 'Description',
        date: testDate,
        opportunityId: null,
      );

      await pumpWidget(
        tester,
        InteractionTile(
          data: tileDataWithoutOpportunity,
          onTap: () {},
          onEdit: callbacks.onEdit,
          onDelete: callbacks.onDelete,
          onOpenOpportunity: callbacks.onOpenOpportunity,
        ),
      );

      expect(find.byType(ActionChip), findsNothing);
      verifyNever(() => callbacks.onOpenOpportunity());
    });

    testWidgets('no author displayed in feed tile by default',
        (WidgetTester tester) async {
      final tileData = InteractionTileData(
        id: 1,
        type: InteractionType.call,
        subject: 'Subject',
        description: 'Description',
        date: testDate,
        authorName: 'John Doe', // authorName provided but showAuthorName defaults to false
      );

      await pumpWidget(
        tester,
        InteractionTile(
          data: tileData,
          onTap: () {},
          onEdit: callbacks.onEdit,
          onDelete: callbacks.onDelete,
        ),
      );

      // Author name should NOT appear
      expect(find.text('John Doe'), findsNothing);
    });

    testWidgets('subject and description clamp with ellipsis',
        (WidgetTester tester) async {
      final longSubject = 'A' * 100;
      final longDescription = 'B' * 200;

      final tileData = InteractionTileData(
        id: 1,
        type: InteractionType.call,
        subject: longSubject,
        description: longDescription,
        date: testDate,
      );

      await pumpWidget(
        tester,
        InteractionTile(
          data: tileData,
          onTap: () {},
          onEdit: callbacks.onEdit,
          onDelete: callbacks.onDelete,
        ),
      );

      // Both subject and description should be rendered with maxLines=2 and ellipsis
      final subjectFinder = find.textContaining(longSubject.substring(0, 50));
      final descFinder = find.textContaining(longDescription.substring(0, 50));

      expect(subjectFinder, findsOneWidget);
      expect(descFinder, findsOneWidget);

      // Verify overflow is handled (no overflow errors)
      expect(tester.takeException(), isNull);
    });

    testWidgets('overflow menu has Edit and Delete items with correct callbacks',
        (WidgetTester tester) async {
      final tileData = InteractionTileData(
        id: 1,
        type: InteractionType.call,
        subject: 'Subject',
        description: 'Description',
        date: testDate,
      );

      await pumpWidget(
        tester,
        InteractionTile(
          data: tileData,
          onTap: () {},
          onEdit: callbacks.onEdit,
          onDelete: callbacks.onDelete,
        ),
      );

      // Find the AppPopupMenu and verify its items
      final popupMenuFinder = find.byType(AppPopupMenu<InteractionTileAction>);
      expect(popupMenuFinder, findsOneWidget);

      final popupMenu = tester.widget<AppPopupMenu<InteractionTileAction>>(popupMenuFinder);
      expect(popupMenu.items.length, equals(2));
      
      // Items are PopupMenuEntry, need to cast to PopupMenuItem to access value
      final editItem = popupMenu.items[0] as PopupMenuItem<InteractionTileAction>;
      final deleteItem = popupMenu.items[1] as PopupMenuItem<InteractionTileAction>;
      expect(editItem.value, equals(InteractionTileAction.edit));
      expect(deleteItem.value, equals(InteractionTileAction.delete));

      // Test onSelected callback for edit
      popupMenu.onSelected(InteractionTileAction.edit);
      verify(() => callbacks.onEdit()).called(1);

      // Reset and test delete
      clearInteractions(callbacks);
      popupMenu.onSelected(InteractionTileAction.delete);
      verify(() => callbacks.onDelete()).called(1);
    });

    testWidgets('swipe end-to-start (delete) returns false, calls onDelete',
        (WidgetTester tester) async {
      final tileData = InteractionTileData(
        id: 1,
        type: InteractionType.call,
        subject: 'Subject',
        description: 'Description',
        date: testDate,
      );

      await pumpWidget(
        tester,
        InteractionTile(
          data: tileData,
          onTap: () {},
          onEdit: callbacks.onEdit,
          onDelete: callbacks.onDelete,
        ),
      );

      final tileFinder = find.byKey(const ValueKey('interaction-tile-1'));
      expect(tileFinder, findsOneWidget);

      // Get the dismissible widget
      final dismissibleFinder = find.byType(Dismissible);
      expect(dismissibleFinder, findsOneWidget);

      // Swipe end-to-start (delete direction) - drag far enough to exceed threshold
      await tester.drag(dismissibleFinder, const Offset(-400, 0));
      await tester.pumpAndSettle();

      // Tile should still be in tree (confirmDismiss returns false)
      expect(tileFinder, findsOneWidget);

      // onDelete should have been called
      verify(() => callbacks.onDelete()).called(1);
    });

    testWidgets('swipe start-to-end (edit) returns false, calls onEdit',
        (WidgetTester tester) async {
      final tileData = InteractionTileData(
        id: 1,
        type: InteractionType.call,
        subject: 'Subject',
        description: 'Description',
        date: testDate,
      );

      await pumpWidget(
        tester,
        InteractionTile(
          data: tileData,
          onTap: () {},
          onEdit: callbacks.onEdit,
          onDelete: callbacks.onDelete,
        ),
      );

      final tileFinder = find.byKey(const ValueKey('interaction-tile-1'));
      expect(tileFinder, findsOneWidget);

      // Get the dismissible widget
      final dismissibleFinder = find.byType(Dismissible);
      expect(dismissibleFinder, findsOneWidget);

      // Swipe start-to-end (edit direction) - drag far enough to exceed threshold
      await tester.drag(dismissibleFinder, const Offset(400, 0));
      await tester.pumpAndSettle();

      // Tile should still be in tree (confirmDismiss returns false)
      expect(tileFinder, findsOneWidget);

      // onEdit should have been called
      verify(() => callbacks.onEdit()).called(1);
    });
  });
}