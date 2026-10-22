/// Client-agnostic HTTP contract. Implementations must return the decoded
/// response body and throw only `AppException` subtypes — never a raw
/// Dio/platform error.
abstract interface class BaseApiClient {
  /// [data] is a request body on GET, for the occasional API designed that
  /// way. Kept as an explicit parameter so switching such an endpoint to a
  /// query param or POST later happens in one place.
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Map<String, Object>? extra,
    Object? data,
  });

  Future<dynamic> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Map<String, Object>? extra,
  });

  Future<dynamic> put(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Map<String, Object>? extra,
  });

  Future<dynamic> patch(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Map<String, Object>? extra,
  });

  Future<dynamic> delete(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Map<String, Object>? extra,
  });
}
