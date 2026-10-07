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

  static int _ms(DateTime now) => now.toUtc().millisecondsSinceEpoch;

  Future<void> _update(String id, FoodLogEntriesCompanion changes) =>
      (update(foodLogEntries)..where((t) => t.id.equals(id))).write(changes);

  /// Hides the entry (see CLAUDE.md §4.7) rather than removing the row.
  Future<void> softDelete(String id, DateTime now) => _update(
        id,
        FoodLogEntriesCompanion(
            deletedAt: Value(_ms(now)), updatedAt: Value(_ms(now))),
      );

  /// Undoes [softDelete] (the diary's "Geri al").
  Future<void> restore(String id, DateTime now) => _update(
        id,
        FoodLogEntriesCompanion(
            deletedAt: const Value(null), updatedAt: Value(_ms(now))),
      );

  /// Changes the number of servings, scaling kcal and macros by
  /// `amount / old amount` so the values frozen at log time stay the basis.
  Future<void> updateAmount(String id, double amount, DateTime now) {
    return transaction(() async {
      final row = await (select(foodLogEntries)..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      if (row == null || row.amount <= 0) return;
      final factor = amount / row.amount;
      await _update(
        id,
        FoodLogEntriesCompanion(
          amount: Value(amount),
          kcal: Value((row.kcal * factor).round()),
          proteinG: Value(row.proteinG * factor),
          carbsG: Value(row.carbsG * factor),
          fatG: Value(row.fatG * factor),
          updatedAt: Value(_ms(now)),
        ),
      );
    });
  }

  /// Moves the entry to another meal (`MealType.name`).
  Future<void> updateMeal(String id, String meal, DateTime now) => _update(
        id,
        FoodLogEntriesCompanion(meal: Value(meal), updatedAt: Value(_ms(now))),
      );

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
