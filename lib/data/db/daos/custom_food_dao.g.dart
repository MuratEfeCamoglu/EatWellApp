// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_food_dao.dart';

// ignore_for_file: type=lint
mixin _$CustomFoodDaoMixin on DatabaseAccessor<AppDatabase> {
  $CustomFoodsTable get customFoods => attachedDatabase.customFoods;
  CustomFoodDaoManager get managers => CustomFoodDaoManager(this);
}

class CustomFoodDaoManager {
  final _$CustomFoodDaoMixin _db;
  CustomFoodDaoManager(this._db);
  $$CustomFoodsTableTableManager get customFoods =>
      $$CustomFoodsTableTableManager(_db.attachedDatabase, _db.customFoods);
}
