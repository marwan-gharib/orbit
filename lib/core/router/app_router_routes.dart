import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:orbit/core/animations/animations.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/router/route_names.dart';
import 'package:orbit/core/router/route_paths.dart';
import 'package:orbit/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:orbit/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:orbit/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:orbit/features/splash/presentation/screens/splash_screen.dart';

import '../di/injection_container.dart';

/// Holds the app's route table.
abstract final class AppRouterRoutes {
  static final List<RouteBase> routes = [
    // Splash screen - no transition (native splash handles entry)
    AppRoute.create(
      path: RoutePaths.splash,
      name: RouteNames.splash,
      transition: AppPageTransition.none,
      builder: (_, _) => BlocProvider(
        create: (context) => getIt<SplashCubit>(),
        child: const SplashScreen(),
      ),
    ),
    // Onboarding screen
    AppRoute.create(
      path: RoutePaths.onboarding,
      name: RouteNames.onboarding,
      transition: AppPageTransition.fadeThrough,
      builder: (_, _) => BlocProvider(
        create: (_) => getIt<OnboardingCubit>()..loadPages(),
        child: const OnboardingScreen(),
      ),
    ),
    // Placeholder login route
    AppRoute.create(
      path: RoutePaths.login,
      name: RouteNames.login,
      transition: AppPageTransition.fadeThrough,
      builder: (_, _) => const _LoginPlaceholder(),
    ),
    // Placeholder home route
    AppRoute.create(
      path: RoutePaths.home,
      name: RouteNames.home,
      transition: AppPageTransition.fadeThrough,
      builder: (_, _) => const _HomePlaceholder(),
    ),
  ];
}

/// Placeholder for login screen (to be implemented).
class _LoginPlaceholder extends StatelessWidget {
  const _LoginPlaceholder();

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Scaffold(
      appBar: AppBar(title: Text(t.app.loginPlaceholder.title)),
      body: Center(child: Text(t.app.loginPlaceholder.body)),
    );
  }
}

/// Placeholder for home screen (to be implemented).
class _HomePlaceholder extends StatelessWidget {
  const _HomePlaceholder();

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Scaffold(
      appBar: AppBar(title: Text(t.app.homePlaceholder.title)),
      body: Center(child: Text(t.app.homePlaceholder.body)),
    );
  }
}
