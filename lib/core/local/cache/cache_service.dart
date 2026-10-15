/// Package-agnostic key/value cache contract, so the backing store can be
/// swapped without touching callers. Implementations must throw
/// `CacheException` for every failure, including unsupported value types.
abstract interface class CacheService {
  /// Reads [key] as [T]; `null` when absent. [T] must be a supported scalar
  /// type (see typed helpers).
  Future<T?> read<T>(String key);

  Future<void> write<T>(String key, T value);

  /// Removes [key]; a missing key is not an error.
  Future<void> delete(String key);

  Future<bool> contains(String key);

  Future<void> clear();

  Future<String?> readString(String key);

  Future<void> writeString(String key, String value);

  Future<bool?> readBool(String key);

  Future<void> writeBool(String key, bool value);

  Future<int?> readInt(String key);

  Future<void> writeInt(String key, int value);

  Future<double?> readDouble(String key);

  Future<void> writeDouble(String key, double value);

  Future<List<String>?> readStringList(String key);

  Future<void> writeStringList(String key, List<String> value);

  /// Decodes the JSON object stored under [key]; `null` when absent, and
  /// `CacheException` when the stored text is not a JSON object.
  Future<Map<String, dynamic>?> readJsonMap(String key);

  Future<void> writeJsonMap(String key, Map<String, dynamic> value);
}
