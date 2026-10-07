import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'food_log_dao.g.dart';

/// SQL for `food_log_entries`. Every read hides soft-deleted rows.
@DriftAccessor(tables: [FoodLogEntries])
class FoodLogDao extends DatabaseAccessor<AppDatabase> with _$FoodLogDaoMixin {
  FoodLogDao(super.attachedDatabase);

  Future<void> insertEntry(FoodLogEntriesCompanion entry) =>
      into(foodLogEntries).insert(entry);

  SimpleSelectStatement<$FoodLogEntriesTable, FoodLogRow> _forDate(
      String date) {
    return select(foodLogEntries)
      ..where((t) => t.date.equals(date) & t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.asc(t.loggedAt)]);
  }

  /// Live, `logged_at`-ordered entries of [date]; re-emits on every change.
  Stream<List<FoodLogRow>> watchEntriesForDate(String date) =>
      _forDate(date).watch();

  Future<List<FoodLogRow>> entriesForDate(String date) => _forDate(date).get();

  /// Distinct days (inclusive [from]..[to]) that have at least one entry;
  /// the input for the streak calculation.
  Future<Set<String>> datesWithEntries({String? from, String? to}) async {
    final date = foodLogEntries.date;
    final query = selectOnly(foodLogEntries, distinct: true)
      ..addColumns([date])
      ..where(foodLogEntries.deletedAt.isNull());
    if (from != null) query.where(date.isBiggerOrEqualValue(from));
    if (to != null) query.where(date.isSmallerOrEqualValue(to));
    final rows = await query.get();
    return {for (final r in rows) r.read(date)!};
  }
}
