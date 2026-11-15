import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/animations/tokens/app_durations.dart';
import 'package:orbit/core/di/injection_container.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/router/route_paths.dart';
import 'package:orbit/features/crm_dashboard/presentation/cubits/dashboard/dashboard_cubit.dart';
import 'package:orbit/features/crm_dashboard/presentation/cubits/dashboard/dashboard_state.dart';
import 'package:orbit/features/crm_shell/presentation/widgets/crm_shell.dart';
import 'package:orbit/features/interactions/presentation/blocs/interactions_list/interactions_list_bloc.dart';
import 'package:orbit/features/interactions/presentation/blocs/interactions_list/interactions_list_event.dart';
import 'package:orbit/features/interactions/presentation/blocs/interactions_list/interactions_list_state.dart';
import 'package:orbit/features/interactions/presentation/cubits/interaction_delete/interaction_delete_cubit.dart';
import 'package:orbit/features/interactions/presentation/cubits/interaction_delete/interaction_delete_state.dart';
import 'package:orbit/features/interactions/presentation/cubits/interaction_form/interaction_form_cubit.dart';
import 'package:orbit/features/interactions/presentation/cubits/interaction_form/interaction_form_state.dart';
import 'package:orbit/features/interactions/domain/params/interactions_criteria.dart';
import 'package:orbit/features/opportunities/domain/params/opportunities_criteria.dart';
import 'package:orbit/features/opportunities/presentation/blocs/opportunities_list/opportunities_list_bloc.dart';
import 'package:orbit/features/opportunities/presentation/blocs/opportunities_list/opportunities_list_event.dart';
import 'package:orbit/features/opportunities/presentation/blocs/opportunities_list/opportunities_list_state.dart';
import 'package:orbit/features/opportunities/presentation/widgets/opportunity_card.dart';
import 'package:orbit/features/opportunities/presentation/widgets/opportunity_card_skeleton.dart'
    show OpportunitiesListSkeleton;

import '../../../crm_dashboard/crm_dashboard_test_mocks.dart';
import '../../../opportunities/opportunities_test_mocks.dart';
import '../../../../core/widgets/harness.dart';

class _MockOpportunitiesBloc
    extends MockBloc<OpportunitiesListEvent, OpportunitiesListState>
    implements OpportunitiesListBloc {}

class _MockFormCubit extends MockBloc<void, InteractionFormState>
    implements InteractionFormCubit {}

class _MockDeleteCubit extends MockBloc<void, InteractionDeleteState>
    implements InteractionDeleteCubit {}

class _MockInteractionsBloc
    extends MockBloc<InteractionsListEvent, InteractionsListState>
    implements InteractionsListBloc {}

void main() {
  setUpAll(() => registerOpportunitiesFallbacks());

  late MockDashboardCubit dashboardCubit;
  late _MockOpportunitiesBloc opportunitiesBloc;
  late _MockFormCubit formCubit;
  late _MockDeleteCubit deleteCubit;
  late _MockInteractionsBloc interactionsBloc;

  setUp(() {
    dashboardCubit = MockDashboardCubit();
    opportunitiesBloc = _MockOpportunitiesBloc();
    formCubit = _MockFormCubit();
    deleteCubit = _MockDeleteCubit();
    interactionsBloc = _MockInteractionsBloc();

    getIt
      ..registerSingleton<DashboardCubit>(dashboardCubit)
      ..registerSingleton<InteractionFormCubit>(formCubit)
      ..registerSingleton<InteractionDeleteCubit>(deleteCubit)
      ..registerSingleton<InteractionsListBloc>(interactionsBloc);

    when(() => dashboardCubit.load()).thenAnswer((_) async {});
    whenListen(
      dashboardCubit,
      const Stream<DashboardState>.empty(),
      initialState: const DashboardInitial(),
    );
    whenListen(
      opportunitiesBloc,
      const Stream<OpportunitiesListState>.empty(),
      initialState: const OpportunitiesListInitial(
        criteria: OpportunitiesCriteria(),
      ),
    );
    whenListen(
      formCubit,
      const Stream<InteractionFormState>.empty(),
      initialState: const InteractionFormInitial(),
    );
    whenListen(
      deleteCubit,
      const Stream<InteractionDeleteState>.empty(),
      initialState: const InteractionDeleteInitial(),
    );
    whenListen(
      interactionsBloc,
      const Stream<InteractionsListState>.empty(),
      initialState: const InteractionsListInitial(
        criteria: InteractionsCriteria(),
      ),
    );
  });

  tearDown(() async => getIt.reset());

  GoRouter router() => GoRouter(
    initialLocation: RoutePaths.crm,
    routes: [
      GoRoute(
        path: RoutePaths.crm,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          child: BlocProvider<OpportunitiesListBloc>.value(
            value: opportunitiesBloc,
            child: const CrmShell(),
          ),
        ),
      ),
      GoRoute(
        path: RoutePaths.crmOpportunityDetails,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          child: Scaffold(body: Text('detail ${state.pathParameters['id']}')),
        ),
      ),
    ],
  );

  testWidgets('should show the CRM title and the three tab labels', (
    tester,
  ) async {
    await pumpApp(tester, routerConfig: router());

    expect(find.text(t.crm.title), findsOneWidget);
    expect(find.text(t.crm.tabs.dashboard), findsOneWidget);
    expect(find.text(t.crm.tabs.opportunities), findsOneWidget);
    expect(find.text(t.crm.tabs.interactions), findsOneWidget);
  });

  testWidgets('should start on the dashboard tab and load it once', (
    tester,
  ) async {
    await pumpApp(tester, routerConfig: router());

    expect(find.byType(OpportunitiesListSkeleton), findsNothing);
    verify(() => dashboardCubit.load()).called(1);
    verifyNever(() => opportunitiesBloc.add(OpportunitiesListStarted()));
  });

  testWidgets('should build the opportunities tab and start its list when '
      'selected', (tester) async {
    await pumpApp(tester, routerConfig: router());

    await tester.tap(find.byIcon(Icons.work_outline_rounded));
    await tester.pump();
    await tester.pump(AppDurations.normal);

    verify(() => opportunitiesBloc.add(OpportunitiesListStarted())).called(1);
    expect(find.byType(OpportunitiesListSkeleton), findsOneWidget);
  });

  testWidgets('should push the detail screen when an opportunity is opened', (
    tester,
  ) async {
    whenListen(
      opportunitiesBloc,
      const Stream<OpportunitiesListState>.empty(),
      initialState: OpportunitiesListSuccess(
        criteria: const OpportunitiesCriteria(),
        items: [tOpportunity(id: 7)],
        hasMore: false,
        nextPage: null,
        totalCount: 1,
      ),
    );

    await pumpApp(tester, routerConfig: router());

    await tester.tap(find.byIcon(Icons.work_outline_rounded));
    await tester.pump();
    await tester.pump(AppDurations.normal);
    await tester.pump(AppDurations.extraSlow);

    expect(find.byType(OpportunityCard), findsOneWidget);

    await tester.tap(find.byType(OpportunityCard));
    await tester.pump();
    await tester.pump(AppDurations.normal);

    expect(find.text('detail 7'), findsOneWidget);
  });
}
