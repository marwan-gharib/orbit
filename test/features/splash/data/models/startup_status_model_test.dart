import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/features/splash/data/models/startup_status_model.dart';
import 'package:orbit/features/splash/domain/entities/splash_state_entity.dart';

void main() {
  group('StartupStatusModel', () {
    const tModel = StartupStatusModel(
      hasAuthToken: true,
      onboardingSeen: false,
    );

    const tEntity = SplashStateEntity(
      hasAuthToken: true,
      onboardingSeen: false,
    );

    test('toEntity returns correct entity', () {
      expect(tModel.toEntity(), equals(tEntity));
    });

    test('toEntity preserves all fields', () {
      final entity = tModel.toEntity();
      expect(entity.hasAuthToken, tModel.hasAuthToken);
      expect(entity.onboardingSeen, tModel.onboardingSeen);
    });
  });
}
