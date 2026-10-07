import 'dart:developer' as developer;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'reminders.dart';

/// [ReminderScheduler] backed by `flutter_local_notifications`: every
/// reminder is a recurring local notification, so nothing needs the
/// network or the app to be running.
class LocalReminderScheduler implements ReminderScheduler {
  final _plugin = FlutterLocalNotificationsPlugin();

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'reminders',
      'Hatırlatıcılar',
      channelDescription: 'Öğün, su ve haftalık özet hatırlatıcıları',
    ),
    iOS: DarwinNotificationDetails(),
  );

  /// Loads the time-zone database, picks the device's zone (so "08:30"
  /// means local 08:30) and initialises the plugin without prompting —
  /// the permission is asked only when a reminder is turned on.
  Future<void> init() async {
    tz_data.initializeTimeZones();
    try {
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
    } catch (e, st) {
      // Falls back to UTC; reminders would then be off by the UTC offset,
      // which is still better than not starting.
      developer.log('Local time zone unavailable', error: e, stackTrace: st);
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestSoundPermission: false,
          requestBadgePermission: false,
        ),
      ),
    );
  }

  @override
  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      return await ios.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    }
    return true;
  }

  @override
  Future<void> apply(NotificationSettings settings) async {
    await _plugin.cancelAll();
    final now = tz.TZDateTime.now(tz.local);
    for (final slot in plannedReminders(settings)) {
      await _plugin.zonedSchedule(
        id: slot.id,
        title: slot.title,
        body: slot.body,
        scheduledDate: nextOccurrence(slot, now),
        notificationDetails: _details,
        // Inexact: no "exact alarm" permission needed, and a few minutes'
        // drift is fine for a reminder.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: slot.weekday == null
            ? DateTimeComponents.time
            : DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  /// The first time strictly after [now] that [slot] should fire.
  /// Days are stepped through the constructor (not `Duration`) so the wall
  /// clock time survives daylight-saving changes.
  static tz.TZDateTime nextOccurrence(ReminderSlot slot, tz.TZDateTime now) {
    tz.TZDateTime onDay(int offset) => tz.TZDateTime(now.location, now.year,
        now.month, now.day + offset, slot.hour, slot.minute);

    final weekday = slot.weekday;
    var offset = weekday == null ? 0 : (weekday - now.weekday) % 7;
    if (!onDay(offset).isAfter(now)) offset += weekday == null ? 1 : 7;
    return onDay(offset);
  }
}
