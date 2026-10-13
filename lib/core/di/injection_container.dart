import 'package:get_it/get_it.dart';

import 'package:orbit/core/di/core_module.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  await initCoreModule(getIt);
}
