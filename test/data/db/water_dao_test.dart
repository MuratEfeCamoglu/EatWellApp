import 'package:denge/data/db/app_database.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  final t1 = DateTime.utc(2026, 10, 7, 9);
  final t2 = DateTime.utc(2026, 10, 7, 15);

  test('no row means null for that day', () async {
    expect(await db.waterDao.glassesForDate('2026-10-07'), isNull);
  });

  test('writing the same day twice keeps a single row (upsert)', () async {
    await db.waterDao.setGlasses('id-1', '2026-10-07', 3, t1);
    await db.waterDao.setGlasses('id-2', '2026-10-07', 5, t2);

    final rows = await db.select(db.waterLogs).get();
    expect(rows, hasLength(1));
    expect(rows.single.id, 'id-1', reason: 'the first id is kept');
    expect(rows.single.glasses, 5);
    expect(rows.single.createdAt, t1.millisecondsSinceEpoch);
    expect(rows.single.updatedAt, t2.millisecondsSinceEpoch);
    expect(await db.waterDao.glassesForDate('2026-10-07'), 5);
  });

  test('different days are separate rows', () async {
    await db.waterDao.setGlasses('a', '2026-10-06', 8, t1);
    await db.waterDao.setGlasses('b', '2026-10-07', 2, t2);
    expect(await db.waterDao.glassesForDate('2026-10-06'), 8);
    expect(await db.waterDao.glassesForDate('2026-10-07'), 2);
  });

  test('a soft-deleted day reads as empty and is revived by a write',
      () async {
    await db.waterDao.setGlasses('a', '2026-10-07', 4, t1);
    await (db.update(db.waterLogs)..where((t) => t.id.equals('a')))
        .write(const WaterLogsCompanion(deletedAt: Value(1)));
    expect(await db.waterDao.glassesForDate('2026-10-07'), isNull);

    await db.waterDao.setGlasses('b', '2026-10-07', 1, t2);
    expect(await db.waterDao.glassesForDate('2026-10-07'), 1);
  });

  test('watchGlassesForDate emits the new value after a write', () async {
    final expectation = expectLater(
      db.waterDao.watchGlassesForDate('2026-10-07'),
      emitsInOrder([null, 2]),
    );
    await pumpEventQueue();
    await db.waterDao.setGlasses('a', '2026-10-07', 2, t1);
    await expectation;
  });
}
