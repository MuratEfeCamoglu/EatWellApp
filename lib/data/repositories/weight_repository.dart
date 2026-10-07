import 'package:uuid/uuid.dart';

import '../db/app_database.dart';
import '../db/date_key.dart';
import '../models.dart';

/// Weight measurements as [WeightEntry] models (date = local measurement
/// time). Several per day are all kept; charts pick the last of each day.
class WeightRepository {
  WeightRepository(this._db, {Uuid uuid = const Uuid()}) : _uuid = uuid;

  final AppDatabase _db;
  final Uuid _uuid;

  /// Records [kg] measured at [now].
  Future<WeightEntry> addEntry(double kg, DateTime now) async {
    final ms = now.toUtc().millisecondsSinceEpoch;
    await _db.weightDao.insertEntry(WeightEntriesCompanion.insert(
      id: _uuid.v4(),
      createdAt: ms,
      updatedAt: ms,
      date: dateKey(now),
      kg: kg,
      measuredAt: ms,
    ));
    return WeightEntry(now, kg);
  }

  Future<List<WeightEntry>> history({DateTime? from}) async =>
      (await _db.weightDao.history(from: from == null ? null : dateKey(from)))
          .map(_toModel)
          .toList();

  Stream<List<WeightEntry>> watchHistory({DateTime? from}) => _db.weightDao
      .watchHistory(from: from == null ? null : dateKey(from))
      .map((rows) => rows.map(_toModel).toList());

  Future<WeightEntry?> latest() async {
    final row = await _db.weightDao.latest();
    return row == null ? null : _toModel(row);
  }

  static WeightEntry _toModel(WeightRow row) => WeightEntry(
        DateTime.fromMillisecondsSinceEpoch(row.measuredAt, isUtc: true)
            .toLocal(),
        row.kg,
      );
}
