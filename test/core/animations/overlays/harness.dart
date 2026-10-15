import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps [host] inside a real [MaterialApp] — dialogs, sheets, snackbars and
/// menus need the navigator, the scaffold messenger and the material
/// localizations — carrying the reduce-motion flag the overlay helpers read.
Future<void> pumpOverlays(
  WidgetTester tester,
  Widget host, {
  bool disableAnimations = false,
  TextDirection direction = TextDirection.ltr,
}) {
  return tester.pumpWidget(
    Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(disableAnimations: disableAnimations),
        child: MaterialApp(
          home: Directionality(
            textDirection: direction,
            child: Scaffold(body: host),
          ),
        ),
      ),
    ),
  );
}
