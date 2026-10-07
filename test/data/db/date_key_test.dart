import 'package:denge/data/db/date_key.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('dateKey', () {
    test('formats a local date as zero-padded yyyy-MM-dd', () {
      expect(dateKey(DateTime(2026, 3, 7, 12)), '2026-03-07');
    });

    test('23:59:59 still belongs to the same day', () {
      expect(dateKey(DateTime(2026, 10, 7, 23, 59, 59)), '2026-10-07');
    });

    test('midnight starts the next day', () {
      expect(dateKey(DateTime(2026, 10, 8)), '2026-10-08');
    });

    test('year boundary', () {
      expect(dateKey(DateTime(2026, 12, 31, 23, 30)), '2026-12-31');
      expect(dateKey(DateTime(2027, 1, 1, 0, 0, 1)), '2027-01-01');
    });
  });

  group('parseDateKey', () {
    test('round-trips with dateKey', () {
      final d = parseDateKey('2026-02-28');
      expect(d, DateTime(2026, 2, 28));
      expect(d.isUtc, isFalse);
      expect(dateKey(d), '2026-02-28');
    });

    test('rejects malformed keys', () {
      expect(() => parseDateKey('2026-2-28'), throwsFormatException);
      expect(() => parseDateKey(''), throwsFormatException);
    });
  });
}
