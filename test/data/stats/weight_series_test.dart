import 'package:denge/data/models.dart';
import 'package:denge/data/stats/weight_series.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('latestPerDay', () {
    test('empty history', () {
      expect(latestPerDay(const []), isEmpty);
    });

    test('keeps the last measurement of each day, oldest day first', () {
      final daily = latestPerDay([
        WeightEntry(DateTime(2026, 10, 7, 8), 70.6),
        WeightEntry(DateTime(2026, 10, 5, 9), 71.2),
        WeightEntry(DateTime(2026, 10, 7, 21), 70.9),
        WeightEntry(DateTime(2026, 10, 7, 7), 70.2),
      ]);
      expect(daily.map((e) => e.kg), [71.2, 70.9]);
    });

    test('a measurement just before midnight stays on its own day', () {
      final daily = latestPerDay([
        WeightEntry(DateTime(2026, 10, 6, 23, 59), 71),
        WeightEntry(DateTime(2026, 10, 7, 0, 1), 70),
      ]);
      expect(daily, hasLength(2));
    });
  });

  group('lastDays', () {
    final daily = [
      WeightEntry(DateTime(2026, 9, 1, 8), 74),
      WeightEntry(DateTime(2026, 9, 30, 8), 72),
      WeightEntry(DateTime(2026, 10, 1, 8), 71.5),
      WeightEntry(DateTime(2026, 10, 7, 8), 71),
    ];
    final now = DateTime(2026, 10, 7, 20);

    test('7 days include today and the 6 days before it', () {
      expect(lastDays(daily, now, 7).map((e) => e.kg), [71.5, 71]);
    });

    test('30 days cross the month boundary', () {
      expect(lastDays(daily, now, 30).map((e) => e.kg), [72, 71.5, 71]);
    });

    test('falls back to the latest point when the window is empty', () {
      expect(lastDays(daily, DateTime(2026, 12, 1), 7).map((e) => e.kg), [71]);
      expect(lastDays(const [], now, 7), isEmpty);
    });
  });
}
