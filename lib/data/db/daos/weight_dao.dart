import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'weight_dao.g.dart';

/// SQL for `weight_entries`. Every read hides soft-deleted rows.
@DriftAccessor(tables: [WeightEntries])
class WeightDao extends DatabaseAccessor<AppDatabase> with _$WeightDaoMixin {
  WeightDao(super.attachedDatabase);

  Future<void> insertEntry(WeightEntriesCompanion entry) =>
      into(weightEntries).insert(entry);

  SimpleSelectStatement<$WeightEntriesTable, WeightRow> _history(
      String? from) {
    return select(weightEntries)
      ..where((t) {
        final alive = t.deletedAt.isNull();
        return from == null ? alive : alive & t.date.isBiggerOrEqualValue(from);
      })
      ..orderBy([(t) => OrderingTerm.asc(t.measuredAt)]);
  }

  /// Measurements oldest first, optionally only from day [from] on.
  Future<List<WeightRow>> history({String? from}) => _history(from).get();

  Stream<List<WeightRow>> watchHistory({String? from}) =>
      _history(from).watch();

  Future<WeightRow?> latest() => (select(weightEntries)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.desc(t.measuredAt)])
        ..limit(1))
      .getSingleOrNull();
}
