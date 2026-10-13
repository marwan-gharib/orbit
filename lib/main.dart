import 'package:flutter/material.dart';
import 'package:orbit/core/di/injection_container.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/router/app_router.dart';
import 'package:orbit/core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(TranslationProvider(child: const OrbitApp()));
}

class OrbitApp extends StatelessWidget {
  const OrbitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: context.t.app.title,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      locale: AppLocale.en.flutterLocale,
      routerConfig: AppRouter.router,
    );
  }
}
