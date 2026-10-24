import 'package:flutter/foundation.dart';

/// Core signal emitting session invalidation events to listeners (such as
/// [GoRouter] via `Listenable.merge`) and tracking session generation
/// counters to guard against logout/re-login race conditions.
final class SessionExpiredNotifier extends ChangeNotifier {
  bool _isExpired = false;
  int _sessionGeneration = 0;

  /// Whether the session was terminally revoked or expired.
  bool get isExpired => _isExpired;

  /// Monotonically increasing counter incremented on every session change
  /// (logout, session clearance, expired signal, or new sign-in).
  int get currentGeneration => _sessionGeneration;

  /// Signals that the session has terminally expired.
  void signalExpired() {
    if (_isExpired) return;
    _isExpired = true;
    _sessionGeneration++;
    notifyListeners();
  }

  /// Resets the expired status (e.g. after a new user signs in).
  void reset() {
    if (!_isExpired) return;
    _isExpired = false;
    _sessionGeneration++;
    notifyListeners();
  }

  /// Increments the session generation counter without altering [isExpired].
  ///
  /// Called when the active session is cleared (e.g. voluntary logout) to
  /// invalidate any in-flight token refresh requests.
  void incrementGeneration() {
    _sessionGeneration++;
  }
}
