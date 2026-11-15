import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/animations/selection/floating_nav_bar.dart';
import 'package:orbit/core/animations/tokens/app_durations.dart';

import 'harness.dart';

void main() {
  List<FloatingNavItem> items() => const [
    FloatingNavItem(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard_rounded,
    ),
    FloatingNavItem(
      label: 'Opportunities',
      icon: Icons.work_outline_rounded,
      selectedIcon: Icons.work_rounded,
    ),
    FloatingNavItem(
      label: 'Interactions',
      icon: Icons.forum_outlined,
      selectedIcon: Icons.forum_rounded,
    ),
  ];

  testWidgets('should call onSelected with the tapped item index', (
    tester,
  ) async {
    int? selected;
    await pumpSelection(
      tester,
      FloatingNavBar(
        items: items(),
        selectedIndex: 0,
        onSelected: (index) => selected = index,
      ),
    );

    await tester.tap(find.byIcon(Icons.work_outline_rounded));
    await tester.pump(AppDurations.normal);

    expect(selected, 1);
  });

  testWidgets('should glide to a changed selection and settle without errors', (
    tester,
  ) async {
    await pumpSelection(
      tester,
      FloatingNavBar(items: items(), selectedIndex: 0, onSelected: (_) {}),
    );

    await pumpSelection(
      tester,
      FloatingNavBar(items: items(), selectedIndex: 2, onSelected: (_) {}),
    );
    await tester.pump(AppDurations.normal);

    expect(tester.takeException(), isNull);
  });

  test('should require at least two items', () {
    expect(
      () => FloatingNavBar(
        items: const [
          FloatingNavItem(label: 'Only', icon: Icons.dashboard_outlined),
        ],
        selectedIndex: 0,
        onSelected: (_) {},
      ),
      throwsAssertionError,
    );
  });
}
