import 'package:denge/data/db/app_database.dart';
import 'package:denge/data/models.dart';
import 'package:denge/data/repositories/food_log_repository.dart';
import 'package:denge/data/repositories/water_repository.dart';
import 'package:denge/data/repositories/weight_repository.dart';
import 'package:denge/data/sync/sync_backend.dart';
import 'package:denge/data/sync/sync_engine.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_sync_backend.dart';
import '../food_log_entry_test.dart' show menemen;

void main() {
  late AppDatabase db;
  late FakeSyncBackend cloud;
  late SyncEngine engine;
  final now = DateTime(2026, 10, 8, 12);

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    cloud = FakeSyncBackend();
    engine = SyncEngine(db, cloud);
  });
  tearDown(() => db.close());

  Future<FoodLogEntry> addFood(DateTime at) => FoodLogRepository(db)
      .add(FoodLogEntry.fromFood(menemen, 1, MealType.lunch, at), at);

  test('new rows of every table are pushed and marked synced', () async {
    final food = await addFood(now);
    await WaterRepository(db).setGlasses('2026-10-08', 3, now);
    await WeightRepository(db).addEntry(70.5, now);

    final result = await engine.push();
    expect(result.pushed, 3);
    expect(result.failed, 0);

    final cloudFood = cloud.table('food_log_entries')[food.id]!;
    expect(cloudFood['food_name'], 'Menemen');
    expect(cloudFood['kcal'], 120);
    expect(cloudFood['meal'], 'lunch');
    expect(cloudFood.containsKey('user_id'), isFalse,
        reason: 'the server fills user_id from the session');
    expect(cloud.table('water_logs').values.single['glasses'], 3);
    expect(cloud.table('weight_entries').values.single['kg'], 70.5);

    final row = (await db.select(db.foodLogEntries).get()).single;
    expect(row.syncedAt, row.updatedAt);
    expect(row.serverUpdatedAt, isNotNull);

    // Nothing left to send.
    expect((await engine.push()).pushed, 0);
  });

  test('an edit after a push is pushed again (and a delete propagates)',
      () async {
    final food = await addFood(now);
    await engine.push();

    await db.foodLogDao
        .softDelete(food.id, now.add(const Duration(minutes: 1)));
    final result = await engine.push();
    expect(result.pushed, 1);
    expect(cloud.table('food_log_entries')[food.id]!['deleted_at'], isNotNull);
  });

  test('a row changed while it was being sent stays dirty', () async {
    final food = await addFood(now);
    final pushedAt = (await db.select(db.foodLogEntries).get()).single.updatedAt;
    // The user edits the entry before the push result comes back.
    await db.foodLogDao.updateAmount(food.id, 2, now.add(const Duration(seconds: 5)));

    await db.syncDao.markSynced(db.foodLogEntries, food.id,
        pushedUpdatedAt: pushedAt, serverUpdatedAt: 99);
    final row = (await db.select(db.foodLogEntries).get()).single;
    expect(row.syncedAt, isNull, reason: 'the newer edit must still go out');
  });

  test('network failure leaves everything dirty and reports it', () async {
    await addFood(now);
    cloud.failWith = Exception('offline');
    await expectLater(engine.push(), throwsA(isA<Exception>()));
    expect((await db.select(db.foodLogEntries).get()).single.syncedAt, isNull);

    cloud.failWith = null;
    expect((await engine.push()).pushed, 1);
  });

  test('many rows go in batches of 100', () async {
    for (var i = 0; i < 250; i++) {
      await addFood(now.add(Duration(seconds: i)));
    }
    final result = await engine.push();
    expect(result.pushed, 250);
    expect(cloud.batches.where((b) => b.$1 == 'food_log_entries').map((b) => b.$2),
        [100, 100, 50]);
  });

  test('one rejected row does not block the others', () async {
    final good = await addFood(now);
    final bad = await addFood(now.add(const Duration(seconds: 1)));
    cloud.rejectIds.add(bad.id);

    final result = await engine.push();
    expect(result.pushed, 1);
    expect(result.failed, 1);
    expect(cloud.table('food_log_entries').keys, [good.id]);
    final rows = {
      for (final r in await db.select(db.foodLogEntries).get()) r.id: r
    };
    expect(rows[good.id]!.syncedAt, isNotNull);
    expect(rows[bad.id]!.syncedAt, isNull, reason: 'retried next time');
  });

  test('water adopts the server id when another device made that day first',
      () async {
    cloud.table('water_logs')['server-id'] = {
      'id': 'server-id',
      'date': '2026-10-08',
      'glasses': 5,
      'created_at': 1,
      'updated_at': 1,
      'deleted_at': null,
      'server_updated_at': 10,
    };
    await WaterRepository(db).setGlasses('2026-10-08', 2, now);
    await engine.push();

    final local = (await db.select(db.waterLogs).get()).single;
    expect(local.id, 'server-id');
    expect(local.glasses, 2, reason: 'ours was newer');
    expect(local.syncedAt, local.updatedAt);
    expect(cloud.table('water_logs').values.single['glasses'], 2);
  });

  test('water from the server wins when it is newer', () async {
    await WaterRepository(db).setGlasses('2026-10-08', 2, now);
    cloud.table('water_logs')['server-id'] = {
      'id': 'server-id',
      'date': '2026-10-08',
      'glasses': 7,
      'created_at': 1,
      'updated_at': now.add(const Duration(hours: 1)).toUtc().millisecondsSinceEpoch,
      'deleted_at': null,
      'server_updated_at': 10,
    };
    await engine.push();
    final local = (await db.select(db.waterLogs).get()).single;
    expect(local.id, 'server-id');
    expect(local.glasses, 7);
    expect(local.syncedAt, local.updatedAt, reason: 'nothing left to send');
  });

  test('custom foods are pushed with their category name', () async {
    await db.into(db.customFoods).insert(CustomFoodsCompanion.insert(
          id: 'c1', createdAt: 1, updatedAt: 2, name: 'Börek',
          servingLabel: '1 dilim', kcalPerServing: 310, proteinG: 9,
          carbsG: 30, fatG: 17, category: 'hamurIsi',
          barcode: const Value('869'),
        ));
    await engine.push();
    final row = cloud.table('custom_foods')['c1']!;
    expect(row['category'], 'hamurIsi');
    expect(row['kcal_per_serving'], 310);
    expect(row['barcode'], '869');
  });

  test('SyncRejected is the data-error type backends throw', () {
    expect(const SyncRejected('x').toString(), contains('x'));
  });
}
