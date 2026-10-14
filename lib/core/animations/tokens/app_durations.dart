/// Duration tokens for every animation in Orbit.
///
/// Widgets never hardcode a [Duration]; they read it from here so the motion
/// profile can be retuned in one place. Speed profile: productivity app,
/// entrances and feedback live between 150ms and 300ms.
abstract final class AppDurations {
  /// Micro feedback: presses, toggles, focus and hover changes.
  static const Duration fast = Duration(milliseconds: 150);

  /// Default for entrances, fades, slides and route transitions.
  static const Duration normal = Duration(milliseconds: 300);

  /// Emphasised motion. Use sparingly; never inside lists.
  static const Duration slow = Duration(milliseconds: 500);

  /// Gap that starts each item of a staggered entrance after the previous one.
  static const Duration stagger = Duration(milliseconds: 50);

  /// One full sweep of a shimmer band across a skeleton screen. Loading loops
  /// are exempt from the 150-300ms profile: they repeat in the background and
  /// must stay slow enough to not pull focus.
  static const Duration shimmer = Duration(milliseconds: 1500);

  /// One leg of a pulsing placeholder's fade; `reverse: true` doubles the
  /// visible cycle. Same loading-loop exemption as [shimmer].
  static const Duration pulse = Duration(milliseconds: 800);

  /// One full travel of an indeterminate progress segment across its track.
  /// Same loading-loop exemption as [shimmer].
  static const Duration indeterminate = Duration(milliseconds: 1200);

  /// How long a transient message (`AppSnackbar`) stays on screen before it
  /// auto-dismisses. This is reading time, not motion: the one hold in this
  /// file that outlives the speed profile.
  static const Duration messageVisible = Duration(seconds: 4);
}
