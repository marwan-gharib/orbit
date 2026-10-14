import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/animations/animations.dart';

import '../entrance/harness.dart';

void main() {
  Finder fadeOfRow(String row) => find.descendant(
    of: find.byKey(ValueKey(row), skipOffstage: false),
    matching: find.byType(FadeTransition, skipOffstage: false),
  );

  testWidgets(
    'should keep the entrance finished when a row scrolls away and back',
    (tester) async {
      await pumpEntrance(
        tester,
        ListView.builder(
          itemCount: 15,
          itemBuilder: (context, index) => SizedBox(
            height: 60,
            child: StaggeredListItem(
              key: ValueKey('row-$index'),
              index: index,
              child: Text('row $index'),
            ),
          ),
        ),
      );
      await tester.pump(AppDurations.slow);

      // Row 0 leaves the viewport; keep-alive leaves its element mounted with
      // the finished entrance.
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(fadeOfRow('row-0'), findsOneWidget);
      expect(
        tester.widget<FadeTransition>(fadeOfRow('row-0')).opacity.value,
        AppAnimationConstants.fadeOpacityEnd,
      );

      // One frame after row 0 scrolls back: a replayed entrance would read
      // fadeOpacityBegin here, the kept one still reads the end value.
      await tester.drag(find.byType(ListView), const Offset(0, 600));
      await tester.pump();
      expect(
        tester.widget<FadeTransition>(fadeOfRow('row-0')).opacity.value,
        AppAnimationConstants.fadeOpacityEnd,
      );
    },
  );
}
