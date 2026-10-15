import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps [child] with the [MediaQuery] and [Directionality] the animation
/// widgets depend on, without pulling in a whole `MaterialApp`.
Future<void> pumpAnimations(
  WidgetTester tester,
  Widget child, {
  bool disableAnimations = false,
  TextDirection direction = TextDirection.ltr,
}) {
  return tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: Directionality(textDirection: direction, child: child),
    ),
  );
}
