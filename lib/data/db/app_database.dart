import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'daos/food_log_dao.dart';
import 'daos/water_dao.dart';
import 'daos/weight_dao.dart';
import 'tables.dart';

part 'app_database.g.dart';

/// The on-device SQLite database holding the user's diary, water and
/// weight logs. Screens never touch it directly — they go through
/// [AppState], which goes through the repositories.
@DriftDatabase(
  tables: [FoodLogEntries, WaterLogs, WeightEntries, CustomFoods],
  daos: [FoodLogDao, WaterDao, WeightDao],
)
class AppDatabase extends _$AppDatabase {
  /// The real database file, `denge.sqlite` in the documents directory.
  AppDatabase() : super(driftDatabase(name: 'denge'));

  /// Tests pass `NativeDatabase.memory()` here.
  AppDatabase.forTesting(super.executor);

  /// Bump on every schema change and add a matching `onUpgrade` step;
  /// never edit a released schema in place (CLAUDE.md §8).
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
      );
}
