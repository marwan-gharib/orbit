import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/features/interactions/domain/enums/interaction_type.dart';
import 'package:orbit/features/interactions/domain/params/interactions_criteria.dart'
    show InteractionsCriteria;
import 'package:orbit/features/interactions/domain/entities/interaction_entity.dart';
import 'package:orbit/features/interactions/presentation/blocs/interactions_list/interactions_list_bloc.dart'
    show InteractionsListBloc;
import 'package:orbit/features/interactions/presentation/blocs/interactions_list/interactions_list_event.dart';
import 'package:orbit/features/interactions/presentation/blocs/interactions_list/interactions_list_state.dart';
import 'package:orbit/features/interactions/presentation/cubits/interaction_form/interaction_form_cubit.dart';
import 'package:orbit/features/interactions/presentation/cubits/interaction_form/interaction_form_state.dart';
import 'package:orbit/features/interactions/presentation/cubits/interaction_delete/interaction_delete_cubit.dart';
import 'package:orbit/features/interactions/presentation/cubits/interaction_delete/interaction_delete_state.dart';
import 'package:orbit/features/interactions/presentation/widgets/interactions_feed_view.dart';
import 'package:orbit/features/interactions/presentation/widgets/interactions_feed_header.dart';
import 'package:orbit/features/interactions/presentation/widgets/interactions_feed_state_body.dart';
import 'package:orbit/features/interactions/presentation/view_models/interaction_tile_data.dart';
import 'package:orbit/core/animations/loading/shimmer_box.dart';

import '../../test_helpers.dart';

class _MockListBloc extends MockBloc<InteractionsListEvent, InteractionsListState>
    implements InteractionsListBloc {}

class _MockFormCubit extends MockBloc<void, InteractionFormState>
    implements InteractionFormCubit {}

class _MockDeleteCubit extends MockBloc<void, InteractionDeleteState>
    implements InteractionDeleteCubit {}

class _MockCallbacks extends Mock {
  void onOpenOpportunity(int opportunityId);
}

void main() {
  group('InteractionsFeedView', () {
    late _MockListBloc listBloc;
    late _MockFormCubit formCubit;
    late _MockDeleteCubit deleteCubit;
    late _MockCallbacks callbacks;
    final today = DateTime(2025, 6, 15);

    setUp(() {
      listBloc = _MockListBloc();
      formCubit = _MockFormCubit();
      deleteCubit = _MockDeleteCubit();
      callbacks = _MockCallbacks();

      registerFallbackValue(const InteractionsListRefreshed());
      registerFallbackValue(const InteractionsListSearchChanged(''));
      registerFallbackValue(const InteractionsListFiltersChanged());
      registerFallbackValue(InteractionTileData(
        id: 1,
        type: InteractionType.call,
        subject: 'Test',
        description: 'Desc',
        date: today,
      ));
    });

    Widget buildTestWidget({
      required InteractionsListState listState,
      required InteractionFormState formState,
      required InteractionDeleteState deleteState,
    }) {
      whenListen(
        listBloc,
        Stream.value(listState),
        initialState: listState,
      );
      whenListen(
        formCubit,
        Stream.value(formState),
        initialState: formState,
      );
      whenListen(
        deleteCubit,
        Stream.value(deleteState),
        initialState: deleteState,
      );

      return MultiBlocProvider(
        providers: [
          BlocProvider<InteractionsListBloc>.value(value: listBloc),
          BlocProvider<InteractionFormCubit>.value(value: formCubit),
          BlocProvider<InteractionDeleteCubit>.value(value: deleteCubit),
        ],
        child: InteractionsFeedView(onOpenOpportunity: callbacks.onOpenOpportunity),
      );
    }

    testWidgets('initial load shows skeleton via Bloc',
        (WidgetTester tester) async {
      final listState = const InteractionsListInitial(
        criteria: InteractionsCriteria(),
      );

      await pumpWidget(
        tester,
        buildTestWidget(
          listState: listState,
          formState: const InteractionFormInitial(),
          deleteState: const InteractionDeleteInitial(),
        ),
      );

      // Should show skeleton (ShimmerBox)
      expect(find.byType(ShimmerBox), findsNWidgets(3));
    });

    testWidgets('pull-to-refresh dispatches InteractionsListRefreshed',
        (WidgetTester tester) async {
      final interactions = [
        InteractionTileData(
          id: 1,
          type: InteractionType.call,
          subject: 'Test Call',
          description: 'Description',
          date: today,
        ),
      ];

      final successState = InteractionsListSuccess(
        criteria: const InteractionsCriteria(),
        interactions: interactions
            .map(
              (e) => Interaction(
                interactionId: e.id,
                type: e.type,
                subject: e.subject,
                description: e.description,
                interactionDate: e.date,
                customerId: e.customerId ?? 1,
                employeeId: 1,
                contactId: e.contactId,
                opportunityId: e.opportunityId,
              ),
            )
            .toList(),
      );

      await pumpWidget(
        tester,
        buildTestWidget(
          listState: successState,
          formState: const InteractionFormInitial(),
          deleteState: const InteractionDeleteInitial(),
        ),
      );

      // Find RefreshIndicator and pull
      final refreshIndicator = find.byType(RefreshIndicator);
      expect(refreshIndicator, findsOneWidget);

      // Drag down to trigger refresh
      await tester.drag(refreshIndicator, const Offset(0, 300));
      await tester.pumpAndSettle();

      // Should have dispatched Refreshed
      verify(() => listBloc.add(const InteractionsListRefreshed())).called(1);
    });

    testWidgets('renders header, content, and bottom padding',
        (WidgetTester tester) async {
      final listState = const InteractionsListInitial(
        criteria: InteractionsCriteria(),
      );

      await pumpWidget(
        tester,
        buildTestWidget(
          listState: listState,
          formState: const InteractionFormInitial(),
          deleteState: const InteractionDeleteInitial(),
        ),
      );

      // Should have CustomScrollView with slivers
      expect(find.byType(CustomScrollView), findsOneWidget);

      // Should have header
      expect(find.byType(InteractionsFeedHeader), findsOneWidget);

      // Should have state body
      expect(find.byType(InteractionsFeedStateBody), findsOneWidget);

      // Should have bottom padding
      expect(find.byWidgetPredicate(
        (widget) => widget is SizedBox && widget.height == 100,
      ), findsOneWidget);
    });
  });
}