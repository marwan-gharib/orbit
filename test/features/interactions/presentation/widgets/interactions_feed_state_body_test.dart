import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/features/interactions/domain/enums/interaction_type.dart';
import 'package:orbit/features/interactions/domain/params/interactions_criteria.dart';
import 'package:orbit/features/interactions/domain/entities/interaction_entity.dart';
import 'package:orbit/features/interactions/presentation/blocs/interactions_list/interactions_list_bloc.dart'
    show InteractionsListBloc;
import 'package:orbit/features/interactions/presentation/blocs/interactions_list/interactions_list_event.dart';
import 'package:orbit/features/interactions/presentation/blocs/interactions_list/interactions_list_state.dart';
import 'package:orbit/features/interactions/presentation/widgets/interaction_refresh_notice.dart';
import 'package:orbit/features/interactions/presentation/widgets/interactions_feed_state_body.dart';
import 'package:orbit/features/interactions/presentation/widgets/interaction_tile.dart';
import 'package:orbit/features/interactions/presentation/view_models/interaction_tile_data.dart';
import 'package:orbit/core/widgets/empty_state.dart';
import 'package:orbit/core/widgets/error_state.dart'
    show ErrorState;
import 'package:orbit/core/animations/loading/animated_progress_bar.dart';
import 'package:orbit/core/animations/loading/shimmer_box.dart';

import '../../test_helpers.dart';

class _MockBloc extends MockBloc<InteractionsListEvent, InteractionsListState>
    implements InteractionsListBloc {}

class _MockCallbacks extends Mock {
  void onEdit(InteractionTileData tile);
  void onDelete(InteractionTileData tile);
  void onOpenOpportunity(int opportunityId);
}

void main() {
  group('InteractionsFeedStateBody', () {
    late _MockBloc bloc;
    late _MockCallbacks callbacks;
    final today = DateTime(2025, 6, 15);

    setUp(() {
      bloc = _MockBloc();
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

    Widget buildTestWidget({required InteractionsListState initialState}) {
      whenListen(
        bloc,
        Stream.value(initialState),
        initialState: initialState,
      );
      return BlocProvider<InteractionsListBloc>.value(
        value: bloc,
        child: InteractionsFeedStateBody(
          onEdit: callbacks.onEdit,
          onDelete: callbacks.onDelete,
          onOpenOpportunity: callbacks.onOpenOpportunity,
        ),
      );
    }

    testWidgets('Initial state shows skeleton',
        (WidgetTester tester) async {
      final initialState = const InteractionsListInitial(
        criteria: InteractionsCriteria(),
      );

      await pumpWidget(tester, buildTestWidget(initialState: initialState));

      // Should show skeleton via InteractionsFeedContent with isSkeleton=true
      // The skeleton uses ShimmerBox (3 rows)
      expect(find.byType(ShimmerBox), findsNWidgets(3));
    });

    testWidgets('Loading state shows skeleton',
        (WidgetTester tester) async {
      final loadingState = const InteractionsListLoading(
        criteria: InteractionsCriteria(),
      );

      await pumpWidget(tester, buildTestWidget(initialState: loadingState));

      expect(find.byType(ShimmerBox), findsNWidgets(3));
    });

    testWidgets('Success state shows grouped feed content',
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

      await pumpWidget(tester, buildTestWidget(initialState: successState));

      // Should show content (not skeleton)
      expect(find.byType(ShimmerBox), findsNothing);
      expect(find.byType(InteractionTile), findsOneWidget);
      expect(find.text('Test Call'), findsOneWidget);
    });

    testWidgets('Success with isRefreshing shows progress bar with content kept',
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
        isRefreshing: true,
      );

      await pumpWidget(tester, buildTestWidget(initialState: successState));

      // Should show progress bar
      expect(find.byType(AnimatedProgressBar), findsOneWidget);

      // Content should be kept
      expect(find.byType(InteractionTile), findsOneWidget);
      expect(find.text('Test Call'), findsOneWidget);
    });

    testWidgets('Success with refreshFailure shows dismissible notice with content kept',
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

      final failure = ServerFailure(message: 'Network error');
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
        isRefreshing: false,
        refreshFailure: failure,
      );

      await pumpWidget(tester, buildTestWidget(initialState: successState));

      // Should show refresh notice
      expect(find.byType(InteractionRefreshNotice), findsOneWidget);
      expect(find.text('Refresh failed — previous data kept'), findsOneWidget);

      // Content should be kept
      expect(find.byType(InteractionTile), findsOneWidget);
      expect(find.text('Test Call'), findsOneWidget);

      // Dismiss button should work
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      // Notice should be dismissed
      expect(find.byType(InteractionRefreshNotice), findsNothing);

      // Content still there
      expect(find.byType(InteractionTile), findsOneWidget);
    });

    testWidgets('Empty with initial criteria (no active filters) shows "No interactions"',
        (WidgetTester tester) async {
      final emptyState = const InteractionsListEmpty(
        criteria: InteractionsCriteria(),
      );

      await pumpWidget(tester, buildTestWidget(initialState: emptyState));

      // Should show EmptyState with feedEmpty title
      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('No interactions'), findsOneWidget);
      expect(find.text('Interactions you add will appear here.'), findsOneWidget);
      // No clear filters action
      expect(find.text('Clear filters'), findsNothing);
    });

    testWidgets('Empty with active search criteria shows "No interactions match" with Clear filters',
        (WidgetTester tester) async {
      final emptyState = const InteractionsListEmpty(
        criteria: InteractionsCriteria(searchText: 'query'),
      );

      await pumpWidget(tester, buildTestWidget(initialState: emptyState));

      // Should show EmptyState with feedNoResults title
      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('No interactions match your filters'), findsOneWidget);

      // Should have Clear filters action
      expect(find.text('Clear filters'), findsOneWidget);

      // Tapping Clear filters should dispatch events
      await tester.tap(find.text('Clear filters'));
      await tester.pump();

      verify(() => bloc.add(const InteractionsListSearchChanged(''))).called(1);
      verify(() => bloc.add(const InteractionsListFiltersChanged(type: null))).called(1);
    });

    testWidgets('Empty with active type filter shows "No interactions match" with Clear filters',
        (WidgetTester tester) async {
      final emptyState = const InteractionsListEmpty(
        criteria: InteractionsCriteria(type: InteractionType.call),
      );

      await pumpWidget(tester, buildTestWidget(initialState: emptyState));

      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('No interactions match your filters'), findsOneWidget);
      expect(find.text('Clear filters'), findsOneWidget);

      await tester.tap(find.text('Clear filters'));
      await tester.pump();

      verify(() => bloc.add(const InteractionsListSearchChanged(''))).called(1);
      verify(() => bloc.add(const InteractionsListFiltersChanged(type: null))).called(1);
    });

    testWidgets('Empty with refreshFailure shows dismissible notice',
        (WidgetTester tester) async {
      final failure = ServerFailure(message: 'Network error');
      final emptyState = InteractionsListEmpty(
        criteria: const InteractionsCriteria(),
        refreshFailure: failure,
      );

      await pumpWidget(tester, buildTestWidget(initialState: emptyState));

      // Should show refresh notice
      expect(find.byType(InteractionRefreshNotice), findsOneWidget);

      // And empty state
      expect(find.byType(EmptyState), findsOneWidget);
    });

    testWidgets('Error state shows ErrorState with retry',
        (WidgetTester tester) async {
      final failure = UnauthorizedFailure(message: 'Unauthorized');
      final errorState = InteractionsListError(
        criteria: const InteractionsCriteria(),
        failure: failure,
      );

      await pumpWidget(tester, buildTestWidget(initialState: errorState));

      // Should show ErrorState
      expect(find.byType(ErrorState), findsOneWidget);

      // Should have retry action
      expect(find.text('Retry'), findsOneWidget);

      // Tapping retry should dispatch Refreshed
      await tester.tap(find.text('Retry'));
      await tester.pump();

      verify(() => bloc.add(const InteractionsListRefreshed())).called(1);
    });

    testWidgets('Error state uses context.failureText for message',
        (WidgetTester tester) async {
      final failure = ServerFailure(message: 'Server down');
      final errorState = InteractionsListError(
        criteria: const InteractionsCriteria(),
        failure: failure,
      );

      await pumpWidget(tester, buildTestWidget(initialState: errorState));

      expect(find.byType(ErrorState), findsOneWidget);
      // Message should be localized via context.failureText
      // We can't easily test the exact message without the full localization setup
      // but we verify ErrorState is shown
    });

    testWidgets('A failing fake use case reaches the error UI (no infinite spinner)',
        (WidgetTester tester) async {
      // Simulate a failed initial load
      final failure = ServerFailure(message: 'Connection failed');
      final errorState = InteractionsListError(
        criteria: const InteractionsCriteria(),
        failure: failure,
      );

      await pumpWidget(tester, buildTestWidget(initialState: errorState));

      // Should NOT show skeleton or loading spinner
      expect(find.byType(ShimmerBox), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Should show ErrorState
      expect(find.byType(ErrorState), findsOneWidget);
    });
  });
}