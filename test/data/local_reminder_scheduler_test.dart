import 'package:denge/data/local_reminder_scheduler.dart';
import 'package:denge/data/reminders.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

void main() {
  tz_data.initializeTimeZones();
  final istanbul = tz.getLocation('Europe/Istanbul');
  final berlin = tz.getLocation('Europe/Berlin');

  ReminderSlot slot(int hour, int minute, {int? weekday}) => ReminderSlot(
      id: 1, title: 't', body: 'b', hour: hour, minute: minute, weekday: weekday);

  test('daily: later today, or tomorrow once the time has passed', () {
    final now = tz.TZDateTime(istanbul, 2026, 10, 7, 10, 0); // Wednesday
    expect(LocalReminderScheduler.nextOccurrence(slot(12, 30), now),
        tz.TZDateTime(istanbul, 2026, 10, 7, 12, 30));
    expect(LocalReminderScheduler.nextOccurrence(slot(8, 30), now),
        tz.TZDateTime(istanbul, 2026, 10, 8, 8, 30));
    expect(LocalReminderScheduler.nextOccurrence(slot(10, 0), now),
        tz.TZDateTime(istanbul, 2026, 10, 8, 10, 0),
        reason: 'exactly now is not "after now"');
  });

  test('daily across a month end', () {
    final now = tz.TZDateTime(istanbul, 2026, 10, 31, 23, 0);
    expect(LocalReminderScheduler.nextOccurrence(slot(8, 30), now),
        tz.TZDateTime(istanbul, 2026, 11, 1, 8, 30));
  });

  test('weekly: next Sunday 20:00', () {
    final wed = tz.TZDateTime(istanbul, 2026, 10, 7, 10);
    expect(
        LocalReminderScheduler.nextOccurrence(
            slot(20, 0, weekday: DateTime.sunday), wed),
        tz.TZDateTime(istanbul, 2026, 10, 11, 20));
    final sundayLate = tz.TZDateTime(istanbul, 2026, 10, 11, 21);
    expect(
        LocalReminderScheduler.nextOccurrence(
            slot(20, 0, weekday: DateTime.sunday), sundayLate),
        tz.TZDateTime(istanbul, 2026, 10, 18, 20));
  });

  test('keeps the wall-clock time across a DST change', () {
    // Berlin leaves summer time on 25 Oct 2026.
    final now = tz.TZDateTime(berlin, 2026, 10, 24, 22);
    final next = LocalReminderScheduler.nextOccurrence(slot(8, 30), now);
    expect((next.day, next.hour, next.minute), (25, 8, 30));
  });
}
