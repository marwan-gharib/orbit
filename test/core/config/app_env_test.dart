import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/config/app_env.dart';
import 'package:orbit/core/constants/app_consts.dart';

void main() {
  tearDown(() {
    AppEnv.reset();
    dotenv.testLoad();
  });

  test('should expose the base url when tests seed it directly', () {
    AppEnv.debugSeed(baseUrl: 'https://test.local');

    expect(AppEnv.isLoaded, isTrue);
    expect(AppEnv.baseUrl, 'https://test.local');
  });

  test(
    'should throw when the base url is read before the environment loads',
    () {
      expect(() => AppEnv.baseUrl, throwsStateError);
    },
  );

  group('load', () {
    test('should read the base url from a seeded environment', () async {
      dotenv.testLoad(
        fileInput: '${AppConsts.envBaseUrlKey}=https://test.local',
      );

      await AppEnv.load();

      expect(AppEnv.isLoaded, isTrue);
      expect(AppEnv.baseUrl, 'https://test.local');
    });

    test('should throw when the base url key is missing', () async {
      dotenv.testLoad(fileInput: 'SOME_OTHER_KEY=1');

      await expectLater(AppEnv.load(), throwsStateError);

      expect(AppEnv.isLoaded, isFalse);
    });

    test('should throw when the base url value is blank', () async {
      dotenv.testLoad(fileInput: '${AppConsts.envBaseUrlKey}=   ');

      await expectLater(AppEnv.load(), throwsStateError);

      expect(AppEnv.isLoaded, isFalse);
    });
  });
}
