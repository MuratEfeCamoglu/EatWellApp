import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'app_database.steps.dart';
import 'daos/custom_food_dao.dart';
import 'daos/food_log_dao.dart';
import 'daos/sync_dao.dart';
import 'daos/water_dao.dart';
import 'daos/weight_dao.dart';
import 'tables.dart';

part 'app_database.g.dart';

/// The on-device SQLite database holding the user's diary, water and
/// weight logs. Screens never touch it directly — they go through
/// [AppState], which goes through the repositories.
@DriftDatabase(
  tables: [FoodLogEntries, WaterLogs, WeightEntries, CustomFoods, SyncState],
  daos: [FoodLogDao, WaterDao, WeightDao, CustomFoodDao, SyncDao],
)
class AppDatabase extends _$AppDatabase {
  /// The real database file, `denge.sqlite` in the documents directory.
  AppDatabase() : super(driftDatabase(name: 'denge'));

  /// Tests pass `NativeDatabase.memory()` here.
  AppDatabase.forTesting(super.executor);

  /// Bump on every schema change and add a matching `onUpgrade` step;
  /// never edit a released schema in place (CLAUDE.md §8).
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        // One step per released version, generated helpers from
        // `dart run drift_dev make-migrations` (CLAUDE.md §8).
        onUpgrade: stepByStep(
          // v2: cloud sync bookkeeping (CLAUDE.md §13.3) — additive only.
          from1To2: (m, schema) async {
            await m.addColumn(
                schema.foodLogEntries, schema.foodLogEntries.serverUpdatedAt);
            await m.addColumn(schema.waterLogs, schema.waterLogs.serverUpdatedAt);
            await m.addColumn(
                schema.weightEntries, schema.weightEntries.serverUpdatedAt);
            await m.addColumn(
                schema.customFoods, schema.customFoods.serverUpdatedAt);
            await m.createTable(schema.syncState);
          },
        ),
      );

  /// The tables holding user data, i.e. carrying [SyncColumns] (everything
  /// except the `sync_state` bookkeeping table).
  List<TableInfo<Table, dynamic>> get userTables =>
      [foodLogEntries, waterLogs, weightEntries, customFoods];

  /// Physically deletes every row of every table ("Tüm verilerimi sil").
  /// Soft deletion doesn't apply here: the user asked for the data to go.
  Future<void> wipeAllData() => transaction(() async {
        for (final table in allTables) {
          await delete(table).go();
        }
      });

  /// Permanently removes rows soft-deleted more than [retention] before
  /// [now]. Run at startup. With [requireSynced] (signed in, cloud sync on)
  /// a deletion is only purged once it reached the cloud
  /// (`synced_at >= deleted_at`); otherwise other devices would never
  /// learn about it.
  Future<void> purgeSoftDeleted(
    DateTime now, {
    Duration retention = const Duration(days: 30),
    bool requireSynced = false,
  }) {
    final cutoff = now.toUtc().subtract(retention).millisecondsSinceEpoch;
    final syncedClause =
        requireSynced ? ' AND synced_at IS NOT NULL AND synced_at >= deleted_at' : '';
    return transaction(() async {
      for (final table in userTables) {
        await customUpdate(
          'DELETE FROM ${table.actualTableName} '
          'WHERE deleted_at IS NOT NULL AND deleted_at < ?$syncedClause',
          variables: [Variable.withInt(cutoff)],
          updates: {table},
          updateKind: UpdateKind.delete,
        );
      }
    });
  }
}
