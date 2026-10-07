import 'package:denge/data/stats/streak.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 10, 7, 15);

  test('no entries -> 0', () {
    expect(currentStreak({}, now), 0);
  });

  test('only today -> 1', () {
    expect(currentStreak({'2026-10-07'}, now), 1);
  });

  test('yesterday and today -> 2', () {
    expect(currentStreak({'2026-10-06', '2026-10-07'}, now), 2);
  });

  test('yesterday but not (yet) today -> 1, the streak is not broken', () {
    expect(currentStreak({'2026-10-06'}, now), 1);
  });

  test('a gap breaks the streak there', () {
    expect(
      currentStreak({'2026-10-01', '2026-10-02', '2026-10-05', '2026-10-06',
          '2026-10-07'}, now),
      3,
    );
  });

  test('neither today nor yesterday -> 0', () {
    expect(currentStreak({'2026-10-05', '2026-10-04'}, now), 0);
  });

  test('future dates are ignored', () {
    expect(currentStreak({'2026-10-08', '2026-10-07'}, now), 1);
  });

  test('crosses a month boundary', () {
    expect(
      currentStreak({'2026-09-29', '2026-09-30', '2026-10-01'},
          DateTime(2026, 10, 1, 9)),
      3,
    );
  });

  test('crosses a year boundary (and leap day)', () {
    expect(
      currentStreak({'2027-12-30', '2027-12-31', '2028-01-01'},
          DateTime(2028, 1, 1, 0, 30)),
      3,
    );
    expect(
      currentStreak({'2028-02-28', '2028-02-29', '2028-03-01'},
          DateTime(2028, 3, 1, 23, 59)),
      3,
    );
  });
}
