import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/animations/state/app_animated_switcher.dart';

import 'harness.dart';

void main() {
  testWidgets(
    'should cross-fade to the new child when the child is replaced by a '
    'child with another key',
    (tester) async {
      await pumpState(
        tester,
        const AppAnimatedSwitcher(
          child: Text('loading', key: ValueKey('loading')),
        ),
      );
      await pumpState(
        tester,
        const AppAnimatedSwitcher(
          child: Text('content', key: ValueKey('content')),
        ),
      );

      expect(find.text('loading'), findsOneWidget);
      expect(find.text('content'), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('loading'), findsNothing);
      expect(find.text('content'), findsOneWidget);
    },
  );

  testWidgets('should update in place when the child keeps its key', (
    tester,
  ) async {
    await pumpState(
      tester,
      const AppAnimatedSwitcher(child: Text('loading', key: ValueKey('state'))),
    );
    await pumpState(
      tester,
      const AppAnimatedSwitcher(child: Text('content', key: ValueKey('state'))),
    );
    await tester.pump();

    expect(find.text('loading'), findsNothing);
    expect(find.text('content'), findsOneWidget);
  });

  testWidgets('should ignore taps on the exiting child while it fades out', (
    tester,
  ) async {
    await pumpState(
      tester,
      const AppAnimatedSwitcher(
        child: Text('loading', key: ValueKey('loading')),
      ),
    );
    await pumpState(
      tester,
      const AppAnimatedSwitcher(
        child: Text('content', key: ValueKey('content')),
      ),
    );

    expect(
      find.ancestor(
        of: find.text('loading'),
        matching: find.byType(IgnorePointer),
      ),
      findsOneWidget,
    );
  });

  testWidgets('should render only the new child when animations are disabled', (
    tester,
  ) async {
    await pumpState(
      tester,
      const AppAnimatedSwitcher(
        child: Text('loading', key: ValueKey('loading')),
      ),
      disableAnimations: true,
    );
    await pumpState(
      tester,
      const AppAnimatedSwitcher(
        child: Text('content', key: ValueKey('content')),
      ),
      disableAnimations: true,
    );

    expect(find.text('loading'), findsNothing);
    expect(find.text('content'), findsOneWidget);
    expect(find.byType(AnimatedSwitcher), findsNothing);
  });
}
