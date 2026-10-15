import 'dart:convert';

import 'package:orbit/core/errors/exceptions.dart';
import 'package:orbit/core/local/cache/cache_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [CacheService] backed by SharedPreferences; the instance is injected so
/// DI containers and tests own its lifecycle. Every failure surfaces as
/// [CacheException].
final class SharedPreferencesService implements CacheService {
  SharedPreferencesService(this._prefs);

  /// Owns plugin setup so this class is the only importer of
  /// `shared_preferences` (ARCH-5).
  static Future<SharedPreferencesService> create() async =>
      SharedPreferencesService(await SharedPreferences.getInstance());

  final SharedPreferences _prefs;

  @override
  Future<T?> read<T>(String key) async {
    try {
      if (T == String) return _prefs.getString(key) as T?;
      if (T == bool) return _prefs.getBool(key) as T?;
      if (T == int) return _prefs.getInt(key) as T?;
      if (T == double) return _prefs.getDouble(key) as T?;
      if (T == List<String>) return _prefs.getStringList(key) as T?;
      throw CacheException(
        message: 'Reading cache values of type $T is not supported.',
      );
    } on CacheException {
      rethrow;
    } catch (e, st) {
      throw CacheException(
        message: 'Failed to read "$key" from the cache.',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> write<T>(String key, T value) async {
    try {
      final Future<bool> saved = switch (value) {
        final String v => _prefs.setString(key, v),
        final bool v => _prefs.setBool(key, v),
        final int v => _prefs.setInt(key, v),
        final double v => _prefs.setDouble(key, v),
        final List<String> v => _prefs.setStringList(key, v),
        _ => throw CacheException(
          message:
              'Writing cache values of type ${value.runtimeType} '
              'is not supported.',
        ),
      };
      if (!await saved) {
        throw CacheException(
          message: 'Failed to persist the value for "$key".',
        );
      }
    } on CacheException {
      rethrow;
    } catch (e, st) {
      throw CacheException(
        message: 'Failed to write "$key" to the cache.',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      await _prefs.remove(key);
    } catch (e, st) {
      throw CacheException(
        message: 'Failed to remove "$key" from the cache.',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<bool> contains(String key) async {
    try {
      return _prefs.containsKey(key);
    } catch (e, st) {
      throw CacheException(
        message: 'Failed to check for "$key" in the cache.',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _prefs.clear();
    } catch (e, st) {
      throw CacheException(
        message: 'Failed to clear the cache.',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<String?> readString(String key) => read<String>(key);

  @override
  Future<void> writeString(String key, String value) =>
      write<String>(key, value);

  @override
  Future<bool?> readBool(String key) => read<bool>(key);

  @override
  Future<void> writeBool(String key, bool value) => write<bool>(key, value);

  @override
  Future<int?> readInt(String key) => read<int>(key);

  @override
  Future<void> writeInt(String key, int value) => write<int>(key, value);

  @override
  Future<double?> readDouble(String key) => read<double>(key);

  @override
  Future<void> writeDouble(String key, double value) =>
      write<double>(key, value);

  @override
  Future<List<String>?> readStringList(String key) => read<List<String>>(key);

  @override
  Future<void> writeStringList(String key, List<String> value) =>
      write<List<String>>(key, value);

  @override
  Future<Map<String, dynamic>?> readJsonMap(String key) async {
    final raw = await readString(key);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      throw CacheException(
        message: 'The cached value for "$key" is not a JSON object.',
      );
    } on CacheException {
      rethrow;
    } catch (e, st) {
      throw CacheException(
        message: 'Failed to decode the cached JSON for "$key".',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> writeJsonMap(String key, Map<String, dynamic> value) async {
    await writeString(key, jsonEncode(value));
  }
}
