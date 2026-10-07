import '../db/date_key.dart';

/// Consecutive local days, counting back from today, that have at least one
/// diary entry ([loggedDates] holds `yyyy-MM-dd` keys).
///
/// If today has nothing logged yet the count starts from yesterday: the
/// day isn't over, so the streak isn't considered broken until it is.
int currentStreak(Set<String> loggedDates, DateTime now) {
  // Stepping with the DateTime constructor (not Duration) keeps days
  // correct across DST changes and month/year ends.
  var day = DateTime(now.year, now.month, now.day);
  if (!loggedDates.contains(dateKey(day))) {
    day = DateTime(day.year, day.month, day.day - 1);
  }
  var streak = 0;
  while (loggedDates.contains(dateKey(day))) {
    streak++;
    day = DateTime(day.year, day.month, day.day - 1);
  }
  return streak;
}
