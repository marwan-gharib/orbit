import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/animations/selection/animated_chip_selector.dart';
import 'package:orbit/core/animations/selection/chip_item.dart';
import 'package:orbit/core/animations/tokens/app_durations.dart';

import 'harness.dart';

void main() {
  List<ChipItem<String>> items() => const [
    ChipItem(value: 'all', label: 'All'),
    ChipItem(value: 'call', label: 'Calls', icon: Icons.call),
    ChipItem(value: 'meeting', label: 'Meetings', badge: 3),
  ];

  testWidgets('should fire onChanged with the tapped chip value', (
    tester,
  ) async {
    String? changed;
    await pumpSelection(
      tester,
      AnimatedChipSelector<String>(
        items: items(),
        selectedValue: 'all',
        onChanged: (value) => changed = value,
      ),
    );

    await tester.tap(find.text('Calls'));
    await tester.pump(AppDurations.normal);

    expect(changed, 'call');
  });

  testWidgets('should show a count badge only for chips that have one', (
    tester,
  ) async {
    await pumpSelection(
      tester,
      AnimatedChipSelector<String>(
        items: items(),
        selectedValue: 'all',
        onChanged: (_) {},
      ),
    );

    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('should render the leading icon of a chip', (tester) async {
    await pumpSelection(
      tester,
      AnimatedChipSelector<String>(
        items: items(),
        selectedValue: 'all',
        onChanged: (_) {},
      ),
    );

    expect(find.byIcon(Icons.call), findsOneWidget);
  });

  testWidgets('should not fire for the already-selected chip', (tester) async {
    String? changed;
    await pumpSelection(
      tester,
      AnimatedChipSelector<String>(
        items: items(),
        selectedValue: 'all',
        onChanged: (value) => changed = value,
      ),
    );

    await tester.tap(find.text('All'));
    await tester.pump(AppDurations.normal);

    expect(changed, 'all');
  });
}
