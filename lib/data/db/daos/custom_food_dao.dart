import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'custom_food_dao.g.dart';

/// SQL for `custom_foods`. Every read hides soft-deleted rows.
@DriftAccessor(tables: [CustomFoods])
class CustomFoodDao extends DatabaseAccessor<AppDatabase>
    with _$CustomFoodDaoMixin {
  CustomFoodDao(super.attachedDatabase);

  Future<void> insertFood(CustomFoodsCompanion food) =>
      into(customFoods).insert(food);

  /// Writes [changes] onto the row with [id].
  Future<void> updateFood(String id, CustomFoodsCompanion changes) =>
      (update(customFoods)..where((t) => t.id.equals(id))).write(changes);

  Future<void> softDelete(String id, DateTime now) {
    final ms = now.toUtc().millisecondsSinceEpoch;
    return updateFood(
      id,
      CustomFoodsCompanion(deletedAt: Value(ms), updatedAt: Value(ms)),
    );
  }

  SimpleSelectStatement<$CustomFoodsTable, CustomFoodRow> _alive() =>
      select(customFoods)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.asc(t.name)]);

  Future<List<CustomFoodRow>> all() => _alive().get();

  Stream<List<CustomFoodRow>> watchAll() => _alive().watch();

  /// The (newest) live food saved for [barcode], if any.
  Future<CustomFoodRow?> byBarcode(String barcode) => (select(customFoods)
        ..where((t) => t.barcode.equals(barcode) & t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
        ..limit(1))
      .getSingleOrNull();
}
