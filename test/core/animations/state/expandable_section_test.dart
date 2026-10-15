import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/animations/state/expandable_section.dart';
import 'package:orbit/core/animations/tokens/app_animation_constants.dart';

import 'harness.dart';

void main() {
  double arrowTurns(WidgetTester tester) => tester
      .widget<RotationTransition>(find.byType(RotationTransition))
      .turns
      .value;

  testWidgets('should start without a body when collapsed initially', (
    tester,
  ) async {
    await pumpState(
      tester,
      const ExpandableSection(header: Text('header'), body: Text('body')),
    );

    expect(find.text('header'), findsOneWidget);
    expect(find.text('body'), findsNothing);
  });

  testWidgets('should reveal then hide the body when the header is tapped in '
      'uncontrolled mode', (tester) async {
    await pumpState(
      tester,
      const ExpandableSection(header: Text('header'), body: Text('body')),
    );

    await tester.tap(find.text('header'));
    await tester.pumpAndSettle();
    expect(find.text('body'), findsOneWidget);

    await tester.tap(find.text('header'));
    await tester.pumpAndSettle();
    expect(find.text('body'), findsNothing);
  });

  testWidgets('should keep the body mounted while collapsed when '
      'maintainState is true', (tester) async {
    await pumpState(
      tester,
      const ExpandableSection(
        maintainState: true,
        header: Text('header'),
        body: Text('body'),
      ),
    );

    await tester.tap(find.text('header'));
    await tester.pumpAndSettle();
    expect(find.text('body'), findsOneWidget);

    await tester.tap(find.text('header'));
    await tester.pumpAndSettle();
    expect(find.text('body'), findsOneWidget);
  });

  testWidgets('should follow the prop and report taps in controlled mode', (
    tester,
  ) async {
    var expanded = false;
    Widget buildSection() => ExpandableSection(
      expanded: expanded,
      onChanged: (open) => expanded = open,
      header: const Text('header'),
      body: const Text('body'),
    );

    await pumpState(tester, buildSection());
    await tester.tap(find.text('header'));
    expect(expanded, isTrue);

    await tester.pumpAndSettle();
    expect(find.text('body'), findsNothing);

    await pumpState(tester, buildSection());
    await tester.pumpAndSettle();
    expect(find.text('body'), findsOneWidget);
  });

  testWidgets('should jump to the tapped state when animations are disabled', (
    tester,
  ) async {
    await pumpState(
      tester,
      const ExpandableSection(header: Text('header'), body: Text('body')),
      disableAnimations: true,
    );

    await tester.tap(find.text('header'));
    await tester.pump();

    expect(find.text('body'), findsOneWidget);
    expect(tester.getSize(find.byType(SizeTransition)).height, greaterThan(0));
  });

  testWidgets('should sweep the arrow half a turn when expanding', (
    tester,
  ) async {
    await pumpState(
      tester,
      const ExpandableSection(header: Text('header'), body: Text('body')),
    );
    expect(arrowTurns(tester), 0.0);

    await tester.tap(find.text('header'));
    await tester.pumpAndSettle();

    expect(arrowTurns(tester), AppAnimationConstants.expandArrowHalfTurn);
  });

  testWidgets('should place the arrow at the end of the header in RTL', (
    tester,
  ) async {
    await pumpState(
      tester,
      const ExpandableSection(header: Text('header'), body: Text('body')),
      direction: TextDirection.rtl,
    );

    final arrow = tester.getTopLeft(find.byType(Icon));
    final header = tester.getTopLeft(find.text('header'));

    expect(arrow.dx, lessThan(header.dx));
  });
}
