import 'package:denge/data/custom_food.dart';
import 'package:denge/data/db/app_database.dart';
import 'package:denge/data/models.dart';
import 'package:denge/data/repositories/custom_food_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

const draft = CustomFood(
  id: '',
  name: 'Annemin böreği',
  brand: 'Ev',
  servingLabel: '1 dilim (120 g)',
  kcalPerServing: 310,
  proteinG: 9,
  carbsG: 30,
  fatG: 17,
  category: FoodCategory.hamurIsi,
  barcode: '8690000000001',
);

void main() {
  late AppDatabase db;
  late CustomFoodRepository repo;
  final now = DateTime(2026, 10, 7, 12);

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = CustomFoodRepository(db);
  });
  tearDown(() => db.close());

  test('add stores every field with a UUID and timestamps', () async {
    final saved = await repo.add(draft, now);
    expect(saved.id, hasLength(36));

    final row = (await db.customFoodDao.all()).single;
    expect(row.createdAt, now.toUtc().millisecondsSinceEpoch);
    expect(row.category, 'hamurIsi');
    expect(row.syncedAt, isNull);

    final read = (await repo.all()).single;
    expect(read.name, 'Annemin böreği');
    expect(read.brand, 'Ev');
    expect(read.servingLabel, '1 dilim (120 g)');
    expect(read.kcalPerServing, 310);
    expect(read.fatG, 17);
    expect(read.category, FoodCategory.hamurIsi);
    expect(read.barcode, '8690000000001');
  });

  test('update changes fields and updated_at, keeps created_at', () async {
    final saved = await repo.add(draft, now);
    final later = now.add(const Duration(hours: 1));
    await repo.update(saved.copyWith(name: 'Börek', kcalPerServing: 280), later);
    final row = (await db.customFoodDao.all()).single;
    expect(row.name, 'Börek');
    expect(row.kcalPerServing, 280);
    expect(row.createdAt, now.toUtc().millisecondsSinceEpoch);
    expect(row.updatedAt, later.toUtc().millisecondsSinceEpoch);
  });

  test('soft delete hides the food everywhere', () async {
    final saved = await repo.add(draft, now);
    await repo.delete(saved.id, now);
    expect(await repo.all(), isEmpty);
    expect(await repo.findByBarcode('8690000000001'), isNull);
    expect(await db.select(db.customFoods).get(), hasLength(1),
        reason: 'the row itself is kept');
  });

  test('findByBarcode matches only that barcode', () async {
    final saved = await repo.add(draft, now);
    expect((await repo.findByBarcode('8690000000001'))!.id, saved.id);
    expect(await repo.findByBarcode('123'), isNull);
  });

  test('watchAll emits, sorted by name', () async {
    await repo.add(draft.copyWith(name: 'Zeytinli poğaça'), now);
    await repo.add(draft.copyWith(name: 'Ayran'), now);
    final list = await repo.watchAll().first;
    expect(list.map((f) => f.name), ['Ayran', 'Zeytinli poğaça']);
  });
}
