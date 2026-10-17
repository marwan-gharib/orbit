import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orbit/core/animations/navigation/app_route.dart';
import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/router/route_names.dart';
import 'package:orbit/core/router/route_paths.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orbit/core/theme/app_theme.dart';
import 'package:orbit/core/widgets/error_state.dart';
import 'package:orbit/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:orbit/features/onboarding/domain/entities/onboarding_page.dart';
import 'package:orbit/features/onboarding/presentation/cubit/onboarding_state.dart';
import 'package:orbit/features/onboarding/presentation/constants/onboarding_layout_constants.dart';
import 'package:orbit/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:orbit/features/onboarding/presentation/widgets/onboarding_page_view.dart';

class MockOnboardingCubit extends MockCubit<OnboardingState>
    implements OnboardingCubit {}

void main() {
  late MockOnboardingCubit cubit;
  late StreamController<OnboardingState> stateController;

  const tPages = <OnboardingPage>[
    OnboardingPage(
      id: 0,
      illustrationType: OnboardingIllustrationType.projects,
    ),
    OnboardingPage(id: 1, illustrationType: OnboardingIllustrationType.people),
    OnboardingPage(id: 2, illustrationType: OnboardingIllustrationType.finance),
    OnboardingPage(
      id: 3,
      illustrationType: OnboardingIllustrationType.insights,
    ),
  ];

  setUp(() {
    cubit = MockOnboardingCubit();
    stateController = StreamController<OnboardingState>.broadcast();
    when(() => cubit.state).thenReturn(const OnboardingLoading());
    when(() => cubit.stream).thenAnswer((_) => stateController.stream);
    when(() => cubit.loadPages()).thenAnswer((_) async {});
    when(() => cubit.complete()).thenAnswer((_) async {});
    when(() => cubit.onPageChanged(any())).thenAnswer((_) async {});
  });

  tearDown(() => stateController.close());

  Future<void> pumpOnboarding(
    WidgetTester tester, {
    required OnboardingState state,
  }) async {
    // Portrait phone so every chrome band and control stays inside the view.
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    when(() => cubit.state).thenReturn(state);

    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp.router(
          theme: AppTheme.light,
          routerConfig: GoRouter(
            initialLocation: RoutePaths.onboarding,
            routes: <RouteBase>[
              AppRoute.create(
                path: RoutePaths.onboarding,
                name: RouteNames.onboarding,
                builder: (_, _) => BlocProvider<OnboardingCubit>.value(
                  value: cubit,
                  child: const OnboardingScreen(),
                ),
              ),
              AppRoute.create(
                path: RoutePaths.login,
                name: RouteNames.login,
                builder: (_, _) => const Text('Login placeholder'),
              ),
            ],
          ),
          builder: (context, child) =>
              Directionality(textDirection: TextDirection.ltr, child: child!),
        ),
      ),
    );

    // Publish the stubbed state so the cubit stream (and therefore the
    // BlocListener in the screen) observes it.
    stateController.add(state);
    await tester.pump();
  }

  group('OnboardingScreen', () {
    testWidgets('should show the loading shell when state is loading', (
      tester,
    ) async {
      await pumpOnboarding(tester, state: const OnboardingLoading());

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(OnboardingPageView), findsNothing);
      expect(find.byType(ErrorState), findsNothing);
    });

    testWidgets('should show the page view and slide 1 headline when state is '
        'success', (tester) async {
      await pumpOnboarding(
        tester,
        state: const OnboardingSuccess(pages: tPages, currentIndex: 0),
      );

      expect(find.byType(OnboardingPageView), findsOneWidget);
      expect(
        find.text(Translations().onboarding.slide1.headline),
        findsOneWidget,
      );
      expect(find.byKey(OnboardingLayoutKeys.skipButton), findsOneWidget);
      expect(find.byKey(OnboardingLayoutKeys.nextButton), findsOneWidget);
      expect(find.byKey(OnboardingLayoutKeys.indicator), findsOneWidget);
    });

    testWidgets('should hide the skip button on the last slide', (
      tester,
    ) async {
      await pumpOnboarding(
        tester,
        state: const OnboardingSuccess(pages: tPages, currentIndex: 3),
      );

      expect(find.byKey(OnboardingLayoutKeys.skipButton), findsNothing);
      expect(find.byKey(OnboardingLayoutKeys.nextButton), findsOneWidget);
    });

    testWidgets('should show the localized error text when state is error', (
      tester,
    ) async {
      const tFailure = CacheFailure(message: 'Storage unavailable');

      await pumpOnboarding(tester, state: OnboardingError(tFailure));

      expect(find.byType(ErrorState), findsOneWidget);
      expect(find.text(Translations().errors.cache), findsOneWidget);
      expect(find.byType(OnboardingPageView), findsNothing);
    });

    testWidgets('should navigate to login when state is completed', (
      tester,
    ) async {
      await pumpOnboarding(tester, state: const OnboardingCompleted());

      await tester.pumpAndSettle();

      expect(find.byType(OnboardingScreen), findsNothing);
      expect(find.text('Login placeholder'), findsOneWidget);
    });

    testWidgets('should call complete when the skip button is tapped', (
      tester,
    ) async {
      await pumpOnboarding(
        tester,
        state: const OnboardingSuccess(pages: tPages, currentIndex: 0),
      );
      // Settle all entrance animations (longest is 1500 ms + 300 ms delay)
      // so the controls are at their settled positions before tapping.
      await tester.pump(const Duration(seconds: 2));

      await tester.tap(find.byKey(OnboardingLayoutKeys.skipButton));

      verify(() => cubit.complete()).called(1);
    });

    testWidgets('should call complete when next is tapped on the last slide', (
      tester,
    ) async {
      await pumpOnboarding(
        tester,
        state: const OnboardingSuccess(pages: tPages, currentIndex: 3),
      );
      await tester.pump(const Duration(seconds: 2));

      await tester.tap(find.byKey(OnboardingLayoutKeys.nextButton));

      verify(() => cubit.complete()).called(1);
    });

    testWidgets('should not call complete when next is tapped before the last '
        'slide', (tester) async {
      await pumpOnboarding(
        tester,
        state: const OnboardingSuccess(pages: tPages, currentIndex: 0),
      );
      await tester.pump(const Duration(seconds: 2));

      await tester.tap(find.byKey(OnboardingLayoutKeys.nextButton));

      verifyNever(() => cubit.complete());
    });
  });
}
