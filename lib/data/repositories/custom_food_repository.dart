import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../custom_food.dart';
import '../db/app_database.dart';
import '../models.dart';

/// The user's own foods as [CustomFood] models; owns ids and timestamps.
class CustomFoodRepository {
  CustomFoodRepository(this._db, {Uuid uuid = const Uuid()}) : _uuid = uuid;

  final AppDatabase _db;
  final Uuid _uuid;

  Future<CustomFood> add(CustomFood draft, DateTime now) async {
    final food = draft.copyWith(id: _uuid.v4());
    final ms = now.toUtc().millisecondsSinceEpoch;
    await _db.customFoodDao.insertFood(CustomFoodsCompanion.insert(
      id: food.id,
      createdAt: ms,
      updatedAt: ms,
      name: food.name,
      brand: Value(food.brand),
      servingLabel: food.servingLabel,
      kcalPerServing: food.kcalPerServing,
      proteinG: food.proteinG,
      carbsG: food.carbsG,
      fatG: food.fatG,
      category: food.category.name,
      barcode: Value(food.barcode),
    ));
    return food;
  }

  /// Saves [food]'s editable fields; `created_at` and the id stay as is.
  Future<void> update(CustomFood food, DateTime now) =>
      _db.customFoodDao.updateFood(
        food.id,
        CustomFoodsCompanion(
          name: Value(food.name),
          brand: Value(food.brand),
          servingLabel: Value(food.servingLabel),
          kcalPerServing: Value(food.kcalPerServing),
          proteinG: Value(food.proteinG),
          carbsG: Value(food.carbsG),
          fatG: Value(food.fatG),
          category: Value(food.category.name),
          updatedAt: Value(now.toUtc().millisecondsSinceEpoch),
        ),
      );

  Future<void> delete(String id, DateTime now) =>
      _db.customFoodDao.softDelete(id, now);

  Future<List<CustomFood>> all() async =>
      (await _db.customFoodDao.all()).map(_toModel).toList();

  Stream<List<CustomFood>> watchAll() => _db.customFoodDao
      .watchAll()
      .map((rows) => rows.map(_toModel).toList());

  Future<CustomFood?> findByBarcode(String barcode) async {
    final row = await _db.customFoodDao.byBarcode(barcode);
    return row == null ? null : _toModel(row);
  }

  static CustomFood _toModel(CustomFoodRow row) => CustomFood(
        id: row.id,
        name: row.name,
        brand: row.brand,
        servingLabel: row.servingLabel,
        kcalPerServing: row.kcalPerServing,
        proteinG: row.proteinG,
        carbsG: row.carbsG,
        fatG: row.fatG,
        category: FoodCategory.values.asNameMap()[row.category] ??
            FoodCategory.atistirmalik,
        barcode: row.barcode,
      );
}
