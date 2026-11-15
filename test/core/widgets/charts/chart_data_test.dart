import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/widgets/charts/chart_data.dart';

void main() {
  group('ChartBarGroup', () {
    test(
      'should hold a label, one value per series and an optional colour',
      () {
        const group = ChartBarGroup(
          label: 'Nov',
          values: [30, 70],
          color: Colors.teal,
        );

        expect(group.label, 'Nov');
        expect(group.values, [30, 70]);
        expect(group.color, Colors.teal);
      },
    );

    test('should default the colour override to null', () {
      const group = ChartBarGroup(label: 'Dec', values: [1]);

      expect(group.color, isNull);
    });
  });

  group('ChartSeries', () {
    test('should hold a name and a colour', () {
      const series = ChartSeries(name: 'Won', color: Colors.green);

      expect(series.name, 'Won');
      expect(series.color, Colors.green);
    });
  });

  group('ChartSlice', () {
    test('should hold a label, a value and a colour', () {
      const slice = ChartSlice(label: 'Lead', value: 40000, color: Colors.blue);

      expect(slice.label, 'Lead');
      expect(slice.value, 40000);
      expect(slice.color, Colors.blue);
    });
  });
}
