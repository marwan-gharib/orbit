import 'package:flutter/services.dart' show HapticFeedback;

/// Which impact a feedback widget plays on interaction.
enum HapticType {
  /// No haptic.
  none,

  /// Light tick: subtle confirmations (presses, selections).
  light,

  /// Medium impact: state changes the user should notice.
  medium,

  /// Selection tick: repeating value changes (pickers, segmented controls).
  selection,
}

/// Static wrapper around [HapticFeedback] with a global kill switch.
///
/// Every haptic in Orbit goes through this class, so a single flag silences
/// them all (e.g. a settings toggle or tests):
///
/// ```dart
/// AppHaptics.enabled = false; // silence everything
/// AppHaptics.light();         // no-op while disabled
/// ```
///
/// Haptics are not animations: `MediaQuery.disableAnimations` does not
/// suppress them here; each call site opts in explicitly.
abstract final class AppHaptics {
  /// Global switch for every haptic in the app.
  static bool enabled = true;

  /// Subtle tick for small confirmations.
  static void light() => _fire(HapticFeedback.lightImpact);

  /// Noticeable impact for state changes.
  static void medium() => _fire(HapticFeedback.mediumImpact);

  /// Strong impact; use sparingly.
  static void heavy() => _fire(HapticFeedback.heavyImpact);

  /// Selection tick for repeating value changes.
  static void selection() => _fire(HapticFeedback.selectionClick);

  /// Distinct buzz for errors and failures (shake, validation).
  static void error() => _fire(HapticFeedback.vibrate);

  /// Plays [type]; [HapticType.none] is a no-op.
  static void play(HapticType type) => switch (type) {
    HapticType.none => null,
    HapticType.light => light(),
    HapticType.medium => medium(),
    HapticType.selection => selection(),
  };

  static void _fire(Future<void> Function() impact) {
    if (enabled) impact();
  }
}
