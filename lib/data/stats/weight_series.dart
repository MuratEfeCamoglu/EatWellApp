import '../db/date_key.dart';
import '../models.dart';

/// The last measurement of each local day, oldest day first — what the
/// weight chart plots when several weights were entered on one day.
List<WeightEntry> latestPerDay(Iterable<WeightEntry> history) {
  final byDay = <String, WeightEntry>{};
  for (final e in history) {
    final key = dateKey(e.date);
    final current = byDay[key];
    if (current == null || !e.date.isBefore(current.date)) byDay[key] = e;
  }
  final keys = byDay.keys.toList()..sort();
  return [for (final k in keys) byDay[k]!];
}

/// The points of [daily] (as returned by [latestPerDay]) within the last
/// [days] local days including today. When none fall in the window the
/// latest known point is returned on its own, so the chart is never blank
/// for someone who simply hasn't weighed in lately.
List<WeightEntry> lastDays(List<WeightEntry> daily, DateTime now, int days) {
  if (daily.isEmpty) return const [];
  final first = dateKey(DateTime(now.year, now.month, now.day - (days - 1)));
  final today = dateKey(now);
  final window = [
    for (final e in daily)
      if (dateKey(e.date).compareTo(first) >= 0 &&
          dateKey(e.date).compareTo(today) <= 0)
        e,
  ];
  return window.isEmpty ? [daily.last] : window;
}
