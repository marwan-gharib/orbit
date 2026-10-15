/// Font families (ARCH-10: the only place a font-name literal may live).
abstract final class Fonts {
  /// Single switch for the app's font, applied to every text style by
  /// `AppTheme` — supports Arabic + English once a shared family ships.
  ///
  /// Placeholder: no font is registered under `fonts:` in `pubspec.yaml` yet
  /// (H-1), so `null` keeps Flutter's default. Set the family name here after
  /// adding the font files; nothing else needs to change.
  static const String? family = null;
}
