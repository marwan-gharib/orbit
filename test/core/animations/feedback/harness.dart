import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps [child] with the [MediaQuery] and [Directionality] the feedback
/// widgets depend on, without pulling in a whole `MaterialApp`.
Future<void> pumpFeedback(
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

/// Records the payload of every haptic fired while the test runs; restored
/// automatically on teardown. All haptics travel as `HapticFeedback.vibrate`
/// in this Flutter version — the impact type rides in the call arguments.
void recordHapticCalls(WidgetTester tester, List<String?> calls) {
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      calls.add(call.arguments as String?);
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );
}
