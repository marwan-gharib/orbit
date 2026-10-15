import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/animations/animations.dart';

import '../entrance/harness.dart';

void main() {
  final children = [
    for (
      var index = 0;
      index <= AppAnimationConstants.maxStaggerIndex + 1;
      index++
    )
      Text('cell $index'),
  ];

  testWidgets(
    'should stagger every child by its position and skip past the cap',
    (tester) async {
      await pumpEntrance(tester, StaggeredColumn(children: children));

      expect(
        find.textContaining('cell'),
        findsNWidgets(AppAnimationConstants.maxStaggerIndex + 2),
      );
      expect(
        find.descendant(
          of: find.byType(StaggeredColumn),
          matching: find.byType(FadeSlideIn),
        ),
        findsNWidgets(AppAnimationConstants.maxStaggerIndex + 1),
      );
    },
  );

  testWidgets(
    'should lay out like a column when layout parameters are passed',
    (tester) async {
      await pumpEntrance(
        tester,
        const StaggeredColumn(
          mainAxisSize: MainAxisSize.min,
          children: [Text('a')],
        ),
      );

      final column = tester.widget<Column>(find.byType(Column));
      expect(column.mainAxisSize, MainAxisSize.min);
      expect(find.text('a'), findsOneWidget);
    },
  );
}
