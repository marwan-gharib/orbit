import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/animations/loading/animated_progress_bar.dart';
import 'package:orbit/core/widgets/empty_state.dart';
import 'package:orbit/core/widgets/error_state.dart' show ErrorState;
import 'package:orbit/features/interactions/domain/entities/interaction_entity.dart';
import 'package:orbit/features/interactions/domain/enums/interaction_type.dart';
import 'package:orbit/features/interactions/domain/params/interactions_criteria.dart';
import 'package:orbit/features/interactions/presentation/blocs/interactions_list/interactions_list_bloc.dart'
    show InteractionsListBloc;
import 'package:orbit/features/interactions/presentation/blocs/interactions_list/interactions_list_event.dart';
import 'package:orbit/features/interactions/presentation/blocs/interactions_list/interactions_list_state.dart';
import 'package:orbit/features/interactions/presentation/view_models/interaction_tile_data.dart';
import 'package:orbit/features/interactions/presentation/widgets/interaction_refresh_notice.dart';
import 'package:orbit/features/interactions/presentation/widgets/interaction_tile.dart';
import 'package:orbit/features/interactions/presentation/widgets/interaction_tile_skeleton.dart';
import 'package:orbit/features/interactions/presentation/widgets/interactions_feed_state_body.dart';

import '../../test_helpers.dart';

class _MockBloc extends MockBloc<InteractionsListEvent, InteractionsListState>
    implements InteractionsListBloc {}

class _MockCallbacks extends Mock {
  void onEdit(InteractionTileData tile);
  void onDelete(InteractionTileData tile);
  void onOpenOpportunity(int opportunityId);
}

/// The state body builds slivers, so it must live inside a scroll view.
Widget _host(Widget sliver) => CustomScrollView(slivers: [sliver]);

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
      registerFallbackValue(
        InteractionTileData(
          id: 1,
          type: InteractionType.call,
          subject: 'Test',
          description: 'Desc',
          date: today,
        ),
      );
    });

    Widget buildTestWidget({required InteractionsListState initialState}) {
      whenListen(bloc, Stream.value(initialState), initialState: initialState);
      return BlocProvider<InteractionsListBloc>.value(
        value: bloc,
        child: _host(
          InteractionsFeedStateBody(
            onEdit: callbacks.onEdit,
            onDelete: callbacks.onDelete,
            onOpenOpportunity: callbacks.onOpenOpportunity,
          ),
        ),
      );
    }

    List<Interaction> entitiesOf(List<InteractionTileData> tiles) => [
      for (final e in tiles)
        Interaction(
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
    ];

    testWidgets('should show the skeleton twin when the state is initial', (
      WidgetTester tester,
    ) async {
      await pumpWidget(
        tester,
        buildTestWidget(
          initialState: const InteractionsListInitial(
            criteria: InteractionsCriteria(),
          ),
        ),
      );

      expect(find.byType(InteractionGroupHeaderSkeleton), findsNWidgets(2));
      expect(find.byType(InteractionTileSkeletonList), findsNWidgets(2));
      expect(find.byType(InteractionTile), findsNothing);
    });

    testWidgets('should show the skeleton twin when the state is loading', (
      WidgetTester tester,
    ) async {
      await pumpWidget(
        tester,
        buildTestWidget(
          initialState: const InteractionsListLoading(
            criteria: InteractionsCriteria(),
          ),
        ),
      );

      expect(find.byType(InteractionGroupHeaderSkeleton), findsNWidgets(2));
      expect(find.byType(InteractionTileSkeletonList), findsNWidgets(2));
    });

    testWidgets('should show grouped content when the state is success', (
      WidgetTester tester,
    ) async {
      final successState = InteractionsListSuccess(
        criteria: const InteractionsCriteria(),
        interactions: entitiesOf([tileData(1, 'Test Call', today)]),
      );

      await pumpWidget(tester, buildTestWidget(initialState: successState));

      expect(find.byType(InteractionTile), findsOneWidget);
      expect(find.text('Test Call'), findsOneWidget);
    });

    testWidgets(
      'should keep content and show a progress bar while refreshing',
      (WidgetTester tester) async {
        final successState = InteractionsListSuccess(
          criteria: const InteractionsCriteria(),
          interactions: entitiesOf([tileData(1, 'Test Call', today)]),
          isRefreshing: true,
        );

        await pumpWidget(tester, buildTestWidget(initialState: successState));

        expect(find.byType(AnimatedProgressBar), findsOneWidget);
        expect(find.byType(InteractionTile), findsOneWidget);
        expect(find.text('Test Call'), findsOneWidget);
      },
    );

    testWidgets(
      'should keep content and show a dismissible notice when refresh fails',
      (WidgetTester tester) async {
        final failure = ServerFailure(message: 'Network error');
        final successState = InteractionsListSuccess(
          criteria: const InteractionsCriteria(),
          interactions: entitiesOf([tileData(1, 'Test Call', today)]),
          refreshFailure: failure,
        );

        await pumpWidget(tester, buildTestWidget(initialState: successState));

        expect(find.byType(InteractionRefreshNotice), findsOneWidget);
        expect(
          find.text('Refresh failed — previous data kept'),
          findsOneWidget,
        );
        expect(find.byType(InteractionTile), findsOneWidget);

        await tester.tap(find.byIcon(Icons.close));
        await tester.pump();

        expect(find.byType(InteractionRefreshNotice), findsNothing);
        expect(find.byType(InteractionTile), findsOneWidget);
      },
    );

    testWidgets(
      'should show the empty state without a clear action when nothing is filtered',
      (WidgetTester tester) async {
        await pumpWidget(
          tester,
          buildTestWidget(
            initialState: const InteractionsListEmpty(
              criteria: InteractionsCriteria(),
            ),
          ),
        );

        expect(find.byType(EmptyState), findsOneWidget);
        expect(find.text('No interactions'), findsOneWidget);
        expect(
          find.text('Interactions you add will appear here.'),
          findsOneWidget,
        );
        expect(find.text('Clear filters'), findsNothing);
      },
    );

    testWidgets('should offer to clear filters when the search found nothing', (
      WidgetTester tester,
    ) async {
      await pumpWidget(
        tester,
        buildTestWidget(
          initialState: const InteractionsListEmpty(
            criteria: InteractionsCriteria(searchText: 'query'),
          ),
        ),
      );

      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('No interactions match your filters'), findsOneWidget);
      expect(find.text('Clear filters'), findsOneWidget);

      await tester.tap(find.text('Clear filters'));
      await tester.pump();

      verify(() => bloc.add(const InteractionsListFiltersCleared())).called(1);
    });

    testWidgets(
      'should offer to clear filters when the type filter found nothing',
      (WidgetTester tester) async {
        await pumpWidget(
          tester,
          buildTestWidget(
            initialState: const InteractionsListEmpty(
              criteria: InteractionsCriteria(type: InteractionType.call),
            ),
          ),
        );

        expect(find.text('No interactions match your filters'), findsOneWidget);
        expect(find.text('Clear filters'), findsOneWidget);

        await tester.tap(find.text('Clear filters'));
        await tester.pump();

        verify(() => bloc.add(const InteractionsListFiltersCleared()))
            .called(1);
      },
    );

    testWidgets(
      'should show a dismissible notice on the empty state when refresh fails',
      (WidgetTester tester) async {
        final emptyState = InteractionsListEmpty(
          criteria: const InteractionsCriteria(),
          refreshFailure: ServerFailure(message: 'Network error'),
        );

        await pumpWidget(tester, buildTestWidget(initialState: emptyState));

        expect(find.byType(InteractionRefreshNotice), findsOneWidget);
        expect(find.byType(EmptyState), findsOneWidget);
      },
    );

    testWidgets('should show the error view and retry on tap', (
      WidgetTester tester,
    ) async {
      final errorState = InteractionsListError(
        criteria: const InteractionsCriteria(),
        failure: UnauthorizedFailure(message: 'Unauthorized'),
      );

      await pumpWidget(tester, buildTestWidget(initialState: errorState));

      expect(find.byType(ErrorState), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pump();

      verify(() => bloc.add(const InteractionsListRefreshed())).called(1);
    });

    testWidgets(
      'should localize the error message through context.failureText',
      (WidgetTester tester) async {
        final errorState = InteractionsListError(
          criteria: const InteractionsCriteria(),
          failure: ServerFailure(message: 'Server down'),
        );

        await pumpWidget(tester, buildTestWidget(initialState: errorState));

        expect(find.byType(ErrorState), findsOneWidget);
      },
    );

    testWidgets(
      'should show only the error view after a failed load (no skeleton)',
      (WidgetTester tester) async {
        final errorState = InteractionsListError(
          criteria: const InteractionsCriteria(),
          failure: ServerFailure(message: 'Connection failed'),
        );

        await pumpWidget(tester, buildTestWidget(initialState: errorState));

        expect(find.byType(InteractionGroupHeaderSkeleton), findsNothing);
        expect(find.byType(InteractionTileSkeletonList), findsNothing);
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.byType(ErrorState), findsOneWidget);
      },
    );
  });
}

InteractionTileData tileData(int id, String subject, DateTime date) =>
    InteractionTileData(
      id: id,
      type: InteractionType.call,
      subject: subject,
      description: 'Description',
      date: date,
    );
