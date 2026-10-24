import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:orbit/core/config/app_env.dart';
import 'package:orbit/core/di/injection_container.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/responsive/responsive_scope.dart';
import 'package:orbit/core/router/app_router.dart';
import 'package:orbit/core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppEnv.load();
  await initDependencies();
  // ResponsiveScope binds/configures the scaling engine before the first
  // build and rebuilds the app on resize, so theme text/spacing/radius scale.
  runApp(TranslationProvider(child: ResponsiveScope(child: const OrbitApp())));
}

class OrbitApp extends StatelessWidget {
  const OrbitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: context.t.app.title,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      locale: AppLocale.en.flutterLocale,
      routerConfig: AppRouter.router,
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: AppTheme.overlayStyle(Theme.of(context).brightness),
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
