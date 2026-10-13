import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:orbit/core/errors/exceptions.dart';
import 'package:orbit/core/local/secure/secure_storage_client.dart';

/// [SecureStorageClient] backed by flutter_secure_storage. Android uses the
/// plugin's defaults (AES-GCM + RSA-OAEP KeyStore backing); iOS uses
/// `first_unlock` accessibility so background refresh can read the token
/// after a reboot. Every failure becomes [SecureStorageException].
final class SecureStorageImpl implements SecureStorageClient {
  /// Creates a client over [storage], or a default-configured one when
  /// omitted.
  SecureStorageImpl([FlutterSecureStorage? storage])
    : _storage =
          storage ??
          const FlutterSecureStorage(
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock,
            ),
          );

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e, st) {
      throw SecureStorageException(
        message: 'Failed to read "$key" from secure storage.',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e, st) {
      throw SecureStorageException(
        message: 'Failed to write "$key" to secure storage.',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e, st) {
      throw SecureStorageException(
        message: 'Failed to delete "$key" from secure storage.',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e, st) {
      throw SecureStorageException(
        message: 'Failed to check for "$key" in secure storage.',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (e, st) {
      throw SecureStorageException(
        message: 'Failed to clear secure storage.',
        cause: e,
        stackTrace: st,
      );
    }
  }
}
