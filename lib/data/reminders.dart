import 'dart:convert';

/// The user's reminder choices. Everything is off until the user opts in,
/// because turning a reminder on is also what asks for the OS permission.
class NotificationSettings {
  const NotificationSettings({
    this.mealReminders = false,
    this.waterReminders = false,
    this.weeklySummary = false,
    this.breakfastMinutes = _defaultBreakfast,
    this.lunchMinutes = _defaultLunch,
    this.dinnerMinutes = _defaultDinner,
    this.waterIntervalHours = 2,
  });

  static const _defaultBreakfast = 8 * 60 + 30;
  static const _defaultLunch = 12 * 60 + 30;
  static const _defaultDinner = 19 * 60;

  final bool mealReminders;
  final bool waterReminders;
  final bool weeklySummary;

  /// Meal reminder times, minutes after local midnight.
  final int breakfastMinutes;
  final int lunchMinutes;
  final int dinnerMinutes;

  /// Hours between water reminders (1–4), from 09:00 until 21:00.
  final int waterIntervalHours;

  bool get anyEnabled => mealReminders || waterReminders || weeklySummary;

  NotificationSettings copyWith({
    bool? mealReminders,
    bool? waterReminders,
    bool? weeklySummary,
    int? breakfastMinutes,
    int? lunchMinutes,
    int? dinnerMinutes,
    int? waterIntervalHours,
  }) {
    return NotificationSettings(
      mealReminders: mealReminders ?? this.mealReminders,
      waterReminders: waterReminders ?? this.waterReminders,
      weeklySummary: weeklySummary ?? this.weeklySummary,
      breakfastMinutes: breakfastMinutes ?? this.breakfastMinutes,
      lunchMinutes: lunchMinutes ?? this.lunchMinutes,
      dinnerMinutes: dinnerMinutes ?? this.dinnerMinutes,
      waterIntervalHours: waterIntervalHours ?? this.waterIntervalHours,
    );
  }

  String toJson() => jsonEncode({
        'mealReminders': mealReminders,
        'waterReminders': waterReminders,
        'weeklySummary': weeklySummary,
        'breakfastMinutes': breakfastMinutes,
        'lunchMinutes': lunchMinutes,
        'dinnerMinutes': dinnerMinutes,
        'waterIntervalHours': waterIntervalHours,
      });

  /// Tolerant of missing, mistyped or out-of-range values (each falls back
  /// to its default) so a bad stored value never breaks startup.
  factory NotificationSettings.fromJson(String? json) {
    Map<String, dynamic> m;
    try {
      final decoded = json == null ? null : jsonDecode(json);
      m = decoded is Map<String, dynamic> ? decoded : const {};
    } on FormatException {
      m = const {};
    }
    bool flag(String k) => m[k] is bool ? m[k] as bool : false;
    int minutes(String k, int fallback) {
      final v = m[k];
      return v is int && v >= 0 && v < 24 * 60 ? v : fallback;
    }

    final interval = m['waterIntervalHours'];
    return NotificationSettings(
      mealReminders: flag('mealReminders'),
      waterReminders: flag('waterReminders'),
      weeklySummary: flag('weeklySummary'),
      breakfastMinutes: minutes('breakfastMinutes', _defaultBreakfast),
      lunchMinutes: minutes('lunchMinutes', _defaultLunch),
      dinnerMinutes: minutes('dinnerMinutes', _defaultDinner),
      waterIntervalHours: interval is int ? interval.clamp(1, 4) : 2,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is NotificationSettings && other.toJson() == toJson();

  @override
  int get hashCode => toJson().hashCode;
}

/// `HH:mm` for minutes after midnight.
String formatMinutes(int minutes) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(minutes ~/ 60)}:${two(minutes % 60)}';
}

/// One recurring notification: daily at [hour]:[minute], or weekly on
/// [weekday] (`DateTime.monday`…`DateTime.sunday`) when that is set.
class ReminderSlot {
  const ReminderSlot({
    required this.id,
    required this.title,
    required this.body,
    required this.hour,
    required this.minute,
    this.weekday,
  });

  final int id;
  final String title;
  final String body;
  final int hour;
  final int minute;
  final int? weekday;
}

const _firstWaterHour = 9;
const _lastWaterHour = 21;

/// Every notification [settings] asks for. Ids are stable per slot so
/// re-scheduling replaces rather than duplicates.
List<ReminderSlot> plannedReminders(NotificationSettings settings) {
  ReminderSlot meal(int id, int minutes, String title, String body) =>
      ReminderSlot(
          id: id, title: title, body: body, hour: minutes ~/ 60, minute: minutes % 60);

  return [
    if (settings.mealReminders) ...[
      meal(1, settings.breakfastMinutes, 'Kahvaltı zamanı',
          'Kahvaltıda ne yedin? Günlüğüne eklemeyi unutma.'),
      meal(2, settings.lunchMinutes, 'Öğle yemeği zamanı',
          'Öğle yemeğini günlüğüne ekle, hedefini takip et.'),
      meal(3, settings.dinnerMinutes, 'Akşam yemeği zamanı',
          'Akşam yemeğini eklemeyi unutma.'),
    ],
    if (settings.waterReminders)
      for (var h = _firstWaterHour, i = 0;
          h <= _lastWaterHour;
          h += settings.waterIntervalHours.clamp(1, 4), i++)
        ReminderSlot(
          id: 10 + i,
          title: 'Su içme zamanı',
          body: 'Bir bardak su iç ve Denge\'de işaretle.',
          hour: h,
          minute: 0,
        ),
    if (settings.weeklySummary)
      const ReminderSlot(
        id: 50,
        title: 'Haftalık özetin hazır',
        body: 'Bu haftaki ilerlemene ve serine göz at.',
        hour: 20,
        minute: 0,
        weekday: DateTime.sunday,
      ),
  ];
}

/// The OS notification layer, kept behind an interface so [AppState] (and
/// its tests) never depend on the plugin directly.
abstract class ReminderScheduler {
  /// Asks for permission to post notifications; true when granted.
  Future<bool> requestPermission();

  /// Cancels everything previously scheduled and schedules [settings]'
  /// [plannedReminders].
  Future<void> apply(NotificationSettings settings);
}

/// Used in tests and whenever the platform plugin couldn't be initialised.
class NoopReminderScheduler implements ReminderScheduler {
  const NoopReminderScheduler();

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> apply(NotificationSettings settings) async {}
}
