/// Conversions between a local calendar day and the `yyyy-MM-dd` text key
/// stored in the `date` columns.
///
/// Days are keyed by the device's *local* clock (a meal eaten at 23:30
/// belongs to that evening, not to the next UTC day); exact instants are
/// stored separately as UTC milliseconds.
library;

final _dateKeyPattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

/// `yyyy-MM-dd` for the local calendar day containing [local].
String dateKey(DateTime local) {
  final d = local.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${d.year.toString().padLeft(4, '0')}-${two(d.month)}-${two(d.day)}';
}

/// Local midnight of the day named by [key]. Throws [FormatException] for
/// anything that isn't exactly `yyyy-MM-dd`.
DateTime parseDateKey(String key) {
  final match = _dateKeyPattern.firstMatch(key);
  if (match == null) throw FormatException('Invalid date key', key);
  return DateTime(
    int.parse(match.group(1)!),
    int.parse(match.group(2)!),
    int.parse(match.group(3)!),
  );
}
