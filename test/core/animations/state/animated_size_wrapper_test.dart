import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/animations/tokens/app_durations.dart';
import 'package:orbit/core/animations/state/animated_size_wrapper.dart';

import 'harness.dart';

void main() {
  Widget wrapped(double height) => Center(
    child: AnimatedSizeWrapper(child: SizedBox(width: 120, height: height)),
  );

  testWidgets('should animate to the new height when the child resizes', (
    tester,
  ) async {
    await pumpState(tester, wrapped(100));
    expect(tester.getSize(find.byType(AnimatedSizeWrapper)).height, 100);

    await pumpState(tester, wrapped(300));
    await tester.pump(AppDurations.normal ~/ 2);
    final midway = tester.getSize(find.byType(AnimatedSizeWrapper)).height;
    expect(midway, greaterThan(100));
    expect(midway, lessThan(300));

    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(AnimatedSizeWrapper)).height, 300);
  });

  testWidgets(
    'should apply the new height immediately when animations are disabled',
    (tester) async {
      await pumpState(tester, wrapped(100), disableAnimations: true);
      await pumpState(tester, wrapped(300), disableAnimations: true);

      expect(tester.getSize(find.byType(AnimatedSizeWrapper)).height, 300);
      expect(find.byType(AnimatedSize), findsNothing);
    },
  );
}
