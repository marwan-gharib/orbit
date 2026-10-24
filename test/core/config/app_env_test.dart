import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/config/app_env.dart';
import 'package:orbit/core/constants/app_consts.dart';

void main() {
  tearDown(() {
    AppEnv.reset();
    dotenv.testLoad();
  });

  test('should expose values when tests seed them directly', () {
    AppEnv.debugSeed(
      baseUrl: 'https://test.local',
      googleServerClientId: 'test-google-client-id',
    );

    expect(AppEnv.isLoaded, isTrue);
    expect(AppEnv.baseUrl, 'https://test.local');
    expect(AppEnv.googleServerClientId, 'test-google-client-id');
  });

  test(
    'should throw when values are read before the environment loads',
    () {
      expect(() => AppEnv.baseUrl, throwsStateError);
      expect(() => AppEnv.googleServerClientId, throwsStateError);
    },
  );

  group('load', () {
    test('should read values from a seeded environment', () async {
      dotenv.testLoad(
        fileInput:
            '${AppConsts.envBaseUrlKey}=https://test.local\n'
            '${AppConsts.envGoogleServerClientIdKey}=test-google-client-id',
      );

      await AppEnv.load();

      expect(AppEnv.isLoaded, isTrue);
      expect(AppEnv.baseUrl, 'https://test.local');
      expect(AppEnv.googleServerClientId, 'test-google-client-id');
    });

    test('should throw when the base url key is missing', () async {
      dotenv.testLoad(
        fileInput: '${AppConsts.envGoogleServerClientIdKey}=test-google-client-id',
      );

      await expectLater(AppEnv.load(), throwsStateError);

      expect(AppEnv.isLoaded, isFalse);
    });

    test('should throw when the google client id key is missing', () async {
      dotenv.testLoad(
        fileInput: '${AppConsts.envBaseUrlKey}=https://test.local',
      );

      await expectLater(AppEnv.load(), throwsStateError);

      expect(AppEnv.isLoaded, isFalse);
    });

    test('should throw when the base url value is blank', () async {
      dotenv.testLoad(
        fileInput:
            '${AppConsts.envBaseUrlKey}=   \n'
            '${AppConsts.envGoogleServerClientIdKey}=test-google-client-id',
      );

      await expectLater(AppEnv.load(), throwsStateError);

      expect(AppEnv.isLoaded, isFalse);
    });

    test('should throw when the google client id value is blank', () async {
      dotenv.testLoad(
        fileInput:
            '${AppConsts.envBaseUrlKey}=https://test.local\n'
            '${AppConsts.envGoogleServerClientIdKey}=   ',
      );

      await expectLater(AppEnv.load(), throwsStateError);

      expect(AppEnv.isLoaded, isFalse);
    });
  });
}
