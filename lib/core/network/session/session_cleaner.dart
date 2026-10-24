/// Core abstraction for completely cleaning the local user session.
///
/// Implemented by the auth feature and consumed by core network components
/// upon unrecoverable session expiry (e.g. refresh token rejected by backend).
/// This prevents core network classes from directly importing feature-level
/// data sources or cubits.
abstract interface class SessionCleaner {
  /// Deletes all authentication tokens, removes cached profile data, wipes
  /// pending signup records, and clears in-memory session states.
  Future<void> clearSession();
}
