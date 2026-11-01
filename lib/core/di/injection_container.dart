import 'package:get_it/get_it.dart';

import 'package:orbit/core/di/auth_injection.dart';
import 'package:orbit/core/di/core_module.dart';
import 'package:orbit/core/di/customer_notes_injection.dart';
import 'package:orbit/core/di/interactions_injection.dart';
import 'package:orbit/core/di/onboarding_injection.dart';
import 'package:orbit/core/di/opportunities_injection.dart';
import 'package:orbit/core/di/splash_injection.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  await initCoreModule(getIt);
  await initSplashModule(getIt);
  await initOnboardingModule(getIt);
  await initAuthModule(getIt);
  await initInteractionsModule(getIt);
  await initCustomerNotesModule(getIt);
  await initOpportunitiesModule(getIt);
}
