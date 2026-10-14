import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/animations/animations.dart';

import 'harness.dart';

void main() {
  final blurPrefix =
      'ImageFilter.blur(${AppAnimationConstants.blurSigma}, ${AppAnimationConstants.blurSigma}';

  testWidgets('should start blurred and drop the filter once sharp', (
    tester,
  ) async {
    await pumpEntrance(tester, const BlurIn(child: Text('payload')));

    final filter = tester
        .widget<ImageFiltered>(find.byType(ImageFiltered))
        .imageFilter;
    expect(filter.toString(), startsWith(blurPrefix));
    expect(find.text('payload'), findsOneWidget);

    await tester.pump(AppDurations.slow);

    expect(find.byType(ImageFiltered), findsNothing);
    expect(find.text('payload'), findsOneWidget);
  });

  testWidgets('should stay blurred until the delay has passed', (tester) async {
    await pumpEntrance(
      tester,
      const BlurIn(delay: AppDurations.fast, child: Text('payload')),
    );

    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(ImageFiltered), findsOneWidget);

    await tester.pump(AppDurations.slow);
    expect(find.byType(ImageFiltered), findsNothing);
  });

  testWidgets(
    'should render the final state immediately when animations are disabled',
    (tester) async {
      await pumpEntrance(
        tester,
        const BlurIn(child: Text('payload')),
        disableAnimations: true,
      );

      expect(find.byType(ImageFiltered), findsNothing);
      expect(find.text('payload'), findsOneWidget);
    },
  );
}
