import 'package:denge/data/sync/profile_snapshot.dart';
import 'package:denge/data/sync/sync_backend.dart';

/// In-memory cloud for tests: one map of rows per table, with the server's
/// last-write-wins and `server_updated_at` behaviour.
class FakeSyncBackend implements SyncBackend {
  ProfileSnapshot? profile;
  int fetches = 0;
  int pushes = 0;

  /// Thrown by every call while set (e.g. a network error).
  Object? failWith;

  /// Rows whose id is listed here are rejected by the "server" (e.g. a
  /// check-constraint violation), alone or inside a batch.
  final Set<String> rejectIds = {};

  final Map<String, Map<String, Map<String, Object?>>> tables = {};
  final List<(String table, int rows)> batches = [];
  int _clock = 1000;

  Map<String, Map<String, Object?>> table(String name) =>
      tables.putIfAbsent(name, () => {});

  @override
  Future<ProfileSnapshot?> fetchProfile() async {
    if (failWith != null) throw failWith!;
    fetches++;
    return profile;
  }

  @override
  Future<void> upsertProfile(ProfileSnapshot snapshot) async {
    if (failWith != null) throw failWith!;
    pushes++;
    profile = snapshot;
  }

  @override
  Future<Map<String, int>> upsertRows(
      String tableName, List<Map<String, Object?>> rows) async {
    if (failWith != null) throw failWith!;
    if (rows.any((r) => rejectIds.contains(r['id']))) {
      throw const SyncRejected('check constraint');
    }
    batches.add((tableName, rows.length));
    final t = table(tableName);
    final result = <String, int>{};
    for (final row in rows) {
      final id = row['id']! as String;
      final existing = t[id];
      if (existing == null ||
          (row['updated_at']! as int) >= (existing['updated_at']! as int)) {
        t[id] = {...row, 'server_updated_at': ++_clock};
      }
      result[id] = t[id]!['server_updated_at']! as int;
    }
    return result;
  }

  @override
  Future<Map<String, Object?>> upsertWater(Map<String, Object?> row) async {
    if (failWith != null) throw failWith!;
    batches.add(('water_logs', 1));
    final t = table('water_logs');
    final sameDay =
        t.values.where((r) => r['date'] == row['date']).firstOrNull;
    if (sameDay == null) {
      final stored = {...row, 'server_updated_at': ++_clock};
      t[row['id']! as String] = stored;
      return stored;
    }
    if ((row['updated_at']! as int) >= (sameDay['updated_at']! as int)) {
      sameDay
        ..['glasses'] = row['glasses']
        ..['updated_at'] = row['updated_at']
        ..['deleted_at'] = row['deleted_at']
        ..['server_updated_at'] = ++_clock;
    }
    return Map.of(sameDay);
  }
}
