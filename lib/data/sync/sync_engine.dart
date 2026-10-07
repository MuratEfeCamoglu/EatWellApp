import 'dart:developer' as developer;

import 'package:drift/drift.dart' show Table, TableInfo;

import '../db/app_database.dart';
import 'row_mappers.dart';
import 'sync_backend.dart';

/// Outcome of one [SyncEngine.push].
class PushResult {
  const PushResult({this.pushed = 0, this.failed = 0});

  /// Rows now confirmed in the cloud.
  final int pushed;

  /// Rows the server refused; they stay dirty and are retried next time.
  final int failed;

  PushResult operator +(PushResult other) =>
      PushResult(pushed: pushed + other.pushed, failed: failed + other.failed);
}

/// Sends local changes to the cloud (CLAUDE.md §13.4, "Gönder"). Pulling
/// other devices' changes is Aşama B5.
class SyncEngine {
  SyncEngine(this._db, this._backend, {this.batchSize = 100});

  final AppDatabase _db;
  final SyncBackend _backend;
  final int batchSize;

  /// Pushes every dirty row of every table. Throws on network / server
  /// trouble (nothing is marked synced that didn't make it); a row the
  /// server rejects is skipped so it can't block the rest.
  Future<PushResult> push() async {
    var result = const PushResult();
    result += await _pushTable(
        _db.foodLogEntries, 'food_log_entries', foodLogToServer);
    result += await _pushTable(
        _db.weightEntries, 'weight_entries', weightToServer);
    result += await _pushTable(
        _db.customFoods, 'custom_foods', customFoodToServer);
    result += await _pushWater();
    return result;
  }

  Future<PushResult> _pushTable<D>(
    TableInfo<Table, D> table,
    String serverTable,
    Map<String, Object?> Function(D) toServer,
  ) async {
    var pushed = 0;
    final rejected = <String>{};
    while (true) {
      final rows = [
        for (final r in await _db.syncDao.dirtyRows(table, limit: batchSize + rejected.length))
          toServer(r),
      ].where((r) => !rejected.contains(r['id'])).take(batchSize).toList();
      if (rows.isEmpty) break;

      Map<String, int> stored;
      try {
        stored = await _backend.upsertRows(serverTable, rows);
      } on SyncRejected {
        // Find the bad row(s) one by one; the rest still go out.
        stored = {};
        for (final row in rows) {
          try {
            stored.addAll(await _backend.upsertRows(serverTable, [row]));
          } on SyncRejected catch (e) {
            developer.log('Row ${row['id']} rejected by the server',
                error: e);
            rejected.add(row['id']! as String);
          }
        }
      }
      var progressed = false;
      for (final row in rows) {
        final serverUpdatedAt = stored[row['id']];
        if (serverUpdatedAt == null) continue;
        await _db.syncDao.markSynced(table, row['id']! as String,
            pushedUpdatedAt: row['updated_at']! as int,
            serverUpdatedAt: serverUpdatedAt);
        pushed++;
        progressed = true;
      }
      // A server that answers without confirming any row would otherwise
      // loop forever; give up for this run.
      if (!progressed && rows.every((r) => !rejected.contains(r['id']))) {
        break;
      }
    }
    return PushResult(pushed: pushed, failed: rejected.length);
  }

  /// Water goes row by row through `upsert_water`, which settles the
  /// one-row-per-day rule across devices and returns the winning row.
  Future<PushResult> _pushWater() async {
    var pushed = 0;
    final rejected = <String>{};
    while (true) {
      final rows = (await _db.syncDao
              .dirtyRows(_db.waterLogs, limit: batchSize + rejected.length))
          .where((r) => !rejected.contains(r.id))
          .toList();
      if (rows.isEmpty) break;
      for (final row in rows) {
        final sent = waterToServer(row);
        try {
          final server = await _backend.upsertWater(sent);
          await _db.syncDao.adoptServerWater(row.id,
              pushedUpdatedAt: row.updatedAt, server: server);
          pushed++;
        } on SyncRejected catch (e) {
          developer.log('Water ${row.id} rejected by the server', error: e);
          rejected.add(row.id);
        }
      }
    }
    return PushResult(pushed: pushed, failed: rejected.length);
  }
}
