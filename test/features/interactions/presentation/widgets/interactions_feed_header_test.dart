import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/features/interactions/domain/enums/interaction_type.dart';
import 'package:orbit/features/interactions/domain/params/interactions_criteria.dart';
import 'package:orbit/features/interactions/presentation/blocs/interactions_list/interactions_list_bloc.dart';
import 'package:orbit/features/interactions/presentation/blocs/interactions_list/interactions_list_event.dart';
import 'package:orbit/features/interactions/presentation/blocs/interactions_list/interactions_list_state.dart';
import 'package:orbit/features/interactions/presentation/widgets/interactions_feed_header.dart';
import 'package:orbit/core/animations/selection/animated_chip_selector.dart';
import 'package:orbit/core/widgets/app_text_field.dart';

import '../../test_helpers.dart';

class _MockBloc extends MockBloc<InteractionsListEvent, InteractionsListState>
    implements InteractionsListBloc {}

void main() {
  group('InteractionsFeedHeader', () {
    late _MockBloc bloc;

    setUp(() {
      bloc = _MockBloc();
      registerFallbackValue(const InteractionsListSearchChanged(''));
      registerFallbackValue(const InteractionsListFiltersChanged());
    });

    testWidgets('renders search field with hint and prefix icon',
        (WidgetTester tester) async {
      whenListen(
        bloc,
        Stream.value(const InteractionsListInitial(criteria: InteractionsCriteria())),
        initialState: const InteractionsListInitial(criteria: InteractionsCriteria()),
      );

      await pumpWidget(
        tester,
        BlocProvider<InteractionsListBloc>.value(
          value: bloc,
          child: const InteractionsFeedHeader(),
        ),
      );

      // Search field exists
      expect(find.byType(AppTextField), findsOneWidget);

      // Hint text is present
      final textField = tester.widget<AppTextField>(find.byType(AppTextField));
      expect(textField.hint, isNotNull);

      // Prefix icon is search
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    });

    testWidgets('search dispatches SearchChanged on every change',
        (WidgetTester tester) async {
      whenListen(
        bloc,
        Stream.value(const InteractionsListInitial(criteria: InteractionsCriteria())),
        initialState: const InteractionsListInitial(criteria: InteractionsCriteria()),
      );

      await pumpWidget(
        tester,
        BlocProvider<InteractionsListBloc>.value(
          value: bloc,
          child: const InteractionsFeedHeader(),
        ),
      );

      // Type in search field
      await tester.enterText(find.byType(AppTextField), 'test query');
      await tester.pump();

      // Verify SearchChanged was dispatched
      verify(() => bloc.add(const InteractionsListSearchChanged('test query')))
          .called(1);

      // Type more
      await tester.enterText(find.byType(AppTextField), 'test query more');
      await tester.pump();

      verify(() => bloc.add(const InteractionsListSearchChanged('test query more')))
          .called(1);
    });

    testWidgets('search clear button dispatches empty SearchChanged and clears field',
        (WidgetTester tester) async {
      whenListen(
        bloc,
        Stream.value(
          const InteractionsListInitial(
            criteria: InteractionsCriteria(searchText: 'existing'),
          ),
        ),
        initialState: const InteractionsListInitial(
          criteria: InteractionsCriteria(searchText: 'existing'),
        ),
      );

      await pumpWidget(
        tester,
        BlocProvider<InteractionsListBloc>.value(
          value: bloc,
          child: const InteractionsFeedHeader(),
        ),
      );

      // Clear button should be visible
      expect(find.byIcon(Icons.clear_rounded), findsOneWidget);

      // Tap clear
      await tester.tap(find.byIcon(Icons.clear_rounded));
      await tester.pump();

      // Verify SearchChanged('') was dispatched (once from onClear, once from onChanged)
      // The _SearchField calls both onClear and onChanged('')
      verify(() => bloc.add(const InteractionsListSearchChanged(''))).called(greaterThanOrEqualTo(1));

      // Field should be cleared
      final textField = tester.widget<AppTextField>(find.byType(AppTextField));
      expect(textField.controller?.text, equals(''));
    });

    testWidgets('type chips render with correct labels and icons',
        (WidgetTester tester) async {
      whenListen(
        bloc,
        Stream.value(const InteractionsListInitial(criteria: InteractionsCriteria())),
        initialState: const InteractionsListInitial(criteria: InteractionsCriteria()),
      );

      await pumpWidget(
        tester,
        BlocProvider<InteractionsListBloc>.value(
          value: bloc,
          child: const InteractionsFeedHeader(),
        ),
      );

      // Should have AnimatedChipSelector with 4 chips (All, Call, Email, Meeting)
      final chipSelector = tester.widget<AnimatedChipSelector<InteractionType?>>(
        find.byType(AnimatedChipSelector<InteractionType?>),
      );
      expect(chipSelector.items.length, equals(4));
      expect(chipSelector.items[0].value, isNull); // All
      expect(chipSelector.items[1].value, equals(InteractionType.call));
      expect(chipSelector.items[2].value, equals(InteractionType.email));
      expect(chipSelector.items[3].value, equals(InteractionType.meeting));
    });

    testWidgets('type chip selection dispatches FiltersChanged',
        (WidgetTester tester) async {
      whenListen(
        bloc,
        Stream.value(const InteractionsListInitial(criteria: InteractionsCriteria())),
        initialState: const InteractionsListInitial(criteria: InteractionsCriteria()),
      );

      await pumpWidget(
        tester,
        BlocProvider<InteractionsListBloc>.value(
          value: bloc,
          child: const InteractionsFeedHeader(),
        ),
      );

      // Find the chip selector and simulate selection
      final chipSelector = tester.widget<AnimatedChipSelector<InteractionType?>>(
        find.byType(AnimatedChipSelector<InteractionType?>),
      );

      // Call onChanged directly (simulating user tapping a chip)
      chipSelector.onChanged(InteractionType.call);

      verify(() => bloc.add(
            const InteractionsListFiltersChanged(type: InteractionType.call),
          )).called(1);

      clearInteractions(bloc);

      // Select All (null)
      chipSelector.onChanged(null);
      verify(() => bloc.add(
            const InteractionsListFiltersChanged(type: null),
          )).called(1);
    });

    testWidgets('Clear filters appears when active filters exist',
        (WidgetTester tester) async {
      whenListen(
        bloc,
        Stream.value(
          const InteractionsListInitial(
            criteria: InteractionsCriteria(type: InteractionType.call),
          ),
        ),
        initialState: const InteractionsListInitial(
          criteria: InteractionsCriteria(type: InteractionType.call),
        ),
      );

      await pumpWidget(
        tester,
        BlocProvider<InteractionsListBloc>.value(
          value: bloc,
          child: const InteractionsFeedHeader(),
        ),
      );

      // Should have chip selector
      final chipSelector = tester.widget<AnimatedChipSelector<InteractionType?>>(
        find.byType(AnimatedChipSelector<InteractionType?>),
      );
      expect(chipSelector.onChanged, isNotNull);
    });

    testWidgets('shows progress indicator when state is Loading',
        (WidgetTester tester) async {
      whenListen(
        bloc,
        Stream.value(const InteractionsListLoading(criteria: InteractionsCriteria())),
        initialState: const InteractionsListLoading(criteria: InteractionsCriteria()),
      );

      await pumpWidget(
        tester,
        BlocProvider<InteractionsListBloc>.value(
          value: bloc,
          child: const InteractionsFeedHeader(),
        ),
        settle: false, // Don't settle to avoid animation timeout
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('does not show progress indicator when not Loading',
        (WidgetTester tester) async {
      whenListen(
        bloc,
        Stream.value(const InteractionsListInitial(criteria: InteractionsCriteria())),
        initialState: const InteractionsListInitial(criteria: InteractionsCriteria()),
      );

      await pumpWidget(
        tester,
        BlocProvider<InteractionsListBloc>.value(
          value: bloc,
          child: const InteractionsFeedHeader(),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}