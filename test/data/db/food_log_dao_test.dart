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

  group('edit', () {
    final now = DateTime.utc(2026, 10, 7, 12);
    final nowMs = now.millisecondsSinceEpoch;

    test('softDelete hides the row, restore brings it back', () async {
      await db.foodLogDao.insertEntry(row('a', '2026-10-07'));
      await db.foodLogDao.softDelete('a', now);
      expect(await db.foodLogDao.entriesForDate('2026-10-07'), isEmpty);
      expect(await db.foodLogDao.datesWithEntries(), isEmpty);

      final deleted = await (db.select(db.foodLogEntries)
            ..where((t) => t.id.equals('a')))
          .getSingle();
      expect(deleted.deletedAt, nowMs);
      expect(deleted.updatedAt, nowMs);

      await db.foodLogDao.restore('a', now.add(const Duration(seconds: 3)));
      final restored =
          (await db.foodLogDao.entriesForDate('2026-10-07')).single;
      expect(restored.deletedAt, isNull);
      expect(restored.updatedAt, nowMs + 3000);
    });

    test('updateAmount rescales kcal and macros proportionally', () async {
      await db.foodLogDao.insertEntry(row('a', '2026-10-07'));
      // row(): amount 1, 100 kcal, P1 C2 F3.
      await db.foodLogDao.updateAmount('a', 2.5, now);
      final r = (await db.foodLogDao.entriesForDate('2026-10-07')).single;
      expect(r.amount, 2.5);
      expect(r.kcal, 250);
      expect(r.proteinG, closeTo(2.5, 1e-9));
      expect(r.carbsG, closeTo(5, 1e-9));
      expect(r.fatG, closeTo(7.5, 1e-9));
      expect(r.updatedAt, nowMs);
    });

    test('updateAmount scales from the current amount, not from 1', () async {
      await db.foodLogDao.insertEntry(row('a', '2026-10-07'));
      await db.foodLogDao.updateAmount('a', 2, now);
      await db.foodLogDao.updateAmount('a', 0.5, now);
      final r = (await db.foodLogDao.entriesForDate('2026-10-07')).single;
      expect(r.kcal, 50);
      expect(r.fatG, closeTo(1.5, 1e-9));
    });

    test('updateMeal moves the entry to another meal', () async {
      await db.foodLogDao.insertEntry(row('a', '2026-10-07'));
      await db.foodLogDao.updateMeal('a', 'dinner', now);
      final r = (await db.foodLogDao.entriesForDate('2026-10-07')).single;
      expect(r.meal, 'dinner');
      expect(r.updatedAt, nowMs);
    });
  });
}
