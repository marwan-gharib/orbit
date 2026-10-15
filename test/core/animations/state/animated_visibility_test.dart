import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/animations/tokens/app_durations.dart';
import 'package:orbit/core/animations/state/animated_visibility.dart';

import 'harness.dart';

void main() {
  testWidgets('should mount the child when visible turns true', (tester) async {
    await pumpState(
      tester,
      const AnimatedVisibility(visible: false, child: Text('payload')),
    );
    expect(find.text('payload'), findsNothing);

    await pumpState(
      tester,
      const AnimatedVisibility(visible: true, child: Text('payload')),
    );
    await tester.pumpAndSettle();
    expect(find.text('payload'), findsOneWidget);
  });

  testWidgets('should remove the child from the tree when the hide finishes', (
    tester,
  ) async {
    await pumpState(
      tester,
      const AnimatedVisibility(visible: true, child: Text('payload')),
    );
    expect(find.text('payload'), findsOneWidget);

    await pumpState(
      tester,
      const AnimatedVisibility(visible: false, child: Text('payload')),
    );
    await tester.pump(AppDurations.normal ~/ 2);
    expect(find.text('payload'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('payload'), findsNothing);
  });

  testWidgets('should keep the child mounted but inert when maintainState '
      'is true', (tester) async {
    await pumpState(
      tester,
      const AnimatedVisibility(
        maintainState: true,
        visible: true,
        child: Text('payload'),
      ),
    );
    await pumpState(
      tester,
      const AnimatedVisibility(
        maintainState: true,
        visible: false,
        child: Text('payload'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('payload'), findsOneWidget);
    expect(
      find.ancestor(
        of: find.text('payload'),
        matching: find.byType(IgnorePointer),
      ),
      findsOneWidget,
    );
  });

  testWidgets('should fade the child out while it collapses', (tester) async {
    await pumpState(
      tester,
      const AnimatedVisibility(visible: true, child: Text('payload')),
    );
    await pumpState(
      tester,
      const AnimatedVisibility(visible: false, child: Text('payload')),
    );
    await tester.pump(AppDurations.normal ~/ 2);

    final opacity = tester
        .widget<FadeTransition>(find.byType(FadeTransition))
        .opacity
        .value;

    expect(opacity, greaterThan(0.0));
    expect(opacity, lessThan(1.0));
  });

  testWidgets('should show the child immediately when animations are '
      'disabled', (tester) async {
    await pumpState(
      tester,
      const AnimatedVisibility(visible: false, child: Text('payload')),
      disableAnimations: true,
    );
    await pumpState(
      tester,
      const AnimatedVisibility(visible: true, child: Text('payload')),
      disableAnimations: true,
    );

    expect(find.text('payload'), findsOneWidget);
    expect(tester.getSize(find.byType(SizeTransition)).height, greaterThan(0));
  });
}
