import 'package:flutter/foundation.dart';

/// Process-wide state for an account that was created but is still awaiting
/// approval.
///
/// The auth data layer keeps it in sync with the persisted copy, and the
/// router listens to it so the auth routes always agree on whether a pending
/// signup exists. It lives in memory only; storage remains the source of truth
/// across app launches.
class PendingSignupSession extends ChangeNotifier {
  String? _email;
  bool _registeredWithGoogle = false;

  /// Work email awaiting approval, or `null` when no signup is pending.
  String? get email => _email;

  /// Whether the pending account was created via Google SSO.
  bool get registeredWithGoogle => _registeredWithGoogle;

  bool get hasPendingSignup => _email != null;

  /// Starts (or replaces) the pending session for [email].
  void start(String email, {bool registeredWithGoogle = false}) {
    if (_email == email && _registeredWithGoogle == registeredWithGoogle) return;
    _email = email;
    _registeredWithGoogle = registeredWithGoogle;
    notifyListeners();
  }

  /// Ends the pending session (approved, rejected, or a cleared auth session).
  void clear() {
    if (_email == null && !_registeredWithGoogle) return;
    _email = null;
    _registeredWithGoogle = false;
    notifyListeners();
  }
}
