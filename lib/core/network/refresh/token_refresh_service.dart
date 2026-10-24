/// Abstract contract for refreshing an expired access token.
abstract interface class TokenRefreshService {
  /// Calls the refresh endpoint using the stored refresh token.
  ///
  /// [capturedGeneration] is the session generation snapshot taken before the
  /// refresh was started. If the active generation changed during the network
  /// call (e.g. due to logout or account switch), the result is discarded.
  ///
  /// Returns the newly acquired access token string on success.
  ///
  /// Throws [SessionExpiredException] if the refresh token is missing or rejected (401/400).
  /// Throws [StaleSessionException] if the session generation changed while in flight.
  /// Throws [ServerErrorException] on malformed 200 or 5xx server errors.
  /// Throws [NetworkException] on connection timeouts or offline errors.
  Future<String> refresh({required int capturedGeneration});
}
