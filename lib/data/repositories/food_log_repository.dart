import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../db/app_database.dart';
import '../models.dart';

/// Turns diary rows into [FoodLogEntry] models and back, and owns id and
/// timestamp generation. The future cloud sync hooks in here.
class FoodLogRepository {
  FoodLogRepository(this._db, {Uuid uuid = const Uuid()}) : _uuid = uuid;

  final AppDatabase _db;
  final Uuid _uuid;

  /// Saves [draft] with a fresh UUID; [now] stamps `created_at` and
  /// `updated_at`. Returns the stored entry.
  Future<FoodLogEntry> add(FoodLogEntry draft, DateTime now) async {
    final entry = draft.copyWith(id: _uuid.v4());
    final ms = now.toUtc().millisecondsSinceEpoch;
    await _db.foodLogDao.insertEntry(FoodLogEntriesCompanion.insert(
      id: entry.id,
      createdAt: ms,
      updatedAt: ms,
      date: entry.date,
      meal: entry.meal.name,
      foodName: entry.foodName,
      brand: Value(entry.brand),
      servingLabel: entry.servingLabel,
      amount: entry.amount,
      kcal: entry.kcal,
      proteinG: entry.proteinG,
      carbsG: entry.carbsG,
      fatG: entry.fatG,
      source: entry.source.name,
      sourceRef: Value(entry.sourceRef),
      loggedAt: entry.loggedAt.millisecondsSinceEpoch,
    ));
    return entry;
  }

  Stream<List<FoodLogEntry>> watchDate(String date) => _db.foodLogDao
      .watchEntriesForDate(date)
      .map((rows) => rows.map(_toModel).toList());

  Future<List<FoodLogEntry>> entriesForDate(String date) async =>
      (await _db.foodLogDao.entriesForDate(date)).map(_toModel).toList();

  Future<Set<String>> datesWithEntries({String? from, String? to}) =>
      _db.foodLogDao.datesWithEntries(from: from, to: to);

  static FoodLogEntry _toModel(FoodLogRow row) => FoodLogEntry(
        id: row.id,
        date: row.date,
        meal: MealType.values.asNameMap()[row.meal] ?? MealType.snack,
        foodName: row.foodName,
        brand: row.brand,
        servingLabel: row.servingLabel,
        amount: row.amount,
        kcal: row.kcal,
        proteinG: row.proteinG,
        carbsG: row.carbsG,
        fatG: row.fatG,
        source: FoodLogSource.values.asNameMap()[row.source] ??
            FoodLogSource.catalog,
        sourceRef: row.sourceRef,
        loggedAt:
            DateTime.fromMillisecondsSinceEpoch(row.loggedAt, isUtc: true),
      );
}
