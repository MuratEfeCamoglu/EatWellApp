import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'water_dao.g.dart';

/// SQL for `water_logs` (one row per local day).
@DriftAccessor(tables: [WaterLogs])
class WaterDao extends DatabaseAccessor<AppDatabase> with _$WaterDaoMixin {
  WaterDao(super.attachedDatabase);

  SimpleSelectStatement<$WaterLogsTable, WaterLogRow> _forDate(String date) =>
      select(waterLogs)
        ..where((t) => t.date.equals(date) & t.deletedAt.isNull());

  /// Glasses drunk on [date], or null when nothing was recorded.
  Future<int?> glassesForDate(String date) async =>
      (await _forDate(date).getSingleOrNull())?.glasses;

  Stream<int?> watchGlassesForDate(String date) =>
      _forDate(date).watchSingleOrNull().map((row) => row?.glasses);

  /// Creates [date]'s row or updates it in place (the `date` column is
  /// unique). [id] is only used when the row is new.
  Future<void> setGlasses(String id, String date, int glasses, DateTime now) {
    final ms = now.toUtc().millisecondsSinceEpoch;
    return into(waterLogs).insert(
      WaterLogsCompanion.insert(
        id: id,
        createdAt: ms,
        updatedAt: ms,
        date: date,
        glasses: glasses,
      ),
      onConflict: DoUpdate(
        (_) => WaterLogsCompanion(
          glasses: Value(glasses),
          updatedAt: Value(ms),
          deletedAt: const Value(null),
        ),
        target: [waterLogs.date],
      ),
    );
  }
}
