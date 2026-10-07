import 'package:denge/data/sync/profile_snapshot.dart';
import 'package:denge/data/sync/sync_backend.dart';

/// In-memory cloud for tests.
class FakeSyncBackend implements SyncBackend {
  ProfileSnapshot? profile;
  int fetches = 0;
  int pushes = 0;
  Object? failWith;

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
}
