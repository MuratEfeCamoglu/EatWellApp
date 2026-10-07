// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_log_dao.dart';

// ignore_for_file: type=lint
mixin _$FoodLogDaoMixin on DatabaseAccessor<AppDatabase> {
  $FoodLogEntriesTable get foodLogEntries => attachedDatabase.foodLogEntries;
  FoodLogDaoManager get managers => FoodLogDaoManager(this);
}

class FoodLogDaoManager {
  final _$FoodLogDaoMixin _db;
  FoodLogDaoManager(this._db);
  $$FoodLogEntriesTableTableManager get foodLogEntries =>
      $$FoodLogEntriesTableTableManager(
        _db.attachedDatabase,
        _db.foodLogEntries,
      );
}
