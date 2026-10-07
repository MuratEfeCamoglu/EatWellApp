import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../sync/profile_snapshot.dart';
import '../sync/sync_backend.dart';

/// [SyncBackend] on the Supabase tables from `supabase/migrations/`. Row
/// Level Security limits every query to the signed-in user's rows.
class SupabaseSyncBackend implements SyncBackend {
  SupabaseSyncBackend(this._client);

  /// Uses the client set up by `SupabaseAuthService.initialize`.
  factory SupabaseSyncBackend.forInitializedClient() =>
      SupabaseSyncBackend(sb.Supabase.instance.client);

  final sb.SupabaseClient _client;

  String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw StateError('Not signed in');
    return id;
  }

  @override
  Future<ProfileSnapshot?> fetchProfile() async {
    final row = await _client
        .from('profiles')
        .select()
        .eq('user_id', _userId)
        .maybeSingle();
    return row == null ? null : ProfileSnapshot.fromRow(row);
  }

  @override
  Future<void> upsertProfile(ProfileSnapshot snapshot) =>
      _client.from('profiles').upsert(snapshot.toRow(_userId));
}
