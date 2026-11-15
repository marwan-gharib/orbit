import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/widgets/progress_ring.dart';

import 'harness.dart';

void main() {
  testWidgets('should size itself to the given edge', (tester) async {
    await pumpWidget(
      tester,
      const ProgressRing(progress: 0.4, strokeWidth: 4, size: 64),
    );

    expect(tester.getSize(find.byType(ProgressRing)), const Size(64, 64));
  });

  testWidgets('should clamp an out-of-range progress', (tester) async {
    await pumpWidget(
      tester,
      const ProgressRing(progress: 2.5, strokeWidth: 4, size: 48),
    );
    expect(tester.takeException(), isNull);

    await pumpWidget(
      tester,
      const ProgressRing(progress: -1, strokeWidth: 4, size: 48),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('should repaint when the progress changes', (tester) async {
    await pumpWidget(
      tester,
      const ProgressRing(progress: 0.1, strokeWidth: 4, size: 48),
    );

    await pumpWidget(
      tester,
      const ProgressRing(progress: 0.9, strokeWidth: 4, size: 48),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('should accept custom track and progress colors', (tester) async {
    await pumpWidget(
      tester,
      const ProgressRing(
        progress: 0.5,
        strokeWidth: 6,
        size: 48,
        trackColor: Colors.amber,
        progressColor: Colors.purple,
        backgroundColor: Colors.black12,
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
