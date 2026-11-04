import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:orbit/core/animations/animations.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/router/route_names.dart';
import 'package:orbit/core/router/route_paths.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';
import 'package:orbit/core/widgets/app_button.dart';
import 'package:orbit/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:orbit/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:orbit/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:orbit/features/splash/presentation/screens/splash_screen.dart';

import '../../features/auth/presentation/cubits/employee_status/employee_status_cubit.dart';
import '../../features/auth/presentation/cubits/google_sign_in/google_sign_in_cubit.dart';
import '../../features/auth/presentation/cubits/login/login_cubit.dart';
import '../../features/auth/presentation/cubits/signup/signup_cubit.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/pending_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/crm_shell/presentation/widgets/crm_shell.dart';
import '../../features/opportunities/presentation/blocs/opportunities_list/opportunities_list_bloc.dart';
import '../../features/opportunities/presentation/blocs/opportunities_list/opportunities_list_event.dart';
import '../../features/opportunities/presentation/widgets/opportunity_detail_page.dart';
import '../di/injection_container.dart';
import 'pending_signup_session.dart';

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
    // Login screen
    AppRoute.create(
      path: RoutePaths.login,
      name: RouteNames.login,
      transition: AppPageTransition.fadeThrough,
      builder: (_, _) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => getIt<LoginCubit>()),
          BlocProvider(create: (_) => getIt<GoogleSignInCubit>()),
        ],
        child: const LoginScreen(),
      ),
    ),
    // Sign-up screen
    AppRoute.create(
      path: RoutePaths.signup,
      name: RouteNames.signup,
      transition: AppPageTransition.fadeThrough,
      builder: (_, _) => BlocProvider(
        create: (_) => getIt<SignupCubit>(),
        child: const SignupScreen(),
      ),
    ),
    // Pending-approval screen
    AppRoute.create(
      path: RoutePaths.pending,
      name: RouteNames.pending,
      transition: AppPageTransition.fadeThrough,
      builder: (_, _) => BlocProvider(
        create: (_) => getIt<EmployeeStatusCubit>(),
        child: PendingScreen(session: getIt<PendingSignupSession>()),
      ),
    ),
    // Home route with CRM entry
    AppRoute.create(
      path: RoutePaths.home,
      name: RouteNames.home,
      transition: AppPageTransition.fadeThrough,
      builder: (_, _) => const _HomeScreen(),
    ),
    // CRM shell - shared axis horizontal for tab switches
    AppRoute.create(
      path: RoutePaths.crm,
      name: RouteNames.crm,
      transition: AppPageTransition.sharedAxisHorizontal,
      builder: (_, _) => BlocProvider(
        create: (_) =>
            getIt<OpportunitiesListBloc>()..add(OpportunitiesListStarted()),
        child: CrmShell(),
      ),
    ),
    // CRM opportunity detail - container transform for Hero flight
    AppRoute.create(
      path: RoutePaths.crmOpportunityDetails,
      name: RouteNames.crmOpportunityDetails,
      transition: AppPageTransition.containerTransform,
      builder: (context, state) {
        final idString = state.pathParameters['id']!;
        final id = int.tryParse(idString);
        if (id == null) {
          return const _CrmInvalidIdPage();
        }
        return OpportunityDetailPage(opportunityId: id);
      },
    ),
  ];
}

/// Home screen with CRM entry.
class _HomeScreen extends StatelessWidget {
  const _HomeScreen();

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Scaffold(
      appBar: AppBar(title: Text(t.home.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton.icon(
              icon: const Icon(Icons.people_alt_rounded),
              label: Text(t.crm.title),
              onPressed: () => context.push(RoutePaths.crm),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Invalid ID page for CRM opportunity detail.
class _CrmInvalidIdPage extends StatelessWidget {
  const _CrmInvalidIdPage();

  @override
  Widget build(BuildContext context) {
    final labels = context.t.crm.common;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: AppSpacing.page,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: context.colors.error,
              ),
              SizedBox(height: AppSpacing.md),
              Text(labels.notFound, style: context.textStyles.titleMedium),
              SizedBox(height: AppSpacing.sm),
              Text(labels.invalidId, style: context.textStyles.bodyMedium),
              SizedBox(height: AppSpacing.lg),
              AppButton.filled(
                label: labels.back,
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
