import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/animations/tokens/app_durations.dart';
import 'package:orbit/core/di/injection_container.dart';
import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/widgets/error_state.dart';
import 'package:orbit/features/crm_dashboard/presentation/cubits/dashboard/dashboard_cubit.dart';
import 'package:orbit/features/crm_dashboard/presentation/cubits/dashboard/dashboard_state.dart';
import 'package:orbit/features/crm_dashboard/presentation/widgets/dashboard_skeleton.dart';
import 'package:orbit/features/crm_dashboard/presentation/widgets/dashboard_tab.dart';
import 'package:orbit/features/crm_dashboard/presentation/widgets/dashboard_view.dart';

import '../../crm_dashboard_test_mocks.dart';
import '../../../../core/widgets/harness.dart';

void main() {
  setUpAll(() => registerDashboardFallbacks());

  late MockDashboardCubit cubit;

  setUp(() {
    cubit = MockDashboardCubit();
    getIt.registerSingleton<DashboardCubit>(cubit);
    when(() => cubit.load()).thenAnswer((_) async {});
  });

  tearDown(() => getIt.reset());

  testWidgets('should request the first load when the tab is displayed', (
    tester,
  ) async {
    whenListen(
      cubit,
      const Stream<DashboardState>.empty(),
      initialState: const DashboardInitial(),
    );

    await pumpWidget(tester, const DashboardTab(), settle: false);
    await tester.pump(AppDurations.extraSlow + AppDurations.normal);

    verify(() => cubit.load()).called(1);
  });

  testWidgets('should show the skeleton while the overview is loading', (
    tester,
  ) async {
    whenListen(
      cubit,
      const Stream<DashboardState>.empty(),
      initialState: const DashboardInitial(),
    );

    await pumpWidget(tester, const DashboardTab(), settle: false);
    await tester.pump(AppDurations.extraSlow + AppDurations.normal);

    expect(find.byType(DashboardSkeleton), findsOneWidget);
    expect(find.byType(DashboardView), findsNothing);
  });

  testWidgets('should show the dashboard figures after a successful load', (
    tester,
  ) async {
    whenListen(
      cubit,
      const Stream<DashboardState>.empty(),
      initialState: DashboardSuccess(overview: tOverview()),
    );

    await pumpWidget(tester, const DashboardTab(), settle: false);
    await tester.pump(AppDurations.extraSlow + AppDurations.normal);

    expect(find.byType(DashboardView), findsOneWidget);
    expect(find.byType(DashboardSkeleton), findsNothing);
  });

  testWidgets(
    'should show the empty state for a brand-new CRM after a successful '
    'load',
    (tester) async {
      whenListen(
        cubit,
        const Stream<DashboardState>.empty(),
        initialState: DashboardSuccess(overview: tEmptyOverview()),
      );

      await pumpWidget(tester, const DashboardTab(), settle: false);
      await tester.pump(AppDurations.extraSlow + AppDurations.normal);

      expect(find.text(t.crm.dashboard.empty.title), findsOneWidget);
    },
  );

  testWidgets('should show the retryable error and load again on Retry', (
    tester,
  ) async {
    whenListen(
      cubit,
      const Stream<DashboardState>.empty(),
      initialState: const DashboardError(ServerFailure(message: 'down')),
    );

    await pumpWidget(tester, const DashboardTab(), settle: false);
    await tester.pump(AppDurations.extraSlow + AppDurations.normal);

    expect(find.byType(ErrorState), findsOneWidget);
    expect(find.text(t.crm.common.retry), findsOneWidget);

    await tester.tap(find.text(t.crm.common.retry));
    await tester.pump(AppDurations.fast);

    verify(() => cubit.load()).called(2);
  });
}
