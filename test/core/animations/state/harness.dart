import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps [child] under the theme, media query and text direction the state
/// widgets read — plus a [Material] so [InkWell] headers can ripple — without
/// pulling in a whole [MaterialApp].
Future<void> pumpState(
  WidgetTester tester,
  Widget child, {
  bool disableAnimations = false,
  TextDirection direction = TextDirection.ltr,
}) {
  return tester.pumpWidget(
    Theme(
      data: ThemeData(),
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
