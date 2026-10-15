import 'package:flutter/material.dart';

/// One-liner accessors for ambient [BuildContext] state (theme, media query,
/// focus). Note: `context.colors` / `context.textStyles` live next to their
/// extension classes in `lib/core/theme/extensions/`.
extension AppContext on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorScheme get colorScheme => theme.colorScheme;

  TextTheme get textTheme => theme.textTheme;

  bool get isDark => theme.brightness == Brightness.dark;

  MediaQueryData get mediaQuery => MediaQuery.of(this);

  Size get screenSize => MediaQuery.sizeOf(this);

  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this);

  EdgeInsets get padding => MediaQuery.paddingOf(this);

  bool get isLandscape =>
      MediaQuery.orientationOf(this) == Orientation.landscape;
}
