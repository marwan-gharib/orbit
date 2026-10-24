import 'package:dio/dio.dart';

import 'package:orbit/core/errors/exceptions.dart';

/// Builds [NetworkException]s and decides why a call failed. Extracted from
/// `DioErrorHandler` so classification and network-failure construction stay
/// readable on their own.
abstract final class NetworkExceptionFactory {
  /// `requestTimeout` is the one reason whose exception also carries a status
  /// code, so callers can treat a client-side timeout like an HTTP 408.
  static NetworkException of(
    NetworkErrorReason reason,
    String technical,
    Object? cause,
    StackTrace? st,
  ) => NetworkException(
    reason: reason,
    message: technical,
    statusCode: reason == NetworkErrorReason.requestTimeout ? 408 : null,
    cause: cause,
    stackTrace: st,
  );

  /// `SocketException` is not always "no internet": only DNS/network-down
  /// wording counts as offline; refused/reset/closed mean the server is the
  /// problem. Walks the cause chain because Dio wraps the original error.
  static NetworkErrorReason reasonOf(Object? error) {
    Object? node = error;
    for (var hops = 0; node != null && hops < 8; hops++) {
      final text = node.toString().toLowerCase();
      if (_offlineMarkers.any(text.contains)) {
        return NetworkErrorReason.noInternet;
      }
      node = node is DioException ? node.error : null;
    }
    return NetworkErrorReason.serverUnreachable;
  }

  static const List<String> _offlineMarkers = [
    'failed host lookup',
    'network is unreachable',
    'no address associated with hostname',
    'no such host is known',
    'nodename nor servname provided',
  ];
}
