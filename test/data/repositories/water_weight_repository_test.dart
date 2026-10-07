import 'package:denge/data/db/app_database.dart';
import 'package:denge/data/repositories/water_repository.dart';
import 'package:denge/data/repositories/weight_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  group('WaterRepository', () {
    test('missing day reads as 0, writes upsert', () async {
      final repo = WaterRepository(db);
      final now = DateTime(2026, 10, 7, 10);
      expect(await repo.glassesFor('2026-10-07'), 0);
      await repo.setGlasses('2026-10-07', 4, now);
      await repo.setGlasses('2026-10-07', 6, now);
      expect(await repo.glassesFor('2026-10-07'), 6);
      expect(await db.select(db.waterLogs).get(), hasLength(1));
      expect(await repo.watchGlasses('2026-10-07').first, 6);
    });
  });

  group('WeightRepository', () {
    test('addEntry stores the local day and the instant', () async {
      final repo = WeightRepository(db);
      final now = DateTime(2026, 10, 7, 23, 30);
      final saved = await repo.addEntry(70.5, now);
      expect(saved.kg, 70.5);
      expect(saved.date, now);

      final row = (await db.select(db.weightEntries).get()).single;
      expect(row.date, '2026-10-07');
      expect(row.measuredAt, now.toUtc().millisecondsSinceEpoch);
      expect(row.id, hasLength(36));
    });

    test('history is oldest first, latest is the newest', () async {
      final repo = WeightRepository(db);
      await repo.addEntry(72, DateTime(2026, 10, 1, 8));
      await repo.addEntry(70, DateTime(2026, 10, 7, 8));
      await repo.addEntry(71, DateTime(2026, 10, 4, 8));
      expect((await repo.history()).map((e) => e.kg), [72, 71, 70]);
      expect((await repo.latest())!.kg, 70);
      expect(
          (await repo.history(from: DateTime(2026, 10, 4))).map((e) => e.kg),
          [71, 70]);
      expect((await repo.watchHistory().first).length, 3);
    });
  });
}
