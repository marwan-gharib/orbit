import 'package:go_router/go_router.dart';

import 'package:orbit/core/router/app_router_routes.dart';

/// Wires the app's router configuration, guards and navigation entry point.
/// The app roots at [router] (NAV-1); no screen is ever pushed with
/// `Navigator`.
abstract final class AppRouter {
  static final GoRouter router = GoRouter(routes: AppRouterRoutes.routes);
}
