/// `AppLogger` tags. A tag is a greppable identifier, not a message, so it
/// lives here rather than next to the log call (ARCH-10).
abstract final class LogTags {
  static const String auth = 'AUTH';
}
