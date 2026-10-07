import 'package:uuid/uuid.dart';

import '../db/app_database.dart';

/// Daily water glasses; a day without a row simply counts as 0.
class WaterRepository {
  WaterRepository(this._db, {Uuid uuid = const Uuid()}) : _uuid = uuid;

  final AppDatabase _db;
  final Uuid _uuid;

  Future<int> glassesFor(String date) async =>
      await _db.waterDao.glassesForDate(date) ?? 0;

  Stream<int> watchGlasses(String date) =>
      _db.waterDao.watchGlassesForDate(date).map((g) => g ?? 0);

  /// Upserts [date]'s row; [now] stamps `created_at`/`updated_at`.
  Future<void> setGlasses(String date, int glasses, DateTime now) =>
      _db.waterDao.setGlasses(_uuid.v4(), date, glasses, now);
}
