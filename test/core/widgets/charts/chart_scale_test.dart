import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/widgets/charts/chart_scale.dart';

void main() {
  group('ChartScale.niceMax', () {
    test('should round a value up to the next nice step', () {
      expect(ChartScale.niceMax(100), 100);
      expect(ChartScale.niceMax(101), 120);
      expect(ChartScale.niceMax(1500), 1500);
      expect(ChartScale.niceMax(75000), 80000);
    });

    test('should stay above the value, never below', () {
      for (final value in const <double>[0.7, 5.3, 42, 999, 12345.6]) {
        expect(ChartScale.niceMax(value), greaterThanOrEqualTo(value));
      }
    });

    test('should return one for empty or invalid input', () {
      expect(ChartScale.niceMax(0), 1);
      expect(ChartScale.niceMax(-5), 1);
      expect(ChartScale.niceMax(double.nan), 1);
      expect(ChartScale.niceMax(double.infinity), 1);
    });
  });

  group('ChartScale.gridValues', () {
    test('should space divisions evenly from zero to max', () {
      expect(ChartScale.gridValues(800, divisions: 4), [0, 200, 400, 600, 800]);
    });

    test('should default to four divisions', () {
      final grid = ChartScale.gridValues(1000);

      expect(grid, hasLength(5));
      expect(grid.first, 0);
      expect(grid.last, 1000);
    });
  });

  group('ChartScale.maxOf', () {
    test('should find the largest value across all series', () {
      expect(
        ChartScale.maxOf([
          [1, 2],
          [7, 3],
        ]),
        7,
      );
    });

    test('should return zero when everything is empty', () {
      expect(ChartScale.maxOf(<List<double>>[]), 0);
      expect(ChartScale.maxOf([<double>[]]), 0);
    });

    test('should treat negative values as zero', () {
      expect(
        ChartScale.maxOf(const <List<double>>[
          [-5, -1],
        ]),
        0,
      );
    });
  });
}
