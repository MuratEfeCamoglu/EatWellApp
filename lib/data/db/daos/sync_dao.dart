import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'sync_dao.g.dart';

/// Bookkeeping SQL for cloud sync, shared by every user table: which rows
/// still have to go out and which are confirmed.
@DriftAccessor(
    tables: [FoodLogEntries, WaterLogs, WeightEntries, CustomFoods, SyncState])
class SyncDao extends DatabaseAccessor<AppDatabase> with _$SyncDaoMixin {
  SyncDao(super.attachedDatabase);

  /// Up to [limit] rows of [table] never pushed or changed since
  /// (`synced_at IS NULL OR updated_at > synced_at`), oldest change first.
  Future<List<D>> dirtyRows<T extends Table, D>(TableInfo<T, D> table,
      {int limit = 100}) async {
    final rows = await customSelect(
      'SELECT * FROM ${table.actualTableName} '
      'WHERE synced_at IS NULL OR updated_at > synced_at '
      'ORDER BY updated_at LIMIT ?',
      variables: [Variable.withInt(limit)],
      readsFrom: {table},
    ).get();
    return [for (final r in rows) await table.map(r.data)];
  }

  /// Marks the row as being in the cloud — but only if it still has the
  /// [pushedUpdatedAt] that was sent. An edit made while the push was in
  /// flight keeps the row dirty so it goes out next time.
  Future<void> markSynced(
    TableInfo<Table, dynamic> table,
    String id, {
    required int pushedUpdatedAt,
    required int serverUpdatedAt,
  }) =>
      customUpdate(
        'UPDATE ${table.actualTableName} '
        'SET synced_at = ?, server_updated_at = ? '
        'WHERE id = ? AND updated_at = ?',
        variables: [
          Variable.withInt(pushedUpdatedAt),
          Variable.withInt(serverUpdatedAt),
          Variable.withString(id),
          Variable.withInt(pushedUpdatedAt),
        ],
        updates: {table},
      );

  /// Replaces the local water row [localId] with the row the server stored
  /// for that day (another device may have created the day first, under
  /// another id; the newer write already won on the server). Skipped if
  /// the local row changed after [pushedUpdatedAt].
  Future<void> adoptServerWater(
    String localId, {
    required int pushedUpdatedAt,
    required Map<String, Object?> server,
  }) async {
    final serverUpdatedAt = server['updated_at']! as int;
    await (update(waterLogs)
          ..where((t) =>
              t.id.equals(localId) & t.updatedAt.equals(pushedUpdatedAt)))
        .write(WaterLogsCompanion(
      id: Value(server['id']! as String),
      glasses: Value(server['glasses']! as int),
      createdAt: Value(server['created_at']! as int),
      updatedAt: Value(serverUpdatedAt),
      deletedAt: Value(server['deleted_at'] as int?),
      syncedAt: Value(serverUpdatedAt),
      serverUpdatedAt: Value(server['server_updated_at']! as int),
    ));
  }
}
