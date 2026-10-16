import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orbit/core/di/injection_container.dart';
import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/router/app_router_routes.dart';
import 'package:orbit/core/router/route_paths.dart';
import 'package:orbit/core/theme/app_theme.dart';
import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/core/widgets/error_state.dart';
import 'package:orbit/features/splash/domain/entities/splash_state_entity.dart';
import 'package:orbit/features/splash/domain/usecases/check_startup_status_usecase.dart';
import 'package:orbit/features/splash/presentation/constants/splash_animation_constants.dart';
import 'package:orbit/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:orbit/features/splash/presentation/screens/splash_screen.dart';
import 'package:orbit/features/splash/presentation/widgets/splash_composition.dart';

class MockCheckStartupStatusUseCase extends Mock
    implements CheckStartupStatusUseCase {}

// Labels of the placeholder destinations in AppRouterRoutes (the widgets are
// private), kept as constants so no test hunts a raw string.
const String loginPlaceholderText = 'Login (Placeholder)';
const String homePlaceholderText = 'Home (Placeholder)';

// Startup statuses from the routing decision table (FEATURE.md §7).
const SplashStateEntity noAuthOnboardingSeen = SplashStateEntity(
  hasAuthToken: false,
  onboardingSeen: true,
);
const SplashStateEntity authOnboardingSeen = SplashStateEntity(
  hasAuthToken: true,
  onboardingSeen: true,
);

void main() {
  /// Pumps the real route table with [SplashScreen] at its initial location
  /// and a real [SplashCubit] over a mocked usecase, so `goNamed` navigations
  /// resolve against the routes the app ships with.
  Future<void> pumpSplash(
    WidgetTester tester, {
    SplashStateEntity startupStatus = noAuthOnboardingSeen,
    bool disableAnimations = false,
    Failure? startupFailure,
  }) async {
    final useCase = MockCheckStartupStatusUseCase();
    final ApiResult<SplashStateEntity> startupResult = startupFailure == null
        ? Success(startupStatus)
        : ResultFailure(startupFailure);
    when(() => useCase()).thenAnswer((_) async => startupResult);
    final cubit = SplashCubit(useCase);
    // The route table provides the cubit from GetIt (as the app does via
    // initDependencies), so the test registers its mocked-usecase instance
    // there for the life of the test.
    getIt.registerSingleton<SplashCubit>(cubit);
    addTearDown(() => getIt.unregister<SplashCubit>());

    final router = GoRouter(
      initialLocation: RoutePaths.splash,
      routes: AppRouterRoutes.routes,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp.router(
          theme: AppTheme.light,
          routerConfig: router,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(disableAnimations: disableAnimations),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: child!,
            ),
          ),
        ),
      ),
    );
  }

  group('SplashScreen', () {
    testWidgets('should show animation composition when animations enabled', (
      tester,
    ) async {
      await pumpSplash(tester);
      await tester.pump();

      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(SplashComposition), findsOneWidget);
    });

    testWidgets(
      'should stay on splash while the animation runs when checks finish early',
      (tester) async {
        await pumpSplash(tester);

        await tester.pump(
          const Duration(
            milliseconds: SplashAnimationConstants.totalDurationMs ~/ 2,
          ),
        );

        expect(find.byType(SplashScreen), findsOneWidget);
        expect(find.text(loginPlaceholderText), findsNothing);
      },
    );

    testWidgets(
      'should navigate to login when animation completes and checks pass',
      (tester) async {
        await pumpSplash(tester);

        await tester.pumpAndSettle();

        expect(find.byType(SplashScreen), findsNothing);
        expect(find.text(loginPlaceholderText), findsOneWidget);
      },
    );

    testWidgets(
      'should navigate to home when startup status has auth and onboarding seen',
      (tester) async {
        await pumpSplash(tester, startupStatus: authOnboardingSeen);

        await tester.pumpAndSettle();

        expect(find.byType(SplashScreen), findsNothing);
        expect(find.text(homePlaceholderText), findsOneWidget);
      },
    );

    testWidgets(
      'should show the localized failure text when the startup checks fail',
      (tester) async {
        await pumpSplash(
          tester,
          startupFailure: CacheFailure(message: 'Startup checks unavailable'),
        );
        await tester.pump();

        expect(find.byType(SplashScreen), findsOneWidget);
        expect(find.byType(SplashComposition), findsNothing);
        expect(find.byType(ErrorState), findsOneWidget);
        expect(find.text(t.errors.cache), findsOneWidget);

        // Unmount while the 4000ms animation is still running: dispose stops
        // the controller so no frame work outlives the test.
        await tester.pumpWidget(const SizedBox());
      },
    );

    testWidgets(
      'should show reduced motion fallback when animations disabled',
      (tester) async {
        await pumpSplash(tester, disableAnimations: true);
        await tester.pump();

        expect(find.byType(SplashComposition), findsNothing);
        expect(find.byType(Image), findsOneWidget);
        expect(find.text(t.splash.tagline), findsOneWidget);

        // Unmount: dispose must cancel the hold timer (UI-9), so nothing
        // outlives the test.
        await tester.pumpWidget(const SizedBox());
      },
    );

    testWidgets(
      'should navigate after the reduced motion delay when animations disabled',
      (tester) async {
        await pumpSplash(tester, disableAnimations: true);
        await tester.pump();

        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        expect(find.byType(SplashScreen), findsNothing);
        expect(find.text(loginPlaceholderText), findsOneWidget);
      },
    );
  });
}
