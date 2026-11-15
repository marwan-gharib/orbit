import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:orbit/core/errors/exceptions.dart';
import 'package:orbit/core/local/cache/shared_preferences_service.dart';

/// Fixture keys local to this test: production never uses them, they only
/// exercise the service's key handling.
const _kString = 'test_string';
const _kBool = 'test_bool';
const _kInt = 'test_int';
const _kDouble = 'test_double';
const _kList = 'test_list';
const _kJson = 'test_json';
const _kRaw = 'test_raw';
const _kFirst = 'test_first';
const _kSecond = 'test_second';
const _kMissing = 'test_missing';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferencesService cache;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    cache = SharedPreferencesService(await SharedPreferences.getInstance());
  });

  group('SharedPreferencesService', () {
    test('should write and read back every supported type', () async {
      await cache.writeString(_kString, 'v');
      await cache.writeBool(_kBool, true);
      await cache.writeInt(_kInt, 7);
      await cache.writeDouble(_kDouble, 2.5);
      await cache.writeStringList(_kList, ['a', 'b']);

      expect(await cache.readString(_kString), 'v');
      expect(await cache.readBool(_kBool), isTrue);
      expect(await cache.readInt(_kInt), 7);
      expect(await cache.readDouble(_kDouble), 2.5);
      expect(await cache.readStringList(_kList), ['a', 'b']);
      expect(await cache.contains(_kString), isTrue);
    });

    test('should round-trip a JSON map', () async {
      await cache.writeJsonMap(_kJson, {'page': 1, 'title': 'ERP'});

      expect(await cache.readJsonMap(_kJson), {'page': 1, 'title': 'ERP'});
    });

    test('should return null for a missing key', () async {
      expect(await cache.readString(_kMissing), isNull);
      expect(await cache.readJsonMap(_kMissing), isNull);
      expect(await cache.contains(_kMissing), isFalse);
    });

    test('should reject unsupported types with a CacheException', () async {
      await expectLater(
        cache.write(_kJson, {'a': 1}),
        throwsA(isA<CacheException>()),
      );
      await expectLater(
        cache.read<Map<String, dynamic>>(_kJson),
        throwsA(isA<CacheException>()),
      );
    });

    test('should fail to decode a non-object JSON value', () async {
      await cache.writeString(_kRaw, '[1, 2]');

      await expectLater(
        cache.readJsonMap(_kRaw),
        throwsA(isA<CacheException>()),
      );
    });

    test('should delete one key and clear everything', () async {
      await cache.writeString(_kFirst, '1');
      await cache.writeString(_kSecond, '2');

      await cache.delete(_kFirst);
      expect(await cache.contains(_kFirst), isFalse);
      expect(await cache.readString(_kSecond), '2');

      await cache.clear();
      expect(await cache.contains(_kSecond), isFalse);
    });
  });
}
