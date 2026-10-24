import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/constants/app_consts.dart';
import 'package:orbit/core/errors/exceptions.dart';
import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/router/pending_signup_session.dart';
import 'package:orbit/core/router/route_names.dart';
import 'package:orbit/core/router/route_paths.dart';
import 'package:orbit/core/theme/app_theme.dart';
import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/core/widgets/app_button.dart';
import 'package:orbit/features/auth/domain/entities/employee_status_info_entity.dart';
import 'package:orbit/features/auth/domain/enums/employment_status.dart';
import 'package:orbit/features/auth/domain/usecases/get_employee_status_usecase.dart';
import 'package:orbit/features/auth/presentation/cubits/employee_status/employee_status_cubit.dart';
import 'package:orbit/features/auth/presentation/screens/pending_screen.dart';

class MockGetEmployeeStatusUseCase extends Mock
    implements GetEmployeeStatusUseCase {}

const tEmail = 'adam@orbit.app';
const tPendingInfo = EmployeeStatusInfo(
  firstName: 'Adam',
  lastName: 'Orbit',
  status: EmploymentStatus.pending,
);
const tApprovedInfo = EmployeeStatusInfo(
  firstName: 'Adam',
  lastName: 'Orbit',
  status: EmploymentStatus.approved,
);
const tRejectedInfo = EmployeeStatusInfo(
  firstName: 'Adam',
  lastName: 'Orbit',
  status: EmploymentStatus.rejected,
);
const tUnknownInfo = EmployeeStatusInfo(
  firstName: 'Adam',
  lastName: 'Orbit',
  status: EmploymentStatus.unknown,
);

void main() {
  late PendingSignupSession session;

  setUp(() {
    session = PendingSignupSession()..start(tEmail);
    addTearDown(session.dispose);
  });

  Future<void> pumpPending(
    WidgetTester tester,
    EmployeeStatusCubit cubit,
  ) async {
    addTearDown(cubit.close);
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: RoutePaths.pending,
      routes: [
        GoRoute(
          path: RoutePaths.pending,
          name: RouteNames.pending,
          builder: (_, _) => BlocProvider.value(
            value: cubit,
            child: PendingScreen(session: session),
          ),
        ),
        GoRoute(
          path: RoutePaths.login,
          name: RouteNames.login,
          builder: (_, _) => const Scaffold(body: Text('Login destination')),
        ),
        GoRoute(
          path: RoutePaths.signup,
          name: RouteNames.signup,
          builder: (_, _) => const Scaffold(body: Text('Signup destination')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp.router(
          theme: AppTheme.light,
          routerConfig: router,
          // The hero orbit repeats forever; reduced motion keeps the tests
          // deterministic and still exercises IdleLoop's settled frame.
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
        ),
      ),
    );
  }

  Finder checkButton() =>
      find.widgetWithText(AppButton, t.auth.pending.checkStatus);

  EmployeeStatusCubit cubitReturning(ApiResult<EmployeeStatusInfo> result) {
    final useCase = MockGetEmployeeStatusUseCase();
    when(() => useCase()).thenAnswer((_) async => result);
    return EmployeeStatusCubit(useCase);
  }

  group('PendingScreen', () {
    testWidgets('should show the email and never-checked state on entry', (
      tester,
    ) async {
      final useCase = MockGetEmployeeStatusUseCase();
      await pumpPending(tester, EmployeeStatusCubit(useCase));

      expect(find.text(t.auth.pending.title), findsOneWidget);
      expect(find.text(tEmail), findsOneWidget);
      expect(find.text(t.auth.pending.lastCheckedNever), findsOneWidget);
      expect(find.text(t.auth.pending.statuses.pending), findsOneWidget);
      expect(find.text(t.auth.pending.stepper.submitted), findsOneWidget);
      expect(find.text(t.auth.pending.stepper.review), findsOneWidget);
      expect(find.text(t.auth.pending.stepper.decision), findsOneWidget);
      expect(checkButton(), findsOneWidget);
      expect(find.text(t.auth.pending.unchanged), findsNothing);
      expect(
        tester
            .widgetList<PopScope>(find.byType(PopScope))
            .where((scope) => !scope.canPop),
        isNotEmpty,
      );

      verifyNever(() => useCase());
    });

    testWidgets('should check once, show the unchanged notice and cool down', (
      tester,
    ) async {
      final useCase = MockGetEmployeeStatusUseCase();
      final pending = Completer<ApiResult<EmployeeStatusInfo>>();
      when(() => useCase()).thenAnswer((_) => pending.future);
      await pumpPending(tester, EmployeeStatusCubit(useCase));

      await tester.tap(checkButton());
      await tester.pump();

      final loadingButton = tester.widget<AppButton>(find.byType(AppButton));
      expect(loadingButton.isLoading, isTrue);
      expect(loadingButton.onPressed, isNull);

      await tester.tap(find.byType(AppButton));
      await tester.pump();
      verify(() => useCase()).called(1);

      pending.complete(const Success(tPendingInfo));
      await tester.pumpAndSettle();

      expect(find.text(t.auth.pending.unchanged), findsOneWidget);
      expect(find.text(t.auth.pending.greeting(name: 'Adam')), findsOneWidget);
      expect(find.text(t.auth.pending.lastCheckedNever), findsNothing);
      expect(find.textContaining('Last checked:'), findsOneWidget);
      expect(find.text(t.auth.pending.cooldown), findsOneWidget);
      expect(
        tester.widget<AppButton>(find.byType(AppButton)).onPressed,
        isNull,
      );

      await tester.pump(AppConsts.pendingCheckCooldown);
      await tester.pump();

      expect(find.text(t.auth.pending.cooldown), findsNothing);
      expect(
        tester.widget<AppButton>(find.byType(AppButton)).onPressed,
        isNotNull,
      );
    });

    testWidgets('should keep the cooldown and show a banner on failure', (
      tester,
    ) async {
      final cubit = cubitReturning(
        const ResultFailure(
          NetworkFailure(
            message: 'offline',
            reason: NetworkErrorReason.noInternet,
          ),
        ),
      );
      await pumpPending(tester, cubit);

      await tester.tap(checkButton());
      await tester.pumpAndSettle();

      expect(find.text(t.auth.pending.errorTitle), findsOneWidget);
      expect(find.text(t.errors.offline), findsOneWidget);
      expect(find.text(t.auth.pending.lastCheckedNever), findsNothing);
      expect(
        tester.widget<AppButton>(find.byType(AppButton)).onPressed,
        isNull,
      );
      expect(find.byType(PendingScreen), findsOneWidget);
    });

    testWidgets('should play the approved moment then replace with login', (
      tester,
    ) async {
      final cubit = cubitReturning(const Success(tApprovedInfo));
      await pumpPending(tester, cubit);

      await tester.tap(checkButton());
      await tester.pumpAndSettle();

      expect(find.text(t.auth.pending.moments.approved), findsOneWidget);
      expect(find.byType(AppButton), findsNothing);
      expect(session.hasPendingSignup, isTrue);

      await tester.pump(AppConsts.pendingMomentHold);
      await tester.pumpAndSettle();

      expect(find.text('Login destination'), findsOneWidget);
      expect(find.byType(PendingScreen), findsNothing);
      expect(session.hasPendingSignup, isFalse);
    });

    testWidgets('should play the rejected moment then replace with signup', (
      tester,
    ) async {
      final cubit = cubitReturning(const Success(tRejectedInfo));
      await pumpPending(tester, cubit);

      await tester.tap(checkButton());
      await tester.pumpAndSettle();

      expect(find.text(t.auth.pending.moments.rejected), findsOneWidget);

      await tester.pump(AppConsts.pendingMomentHold);
      await tester.pumpAndSettle();

      expect(find.text('Signup destination'), findsOneWidget);
      expect(find.byType(PendingScreen), findsNothing);
      expect(session.hasPendingSignup, isFalse);
    });

    testWidgets('should stay on the screen for an unknown status', (
      tester,
    ) async {
      final cubit = cubitReturning(const Success(tUnknownInfo));
      await pumpPending(tester, cubit);

      await tester.tap(checkButton());
      await tester.pumpAndSettle();

      expect(find.text(t.auth.pending.statuses.unknown), findsOneWidget);
      expect(find.text(t.auth.pending.moments.approved), findsNothing);
      expect(find.text(t.auth.pending.moments.rejected), findsNothing);
      expect(find.text(t.auth.pending.unchanged), findsNothing);
      expect(find.byType(PendingScreen), findsOneWidget);
    });
  });
}
