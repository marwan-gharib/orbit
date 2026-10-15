/// Hero tag strings (ARCH-10: values live in `core/constants/`, never inside
/// a widget).
abstract final class HeroTags {
  /// Namespace every tag produced by `AppHeroTag.of` starts with, so a
  /// feature's tag can never collide with the tag of a library widget that
  /// ships its own `Hero`.
  static const String prefix = 'orbit.hero.';
}
