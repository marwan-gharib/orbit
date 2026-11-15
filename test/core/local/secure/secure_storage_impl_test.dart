import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/constants/app_consts.dart';
import 'package:orbit/core/errors/exceptions.dart';
import 'package:orbit/core/local/secure/secure_storage_impl.dart';

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockSecureStorage storage;
  late SecureStorageImpl client;

  setUp(() {
    storage = _MockSecureStorage();
    client = SecureStorageImpl(storage);
  });

  group('SecureStorageImpl', () {
    test('should write and read back a value', () async {
      when(() => storage.write(key: AppConsts.accessTokenKey, value: 'tok-1'))
          .thenAnswer((_) async {});
      when(() => storage.read(key: AppConsts.accessTokenKey))
          .thenAnswer((_) async => 'tok-1');

      await client.write(AppConsts.accessTokenKey, 'tok-1');

      expect(await client.read(AppConsts.accessTokenKey), 'tok-1');
    });

    test('should report whether a key exists and delete it', () async {
      when(() => storage.containsKey(key: AppConsts.accessTokenKey))
          .thenAnswer((_) async => true);
      when(() => storage.delete(key: AppConsts.accessTokenKey))
          .thenAnswer((_) async {});

      expect(await client.containsKey(AppConsts.accessTokenKey), isTrue);

      await client.delete(AppConsts.accessTokenKey);

      verify(() => storage.delete(key: AppConsts.accessTokenKey)).called(1);
    });

    test('should wrap every failure in SecureStorageException', () async {
      when(() => storage.read(key: AppConsts.accessTokenKey))
          .thenThrow(Exception('locked'));
      when(() => storage.write(key: AppConsts.accessTokenKey, value: 'tok-1'))
          .thenThrow(Exception('locked'));
      when(() => storage.delete(key: AppConsts.accessTokenKey))
          .thenThrow(Exception('locked'));
      when(() => storage.containsKey(key: AppConsts.accessTokenKey))
          .thenThrow(Exception('locked'));
      when(() => storage.deleteAll()).thenThrow(Exception('locked'));

      await expectLater(
        client.read(AppConsts.accessTokenKey),
        throwsA(isA<SecureStorageException>()),
      );
      await expectLater(
        client.write(AppConsts.accessTokenKey, 'tok-1'),
        throwsA(isA<SecureStorageException>()),
      );
      await expectLater(
        client.delete(AppConsts.accessTokenKey),
        throwsA(isA<SecureStorageException>()),
      );
      await expectLater(
        client.containsKey(AppConsts.accessTokenKey),
        throwsA(isA<SecureStorageException>()),
      );
      await expectLater(
        client.deleteAll(),
        throwsA(isA<SecureStorageException>()),
      );
    });
  });
}
