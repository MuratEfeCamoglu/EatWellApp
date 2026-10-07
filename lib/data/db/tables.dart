import 'package:drift/drift.dart';

/// Columns every user table carries so cloud sync can be added later
/// without a schema change (see CLAUDE.md §5.1). All instants are UTC
/// milliseconds since epoch.
mixin SyncColumns on Table {
  /// UUID v4 generated on the device.
  TextColumn get id => text()();
  IntColumn get createdAt => integer()();

  /// Refreshed on every change; the future sync's "last write wins" key.
  IntColumn get updatedAt => integer()();

  /// Soft-delete marker: rows are hidden rather than removed so a delete
  /// can still be propagated to other devices.
  IntColumn get deletedAt => integer().nullable()();

  /// Always null until a cloud backend exists.
  IntColumn get syncedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// One food added to the diary. Name, serving and nutrition are copied at
/// log time so later catalog edits never rewrite past days.
@DataClassName('FoodLogRow')
@TableIndex(name: 'food_log_date_meal', columns: {#date, #meal})
@TableIndex(name: 'food_log_date', columns: {#date})
class FoodLogEntries extends Table with SyncColumns {
  /// Local day, `yyyy-MM-dd`.
  TextColumn get date => text()();

  /// `MealType.name`.
  TextColumn get meal => text()();
  TextColumn get foodName => text()();
  TextColumn get brand => text().withDefault(const Constant(''))();
  TextColumn get servingLabel => text()();

  /// Multiplier of the serving described by [servingLabel].
  RealColumn get amount => real()();

  /// Totals for [amount] servings, frozen at log time.
  IntColumn get kcal => integer()();
  RealColumn get proteinG => real()();
  RealColumn get carbsG => real()();
  RealColumn get fatG => real()();

  /// `catalog` / `recipe` / `barcode` / `photo` / `custom`.
  TextColumn get source => text()();

  /// Barcode number or `custom_foods.id`, depending on [source].
  TextColumn get sourceRef => text().nullable()();

  /// When the food was added, UTC ms; orders entries within a day.
  IntColumn get loggedAt => integer()();
}

/// Glasses of water drunk on a local day; one row per day.
@DataClassName('WaterLogRow')
class WaterLogs extends Table with SyncColumns {
  TextColumn get date => text().unique()();
  IntColumn get glasses => integer()();
}

/// Every weight measurement; several per day are all kept and charts use
/// the latest one of each day.
@DataClassName('WeightRow')
class WeightEntries extends Table with SyncColumns {
  TextColumn get date => text()();
  RealColumn get kg => real()();
  IntColumn get measuredAt => integer()();
}

/// Foods the user created themselves (not in the bundled catalog).
@DataClassName('CustomFoodRow')
class CustomFoods extends Table with SyncColumns {
  TextColumn get name => text()();
  TextColumn get brand => text().withDefault(const Constant(''))();
  TextColumn get servingLabel => text()();
  IntColumn get kcalPerServing => integer()();
  RealColumn get proteinG => real()();
  RealColumn get carbsG => real()();
  RealColumn get fatG => real()();

  /// `FoodCategory.name`.
  TextColumn get category => text()();

  /// Set when the food was saved from an unrecognised barcode scan.
  TextColumn get barcode => text().nullable()();
}
