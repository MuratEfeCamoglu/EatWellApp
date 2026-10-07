import 'package:denge/data/reminders.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationSettings', () {
    test('everything is off by default (opt-in only)', () {
      const s = NotificationSettings();
      expect(s.anyEnabled, isFalse);
      expect(s.breakfastMinutes, 8 * 60 + 30);
      expect(s.lunchMinutes, 12 * 60 + 30);
      expect(s.dinnerMinutes, 19 * 60);
      expect(s.waterIntervalHours, 2);
    });

    test('round-trips through JSON', () {
      const s = NotificationSettings(
        mealReminders: true,
        weeklySummary: true,
        breakfastMinutes: 7 * 60 + 15,
        waterIntervalHours: 3,
      );
      final back = NotificationSettings.fromJson(s.toJson());
      expect(back, s);
    });

    test('broken or out-of-range JSON falls back to safe values', () {
      expect(NotificationSettings.fromJson('not json'),
          const NotificationSettings());
      final s = NotificationSettings.fromJson(
          '{"breakfastMinutes": 99999, "waterIntervalHours": 9, "mealReminders": "yes"}');
      expect(s.breakfastMinutes, 8 * 60 + 30);
      expect(s.waterIntervalHours, 4);
      expect(s.mealReminders, isFalse);
    });

    test('formatMinutes pads to HH:mm', () {
      expect(formatMinutes(7 * 60 + 5), '07:05');
      expect(formatMinutes(23 * 60 + 59), '23:59');
    });
  });

  group('plannedReminders', () {
    test('nothing enabled -> nothing scheduled', () {
      expect(plannedReminders(const NotificationSettings()), isEmpty);
    });

    test('meal reminders at the chosen times, daily', () {
      final slots = plannedReminders(const NotificationSettings(
          mealReminders: true, breakfastMinutes: 7 * 60 + 45));
      expect(slots.map((s) => (s.hour, s.minute)),
          [(7, 45), (12, 30), (19, 0)]);
      expect(slots.every((s) => s.weekday == null), isTrue);
      expect(slots.first.title, 'Kahvaltı zamanı');
    });

    test('water every N hours from 09:00 to 21:00', () {
      List<int> hours(int n) => plannedReminders(NotificationSettings(
              waterReminders: true, waterIntervalHours: n))
          .map((s) => s.hour)
          .toList();
      expect(hours(2), [9, 11, 13, 15, 17, 19, 21]);
      expect(hours(3), [9, 12, 15, 18, 21]);
      expect(hours(4), [9, 13, 17, 21]);
    });

    test('weekly summary on Sunday 20:00', () {
      final s = plannedReminders(
              const NotificationSettings(weeklySummary: true))
          .single;
      expect((s.weekday, s.hour, s.minute), (DateTime.sunday, 20, 0));
    });

    test('ids are unique across all reminders', () {
      final slots = plannedReminders(const NotificationSettings(
          mealReminders: true,
          waterReminders: true,
          weeklySummary: true,
          waterIntervalHours: 1));
      expect(slots.map((s) => s.id).toSet(), hasLength(slots.length));
    });
  });
}
