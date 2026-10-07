import 'package:denge/data/db/app_database.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

FoodLogEntriesCompanion row(String id, String date,
        {int loggedAt = 0, int? deletedAt, String meal = 'lunch'}) =>
    FoodLogEntriesCompanion.insert(
      id: id,
      createdAt: loggedAt,
      updatedAt: loggedAt,
      deletedAt: Value(deletedAt),
      date: date,
      meal: meal,
      foodName: 'Yemek $id',
      servingLabel: '1 porsiyon',
      amount: 1,
      kcal: 100,
      proteinG: 1,
      carbsG: 2,
      fatG: 3,
      source: 'catalog',
      loggedAt: loggedAt,
    );

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('insert then read back for that date', () async {
    await db.foodLogDao.insertEntry(row('a', '2026-10-07'));
    final rows = await db.foodLogDao.entriesForDate('2026-10-07');
    expect(rows.single.id, 'a');
    expect(rows.single.foodName, 'Yemek a');
  });

  test('entries of another day are not returned', () async {
    await db.foodLogDao.insertEntry(row('a', '2026-10-07'));
    await db.foodLogDao.insertEntry(row('b', '2026-10-06'));
    final rows = await db.foodLogDao.entriesForDate('2026-10-07');
    expect(rows.map((r) => r.id), ['a']);
  });

  test('soft-deleted entries are not returned', () async {
    await db.foodLogDao.insertEntry(row('a', '2026-10-07'));
    await db.foodLogDao.insertEntry(row('b', '2026-10-07', deletedAt: 5));
    final rows = await db.foodLogDao.entriesForDate('2026-10-07');
    expect(rows.map((r) => r.id), ['a']);
  });

  test('entries are ordered by logged_at', () async {
    await db.foodLogDao.insertEntry(row('late', '2026-10-07', loggedAt: 20));
    await db.foodLogDao.insertEntry(row('early', '2026-10-07', loggedAt: 10));
    final rows = await db.foodLogDao.entriesForDate('2026-10-07');
    expect(rows.map((r) => r.id), ['early', 'late']);
  });

  test('watchEntriesForDate emits again after an insert', () async {
    final stream = db.foodLogDao.watchEntriesForDate('2026-10-07');
    final expectation = expectLater(
      stream.map((rows) => rows.map((r) => r.id).toList()),
      emitsInOrder([<String>[], ['a']]),
    );
    await pumpEventQueue();
    await db.foodLogDao.insertEntry(row('a', '2026-10-07'));
    await expectation;
  });

  test('datesWithEntries is distinct, skips deleted and honours range',
      () async {
    await db.foodLogDao.insertEntry(row('a', '2026-10-05'));
    await db.foodLogDao.insertEntry(row('b', '2026-10-07'));
    await db.foodLogDao.insertEntry(row('c', '2026-10-07'));
    await db.foodLogDao.insertEntry(row('d', '2026-10-06', deletedAt: 1));
    await db.foodLogDao.insertEntry(row('e', '2026-09-30'));

    expect(await db.foodLogDao.datesWithEntries(),
        {'2026-09-30', '2026-10-05', '2026-10-07'});
    expect(
        await db.foodLogDao
            .datesWithEntries(from: '2026-10-01', to: '2026-10-06'),
        {'2026-10-05'});
  });
}
