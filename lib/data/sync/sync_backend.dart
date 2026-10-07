import 'profile_snapshot.dart';

/// The server refused this data (e.g. a check constraint), as opposed to a
/// network or availability problem. Retrying the same rows won't help.
class SyncRejected implements Exception {
  const SyncRejected(this.message);

  final String message;

  @override
  String toString() => 'SyncRejected($message)';
}

/// The cloud as the sync code sees it; Supabase implements it in
/// `backend/`, tests use an in-memory fake (CLAUDE.md §13.1). Methods
/// throw [SyncRejected] for bad data and anything else for network or
/// server errors — callers decide how to recover.
abstract class SyncBackend {
  /// The signed-in user's cloud profile, or null if there is none yet.
  Future<ProfileSnapshot?> fetchProfile();

  /// Creates or replaces the signed-in user's cloud profile. The server
  /// ignores it if its stored `updated_at` is newer.
  Future<void> upsertProfile(ProfileSnapshot snapshot);

  /// Upserts rows (snake_case server columns, no `user_id`) into [table];
  /// returns each row's `server_updated_at` by id. Rows older than the
  /// server's copy are ignored by the server (last write wins).
  Future<Map<String, int>> upsertRows(
      String table, List<Map<String, Object?>> rows);

  /// Writes one day's water through `upsert_water` and returns the row the
  /// server now stores for that day (its `id` may differ from ours).
  Future<Map<String, Object?>> upsertWater(Map<String, Object?> row);
}
