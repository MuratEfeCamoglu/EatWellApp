import 'profile_snapshot.dart';

/// The cloud as the sync code sees it; Supabase implements it in
/// `backend/`, tests use an in-memory fake (CLAUDE.md §13.1). Methods
/// throw on network or server errors — callers decide how to recover.
abstract class SyncBackend {
  /// The signed-in user's cloud profile, or null if there is none yet.
  Future<ProfileSnapshot?> fetchProfile();

  /// Creates or replaces the signed-in user's cloud profile. The server
  /// ignores it if its stored `updated_at` is newer.
  Future<void> upsertProfile(ProfileSnapshot snapshot);
}
