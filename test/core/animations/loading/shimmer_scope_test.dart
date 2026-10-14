import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/animations/loading/shimmer_box.dart';
import 'package:orbit/core/animations/loading/shimmer_scope.dart';

import 'harness.dart';

void main() {
  Widget skeleton() => Column(
    children: [
      const ShimmerBox(height: 20),
      const ShimmerBox.circle(),
      const ShimmerBox.textLine(width: 120),
    ],
  );

  testWidgets(
    'should apply a single shader mask over the whole skeleton when animations are enabled',
    (tester) async {
      await pumpLoading(tester, ShimmerScope(child: skeleton()));

      expect(find.byType(ShaderMask), findsOneWidget);
      expect(find.byType(ShimmerBox), findsNWidgets(3));
    },
  );

  testWidgets(
    'should re-render the sweep on every tick when animations are enabled',
    (tester) async {
      await pumpLoading(tester, ShimmerScope(child: skeleton()));
      final before = tester.widget<ShaderMask>(find.byType(ShaderMask));

      await tester.pump(const Duration(milliseconds: 300));

      final after = tester.widget<ShaderMask>(find.byType(ShaderMask));
      expect(identical(before, after), isFalse);
    },
  );

  testWidgets(
    'should render the skeleton without a shader mask when animations are disabled',
    (tester) async {
      await pumpLoading(
        tester,
        ShimmerScope(child: skeleton()),
        disableAnimations: true,
      );

      expect(find.byType(ShaderMask), findsNothing);
      expect(find.byType(ShimmerBox), findsNWidgets(3));
    },
  );

  testWidgets(
    'should render the skeleton without errors when the direction is RTL',
    (tester) async {
      await pumpLoading(
        tester,
        ShimmerScope(child: skeleton()),
        direction: TextDirection.rtl,
      );

      expect(find.byType(ShaderMask), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('should dispose cleanly when removed', (tester) async {
    await pumpLoading(tester, ShimmerScope(child: skeleton()));
    await pumpLoading(tester, const SizedBox());

    expect(tester.takeException(), isNull);
  });
}
