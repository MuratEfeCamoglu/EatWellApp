import 'package:denge/data/profile_enums.dart';
import 'package:denge/data/sync/profile_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

ProfileSnapshot snap({int updatedAt = 1000, int calorieGoal = 1800}) =>
    ProfileSnapshot(
      createdAt: 500,
      updatedAt: updatedAt,
      name: 'Ayşe',
      email: 'ayse@ornek.com',
      gender: Gender.female,
      age: 27,
      heightCm: 168,
      weightKg: 70,
      activityLevel: ActivityLevel.moderate,
      weightGoal: WeightGoal.lose,
      goalWeightKg: 64,
      weeklyPaceKg: 0.5,
      calorieGoal: calorieGoal,
      proteinGoalG: 126,
      carbsGoalG: 185,
      fatGoalG: 51,
      allergies: const ['gluten'],
      allergyNote: 'çilek',
      consentVersion: '1',
      consentAt: 400,
    );

void main() {
  test('round-trips through the server row (snake_case columns)', () {
    final row = snap().toRow('user-1');
    expect(row['user_id'], 'user-1');
    expect(row['calorie_goal'], 1800);
    expect(row['activity_level'], 'moderate');
    expect(row['allergies'], ['gluten']);
    expect(row.containsKey('server_updated_at'), isFalse,
        reason: 'the server owns server_updated_at');

    final back = ProfileSnapshot.fromRow({...row, 'server_updated_at': 9});
    expect(back.toRow('user-1'), row);
  });

  test('unknown enum names and nulls from the server are tolerated', () {
    final back = ProfileSnapshot.fromRow({
      'created_at': 1,
      'updated_at': 2,
      'gender': 'other',
      'activity_level': null,
      'allergies': null,
    });
    expect(back.gender, isNull);
    expect(back.activityLevel, isNull);
    expect(back.allergies, isEmpty);
    expect(back.name, '');
  });

  group('decideProfileSync', () {
    test('nothing anywhere -> nothing to do', () {
      expect(decideProfileSync(local: null, remote: null), ProfileSyncAction.none);
    });

    test('only this device has a profile -> push', () {
      expect(decideProfileSync(local: snap(), remote: null), ProfileSyncAction.push);
    });

    test('fresh device, profile in the cloud -> pull', () {
      expect(decideProfileSync(local: null, remote: snap()), ProfileSyncAction.pull);
    });

    test('newest updated_at wins', () {
      expect(
          decideProfileSync(
              local: snap(updatedAt: 2000), remote: snap(updatedAt: 1000)),
          ProfileSyncAction.push);
      expect(
          decideProfileSync(
              local: snap(updatedAt: 1000), remote: snap(updatedAt: 2000)),
          ProfileSyncAction.pull);
      expect(
          decideProfileSync(
              local: snap(updatedAt: 1000), remote: snap(updatedAt: 1000)),
          ProfileSyncAction.none);
    });

    test('a cloud profile without goals never overwrites a real one', () {
      expect(
          decideProfileSync(
              local: snap(updatedAt: 1000),
              remote: snap(updatedAt: 2000, calorieGoal: 0)),
          ProfileSyncAction.push);
      expect(
          decideProfileSync(local: null, remote: snap(calorieGoal: 0)),
          ProfileSyncAction.none);
    });
  });
}
