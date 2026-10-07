import 'package:denge/data/db/app_database.dart';
import 'package:denge/data/models.dart';
import 'package:denge/data/repositories/food_log_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../food_log_entry_test.dart' show menemen;

void main() {
  late AppDatabase db;
  late FoodLogRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = FoodLogRepository(db);
  });
  tearDown(() => db.close());

  test('add assigns a UUID and timestamps, and round-trips every field',
      () async {
    final now = DateTime(2026, 10, 7, 13, 5);
    final draft = FoodLogEntry.fromFood(menemen, 2, MealType.lunch, now,
        source: FoodLogSource.barcode, sourceRef: '123');
    final saved = await repo.add(draft, now);

    expect(saved.id, matches(RegExp(r'^[0-9a-f-]{36}$')));
    final row = (await db.foodLogDao.entriesForDate('2026-10-07')).single;
    expect(row.createdAt, now.toUtc().millisecondsSinceEpoch);
    expect(row.updatedAt, row.createdAt);
    expect(row.deletedAt, isNull);
    expect(row.syncedAt, isNull);
    expect(row.source, 'barcode');

    final read = (await repo.entriesForDate('2026-10-07')).single;
    expect(read.id, saved.id);
    expect(read.meal, MealType.lunch);
    expect(read.foodName, 'Menemen');
    expect(read.brand, 'Ev yapımı');
    expect(read.amount, 2);
    expect(read.kcal, 240);
    expect(read.proteinG, closeTo(13, 1e-9));
    expect(read.source, FoodLogSource.barcode);
    expect(read.sourceRef, '123');
    expect(read.loggedAt, now.toUtc());
  });

  test('two adds get distinct ids', () async {
    final now = DateTime(2026, 10, 7);
    final a = await repo.add(
        FoodLogEntry.fromFood(menemen, 1, MealType.lunch, now), now);
    final b = await repo.add(
        FoodLogEntry.fromFood(menemen, 1, MealType.lunch, now), now);
    expect(a.id, isNot(b.id));
  });

  test('watchDate maps rows to entries', () async {
    final now = DateTime(2026, 10, 7);
    await repo.add(FoodLogEntry.fromFood(menemen, 1, MealType.snack, now), now);
    final list = await repo.watchDate('2026-10-07').first;
    expect(list.single.meal, MealType.snack);
  });
}
