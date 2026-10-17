/// The 16 placeholder hex values baked into the onboarding illustration SVGs
/// (one per theme token). The SVGs are not edited by hand: a `ColorMapper`
/// replaces every value with the active theme's token at render time, so this
/// file and `assets/svgs/onboarding/README.md` are the single source of the
/// mapping. `surface` and `onColor` are deliberately separate keys: glyphs
/// drawn on colored fills must stay legible when both are mapped in dark mode.
abstract final class OnboardingSvgPalette {
  static const int surface = 0xFEFEFE;
  static const int onColor = 0xFFFFFF;
  static const int subtleSurface = 0xF7F8F9;
  static const int border = 0xDEDFE0;
  static const int borderStrong = 0xC6C6C7;
  static const int muted = 0x949595;
  static const int primary = 0x2373F4;
  static const int primarySoft = 0xBBD4FC;
  static const int primaryContainer = 0xE9F1FE;
  static const int secondary = 0x112E81;
  static const int success = 0x16A34A;
  static const int successSoft = 0xB7E2C7;
  static const int successContainer = 0xE8F6ED;
  static const int warning = 0xD97706;
  static const int warningContainer = 0xFBF1E6;
  static const int error = 0xDC2626;

  /// Every key, in [colorFor] resolution order. Used by the mapper and by the
  /// tests that scan the SVG files against this set.
  static const List<int> all = <int>[
    surface,
    onColor,
    subtleSurface,
    border,
    borderStrong,
    muted,
    primary,
    primarySoft,
    primaryContainer,
    secondary,
    success,
    successSoft,
    successContainer,
    warning,
    warningContainer,
    error,
  ];
}
