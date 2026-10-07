import 'package:denge/data/db/app_database.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

WeightEntriesCompanion weight(String id, String date, double kg, int at,
        {int? deletedAt}) =>
    WeightEntriesCompanion.insert(
      id: id,
      createdAt: at,
      updatedAt: at,
      deletedAt: Value(deletedAt),
      date: date,
      kg: kg,
      measuredAt: at,
    );

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('history is ordered by measured_at regardless of insert order',
      () async {
    await db.weightDao.insertEntry(weight('c', '2026-10-07', 70, 300));
    await db.weightDao.insertEntry(weight('a', '2026-10-01', 72, 100));
    await db.weightDao.insertEntry(weight('b', '2026-10-04', 71, 200));
    final rows = await db.weightDao.history();
    expect(rows.map((r) => r.id), ['a', 'b', 'c']);
  });

  test('history skips deleted rows and honours from', () async {
    await db.weightDao.insertEntry(weight('a', '2026-09-20', 73, 100));
    await db.weightDao.insertEntry(weight('b', '2026-10-04', 71, 200));
    await db.weightDao
        .insertEntry(weight('x', '2026-10-05', 99, 250, deletedAt: 1));
    expect((await db.weightDao.history(from: '2026-10-01')).map((r) => r.id),
        ['b']);
  });

  test('latest returns the newest measurement or null', () async {
    expect(await db.weightDao.latest(), isNull);
    await db.weightDao.insertEntry(weight('a', '2026-10-07', 70.4, 200));
    await db.weightDao.insertEntry(weight('b', '2026-10-07', 70.1, 300));
    await db.weightDao.insertEntry(weight('c', '2026-10-06', 71, 100));
    expect((await db.weightDao.latest())!.id, 'b');
  });

  test('watchHistory emits after an insert', () async {
    final expectation = expectLater(
      db.weightDao.watchHistory().map((r) => r.length),
      emitsInOrder([0, 1]),
    );
    await pumpEventQueue();
    await db.weightDao.insertEntry(weight('a', '2026-10-07', 70, 1));
    await expectation;
  });
}
