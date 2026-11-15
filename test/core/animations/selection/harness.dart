import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/theme/app_theme.dart';

/// Pumps [child] under the full Orbit theme (colour and text-style
/// extensions), media query and direction the selection widgets read, plus a
/// [Material] so chips can ripple — without a whole [MaterialApp].
Future<void> pumpSelection(
  WidgetTester tester,
  Widget child, {
  bool disableAnimations = false,
  TextDirection direction = TextDirection.ltr,
}) {
  return tester.pumpWidget(
    Theme(
      data: AppTheme.light,
      child: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: Directionality(
          textDirection: direction,
          child: Material(child: child),
        ),
      ),
    ),
  );
}
