import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/animations/tokens/app_durations.dart';
import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/features/opportunities/domain/entities/opportunity_entity.dart';
import 'package:orbit/features/opportunities/domain/enums/opportunity_stage.dart';
import 'package:orbit/features/opportunities/domain/params/opportunities_criteria.dart';
import 'package:orbit/features/opportunities/presentation/blocs/opportunities_list/opportunities_list_bloc.dart';
import 'package:orbit/features/opportunities/presentation/blocs/opportunities_list/opportunities_list_event.dart';
import 'package:orbit/features/opportunities/presentation/blocs/opportunities_list/opportunities_list_state.dart';
import 'package:orbit/features/opportunities/presentation/widgets/opportunities_list_notices.dart';
import 'package:orbit/features/opportunities/presentation/widgets/opportunities_list_sliver.dart';
import 'package:orbit/features/opportunities/presentation/widgets/opportunities_stage_chips.dart';
import 'package:orbit/features/opportunities/presentation/widgets/opportunities_status_filter.dart';
import 'package:orbit/features/opportunities/presentation/widgets/opportunities_tab_view.dart';
import 'package:orbit/features/opportunities/presentation/widgets/opportunity_card.dart';
import 'package:orbit/features/opportunities/presentation/widgets/opportunity_card_skeleton.dart';

import '../../../../core/widgets/harness.dart';
import '../../opportunities_test_mocks.dart';

class _MockListBloc
    extends MockBloc<OpportunitiesListEvent, OpportunitiesListState>
    implements OpportunitiesListBloc {}

/// Pumps the tab view bound to a `MockBloc` in a tall viewport so the whole
/// sliver tree builds. The caller has already run `whenListen(bloc, ...)`.
Future<void> pumpTab(WidgetTester tester, OpportunitiesListBloc bloc) async {
  tester.view.physicalSize = const Size(800, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await pumpWidget(
    tester,
    BlocProvider<OpportunitiesListBloc>.value(
      value: bloc,
      child: OpportunitiesTabView(onOpenOpportunity: (_) {}),
    ),
    settle: false,
  );
  await tester.pump();
}

/// One frame for stream emissions, then past the sliver's stagger settle
/// timer so no timer outlives the test.
Future<void> pumpSettled(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(AppDurations.extraSlow + AppDurations.normal);
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump();
}

OpportunitiesListSuccess success({
  List<Opportunity>? items,
  bool hasMore = false,
  int? nextPage,
  Failure? refreshFailure,
}) => OpportunitiesListSuccess(
  criteria: const OpportunitiesCriteria(),
  items: items ?? [tOpportunity()],
  hasMore: hasMore,
  nextPage: nextPage,
  totalCount: items?.length ?? 1,
  refreshFailure: refreshFailure,
);

void main() {
  setUpAll(() {
    registerOpportunitiesFallbacks();
    registerFallbackValue(OpportunitiesListFiltersCleared());
    registerFallbackValue(OpportunitiesListLoadMoreRequested());
  });

  testWidgets(
    'should show the skeleton, stage chips and status filter while loading',
    (WidgetTester tester) async {
      final bloc = _MockListBloc();
      whenListen(
        bloc,
        const Stream<OpportunitiesListState>.empty(),
        initialState: const OpportunitiesListLoading(
          criteria: OpportunitiesCriteria(),
        ),
      );
      await pumpTab(tester, bloc);

      expect(find.byType(OpportunitiesListSkeleton), findsOneWidget);
      expect(find.byType(OpportunitiesStageChips), findsOneWidget);
      expect(find.byType(OpportunitiesStatusFilter), findsOneWidget);
      expect(find.byType(OpportunityCard), findsNothing);
    },
  );

  testWidgets('should show the loaded cards and the count on success', (
    WidgetTester tester,
  ) async {
    final bloc = _MockListBloc();
    whenListen(
      bloc,
      const Stream<OpportunitiesListState>.empty(),
      initialState: success(),
    );

    await pumpTab(tester, bloc);
    await pumpSettled(tester);

    expect(find.byType(OpportunitiesListSliver), findsOneWidget);
    expect(find.byType(OpportunityCard), findsOneWidget);
    expect(find.text('1 opportunity'), findsOneWidget);
  });

  testWidgets(
    'should show the filtered empty view and dispatch FiltersCleared on tap',
    (WidgetTester tester) async {
      final bloc = _MockListBloc();
      whenListen(
        bloc,
        const Stream<OpportunitiesListState>.empty(),
        initialState: const OpportunitiesListEmpty(
          criteria: OpportunitiesCriteria(stage: OpportunityStage.lead),
          totalCount: 0,
        ),
      );

      await pumpTab(tester, bloc);
      await pumpSettled(tester);

      expect(find.text('No opportunities match your filters'), findsOneWidget);
      expect(find.text('Clear filters'), findsNWidgets(2));

      await tester.tap(find.text('Clear filters').last);
      verify(
        () => bloc.add(
          any<OpportunitiesListEvent>(
            that: isA<OpportunitiesListFiltersCleared>(),
          ),
        ),
      ).called(1);
    },
  );

  testWidgets('should show the error view with retry when the load failed', (
    WidgetTester tester,
  ) async {
    final bloc = _MockListBloc();
    whenListen(
      bloc,
      const Stream<OpportunitiesListState>.empty(),
      initialState: const OpportunitiesListError(
        criteria: OpportunitiesCriteria(),
        failure: ServerFailure(message: 'down'),
      ),
    );

    await pumpTab(tester, bloc);
    await pumpSettled(tester);

    expect(find.byType(OpportunitiesErrorView), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.byType(OpportunityCard), findsNothing);
  });

  testWidgets(
    'should show the dismissible refresh-failed notice and keep items',
    (WidgetTester tester) async {
      final bloc = _MockListBloc();
      whenListen(
        bloc,
        const Stream<OpportunitiesListState>.empty(),
        initialState: success(refreshFailure: ServerFailure(message: 'down')),
      );

      await pumpTab(tester, bloc);
      await pumpSettled(tester);

      expect(find.byType(OpportunityCard), findsOneWidget);
      expect(find.byType(RefreshFailedNotice), findsOneWidget);
      expect(find.text('Refresh failed — previous data kept'), findsOneWidget);

      await tester.tap(find.text('Dismiss'));
      await tester.pump();
      await tester.pump();
      expect(find.byType(RefreshFailedNotice), findsNothing);
      expect(find.byType(OpportunityCard), findsOneWidget);
    },
  );

  testWidgets('should dispatch LoadMoreRequested when scrolled near the end', (
    WidgetTester tester,
  ) async {
    final bloc = _MockListBloc();
    // Enough cards to overflow the tall viewport so a drag really scrolls.
    final items = [for (var i = 1; i <= 30; i++) tOpportunity(id: i)];
    whenListen(
      bloc,
      StreamController<OpportunitiesListState>().stream,
      initialState: success(items: items, hasMore: true, nextPage: 2),
    );

    await pumpTab(tester, bloc);
    await pumpSettled(tester);

    // Scroll to the very end: within `loadMoreThreshold` of the max
    // extent, the tab must request the next page.
    final scrollable = tester.state<ScrollableState>(
      find
          .descendant(
            of: find.byType(CustomScrollView).first,
            matching: find.byType(Scrollable),
          )
          .first,
    );
    scrollable.position.jumpTo(scrollable.position.maxScrollExtent);
    await tester.pump();
    verify(
      () => bloc.add(
        any<OpportunitiesListEvent>(
          that: isA<OpportunitiesListLoadMoreRequested>(),
        ),
      ),
    ).called(1);
  });
}
