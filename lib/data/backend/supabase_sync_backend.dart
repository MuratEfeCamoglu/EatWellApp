import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../sync/profile_snapshot.dart';
import '../sync/row_mappers.dart';
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
      _guard(() => _client.from('profiles').upsert(snapshot.toRow(_userId)));

  @override
  Future<Map<String, int>> upsertRows(
      String table, List<Map<String, Object?>> rows) {
    return _guard(() async {
      final stored = await _client
          .from(table)
          .upsert(rows)
          .select('id, server_updated_at');
      return {
        for (final r in stored)
          r['id'] as String: (r['server_updated_at'] as num).toInt(),
      };
    });
  }

  @override
  Future<Map<String, Object?>> upsertWater(Map<String, Object?> row) {
    return _guard(() async {
      final stored =
          await _client.rpc('upsert_water', params: waterRpcParams(row));
      final map = Map<String, Object?>.from(stored as Map);
      return {
        ...map,
        for (final k in [
          'created_at',
          'updated_at',
          'deleted_at',
          'server_updated_at',
          'glasses',
        ])
          k: (map[k] as num?)?.toInt(),
      };
    });
  }

  /// Postgres refusing the data (constraint / RLS / bad input, SQLSTATE
  /// classes 22 and 23, or 42501) is a [SyncRejected]; everything else
  /// (network, 5xx) propagates unchanged so the sync retries later.
  static Future<T> _guard<T>(Future<T> Function() run) async {
    try {
      return await run();
    } on sb.PostgrestException catch (e) {
      final code = e.code ?? '';
      if (code.startsWith('22') || code.startsWith('23') || code == '42501') {
        throw SyncRejected('${e.code}: ${e.message}');
      }
      rethrow;
    }
  }
}
