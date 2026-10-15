import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/animations/animations.dart';

import '../entrance/harness.dart';

void main() {
  double opacityOf(WidgetTester tester) =>
      tester.widget<FadeTransition>(find.byType(FadeTransition)).opacity.value;

  Finder fadeOfCell(String cell) => find.descendant(
    of: find.byKey(ValueKey(cell), skipOffstage: false),
    matching: find.byType(FadeTransition, skipOffstage: false),
  );

  testWidgets('should delay a cell by index times stagger when built', (
    tester,
  ) async {
    await pumpEntrance(
      tester,
      const StaggeredGridItem(index: 1, child: Text('payload')),
    );

    await tester.pump(const Duration(milliseconds: 20));
    expect(opacityOf(tester), AppAnimationConstants.fadeOpacityBegin);

    await tester.pump(AppDurations.slow);
    expect(opacityOf(tester), AppAnimationConstants.fadeOpacityEnd);
  });

  testWidgets(
    'should render a cell immediately when its index is past the cap',
    (tester) async {
      await pumpEntrance(
        tester,
        const StaggeredGridItem(
          index: AppAnimationConstants.maxStaggerIndex + 1,
          child: Text('payload'),
        ),
      );

      expect(find.byType(FadeSlideIn), findsNothing);
      expect(find.text('payload'), findsOneWidget);
    },
  );

  testWidgets(
    'should keep the entrance finished when a cell scrolls away and back in a grid',
    (tester) async {
      await pumpEntrance(
        tester,
        GridView.builder(
          itemCount: 8,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2,
          ),
          itemBuilder: (context, index) => StaggeredGridItem(
            key: ValueKey('cell-$index'),
            index: index,
            child: Text('cell $index'),
          ),
        ),
      );
      await tester.pump(AppDurations.slow);

      await tester.drag(find.byType(GridView), const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(fadeOfCell('cell-0'), findsOneWidget);
      expect(
        tester.widget<FadeTransition>(fadeOfCell('cell-0')).opacity.value,
        AppAnimationConstants.fadeOpacityEnd,
      );

      await tester.drag(find.byType(GridView), const Offset(0, 500));
      await tester.pump();
      expect(
        tester.widget<FadeTransition>(fadeOfCell('cell-0')).opacity.value,
        AppAnimationConstants.fadeOpacityEnd,
      );
    },
  );
}
