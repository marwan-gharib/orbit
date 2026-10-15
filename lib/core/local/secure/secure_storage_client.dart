/// Package-agnostic secret-storage contract; implementations must throw
/// [SecureStorageException] for every failure.
abstract interface class SecureStorageClient {
  /// Returns the secret stored under [key], or `null` when absent.
  Future<String?> read(String key);

  Future<void> write(String key, String value);

  /// Removes [key]; a missing key is not an error.
  Future<void> delete(String key);

  Future<bool> containsKey(String key);

  Future<void> deleteAll();
}
