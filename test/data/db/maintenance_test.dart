import 'package:denge/data/db/app_database.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  final now = DateTime.utc(2026, 10, 7, 12);
  int daysAgo(int d) =>
      now.subtract(Duration(days: d)).millisecondsSinceEpoch;

  Future<void> seed() async {
    Future<void> food(String id, int? deletedAt) =>
        db.foodLogDao.insertEntry(FoodLogEntriesCompanion.insert(
          id: id, createdAt: 0, updatedAt: 0, deletedAt: Value(deletedAt),
          date: '2026-09-01', meal: 'lunch', foodName: id,
          servingLabel: '1', amount: 1, kcal: 1, proteinG: 0, carbsG: 0,
          fatG: 0, source: 'catalog', loggedAt: 0,
        ));
    await food('alive', null);
    await food('deleted-31d', daysAgo(31));
    await food('deleted-29d', daysAgo(29));
    await db.waterDao.setGlasses('w', '2026-10-07', 3, now);
    await db.weightDao.insertEntry(WeightEntriesCompanion.insert(
        id: 'kg-old', createdAt: 0, updatedAt: 0,
        deletedAt: Value(daysAgo(45)), date: '2026-08-01', kg: 70,
        measuredAt: 0));
    await db.into(db.customFoods).insert(CustomFoodsCompanion.insert(
        id: 'cf-old', createdAt: 0, updatedAt: 0,
        deletedAt: Value(daysAgo(40)), name: 'X', servingLabel: '1',
        kcalPerServing: 1, proteinG: 0, carbsG: 0, fatG: 0, category: 'tatli'));
  }

  test('purgeSoftDeleted removes rows deleted more than 30 days ago',
      () async {
    await seed();
    await db.purgeSoftDeleted(now);

    final foods = await db.select(db.foodLogEntries).get();
    expect(foods.map((r) => r.id).toSet(), {'alive', 'deleted-29d'});
    expect(await db.select(db.weightEntries).get(), isEmpty);
    expect(await db.select(db.customFoods).get(), isEmpty);
    expect(await db.select(db.waterLogs).get(), hasLength(1),
        reason: 'rows that were never deleted stay');
  });

  test('wipeAllData physically empties every table', () async {
    await seed();
    await db.wipeAllData();
    for (final table in db.allTables) {
      expect(await db.select(table).get(), isEmpty,
          reason: table.actualTableName);
    }
  });
}
