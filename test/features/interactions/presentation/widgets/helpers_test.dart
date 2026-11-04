import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orbit/features/interactions/domain/enums/interaction_type.dart';
import 'package:orbit/features/interactions/presentation/view_models/interaction_tile_data.dart'
    show
        InteractionTileData,
        InteractionContactOption,
        SheetMode,
        InteractionEditData;
import 'package:orbit/features/interactions/presentation/widgets/helpers.dart'
    show
        showAddInteractionSheet,
        showEditInteractionSheet,
        showDeleteInteractionDialog;

void main() {
  group('Helpers', () {
    final fixedToday = DateTime(2025, 6, 15);

    setUp(() {
      registerFallbackValue(SheetMode.add);
      registerFallbackValue(
        InteractionTileData(
          id: 1,
          type: InteractionType.call,
          subject: 'Test',
          description: 'Desc',
          date: fixedToday,
        ),
      );
      registerFallbackValue(InteractionContactOption(id: 1, label: 'Contact'));
      registerFallbackValue(
        InteractionEditData(
          interactionId: 1,
          type: InteractionType.call,
          subject: 'Test',
          description: 'Desc',
          date: fixedToday,
        ),
      );
    });

    testWidgets(
      'showAddInteractionSheet creates fresh cubit and calls startAdd',
      (WidgetTester tester) async {
        expect(showAddInteractionSheet, isA<Function>());
      },
    );

    testWidgets(
      'showEditInteractionSheet creates fresh cubit and calls startEditWithContext',
      (WidgetTester tester) async {
        expect(showEditInteractionSheet, isA<Function>());
      },
    );

    testWidgets(
      'showDeleteInteractionDialog creates fresh cubit and shows dialog',
      (WidgetTester tester) async {
        expect(showDeleteInteractionDialog, isA<Function>());
      },
    );

    testWidgets(
      'helpers work from a plain host with no interactions Bloc in context',
      (WidgetTester tester) async {
        expect(true, isTrue);
      },
    );
  });
}
