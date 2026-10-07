import '../profile_enums.dart';

/// The synced part of the profile (CLAUDE.md §13.2 `profiles`): what the app
/// keeps in shared_preferences, as one value that can be compared and sent.
/// Times are UTC milliseconds, like every other synced row.
class ProfileSnapshot {
  const ProfileSnapshot({
    required this.createdAt,
    required this.updatedAt,
    this.name = '',
    this.email = '',
    this.gender,
    this.age,
    this.heightCm,
    this.weightKg,
    this.activityLevel,
    this.weightGoal,
    this.goalWeightKg,
    this.weeklyPaceKg,
    this.calorieGoal = 0,
    this.proteinGoalG = 0,
    this.carbsGoalG = 0,
    this.fatGoalG = 0,
    this.allergies = const [],
    this.allergyNote = '',
    this.consentVersion,
    this.consentAt,
  });

  final int createdAt;

  /// Last local change; the "last write wins" key.
  final int updatedAt;
  final String name;
  final String email;
  final Gender? gender;
  final int? age;
  final double? heightCm;
  final double? weightKg;
  final ActivityLevel? activityLevel;
  final WeightGoal? weightGoal;
  final double? goalWeightKg;
  final double? weeklyPaceKg;
  final int calorieGoal;
  final int proteinGoalG;
  final int carbsGoalG;
  final int fatGoalG;

  /// `Allergen.name`s.
  final List<String> allergies;
  final String allergyNote;

  /// Health-data consent (F20), so a second device doesn't ask again.
  final String? consentVersion;
  final int? consentAt;

  /// A profile is only worth adopting once setup produced real goals.
  bool get hasGoals => calorieGoal > 0;

  ProfileSnapshot copyWith({int? updatedAt, int? calorieGoal}) =>
      ProfileSnapshot(
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        name: name,
        email: email,
        gender: gender,
        age: age,
        heightCm: heightCm,
        weightKg: weightKg,
        activityLevel: activityLevel,
        weightGoal: weightGoal,
        goalWeightKg: goalWeightKg,
        weeklyPaceKg: weeklyPaceKg,
        calorieGoal: calorieGoal ?? this.calorieGoal,
        proteinGoalG: proteinGoalG,
        carbsGoalG: carbsGoalG,
        fatGoalG: fatGoalG,
        allergies: allergies,
        allergyNote: allergyNote,
        consentVersion: consentVersion,
        consentAt: consentAt,
      );

  /// The `profiles` row for [userId]. `server_updated_at` is left out on
  /// purpose: only the server sets it.
  Map<String, Object?> toRow(String userId) => {
        'user_id': userId,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'name': name,
        'email': email,
        'gender': gender?.name,
        'age': age,
        'height_cm': heightCm,
        'weight_kg': weightKg,
        'activity_level': activityLevel?.name,
        'weight_goal': weightGoal?.name,
        'goal_weight_kg': goalWeightKg,
        'weekly_pace_kg': weeklyPaceKg,
        'calorie_goal': calorieGoal,
        'protein_goal_g': proteinGoalG,
        'carbs_goal_g': carbsGoalG,
        'fat_goal_g': fatGoalG,
        'allergies': allergies,
        'allergy_note': allergyNote,
        'consent_version': consentVersion,
        'consent_at': consentAt,
      };

  /// Tolerates nulls and names this app version doesn't know.
  factory ProfileSnapshot.fromRow(Map<String, dynamic> row) {
    double? dbl(String k) => (row[k] as num?)?.toDouble();
    int intOr0(String k) => (row[k] as num?)?.toInt() ?? 0;
    return ProfileSnapshot(
      createdAt: intOr0('created_at'),
      updatedAt: intOr0('updated_at'),
      name: row['name'] as String? ?? '',
      email: row['email'] as String? ?? '',
      gender: enumByName(Gender.values, row['gender'] as String?),
      age: (row['age'] as num?)?.toInt(),
      heightCm: dbl('height_cm'),
      weightKg: dbl('weight_kg'),
      activityLevel:
          enumByName(ActivityLevel.values, row['activity_level'] as String?),
      weightGoal: enumByName(WeightGoal.values, row['weight_goal'] as String?),
      goalWeightKg: dbl('goal_weight_kg'),
      weeklyPaceKg: dbl('weekly_pace_kg'),
      calorieGoal: intOr0('calorie_goal'),
      proteinGoalG: intOr0('protein_goal_g'),
      carbsGoalG: intOr0('carbs_goal_g'),
      fatGoalG: intOr0('fat_goal_g'),
      allergies: [
        for (final a in (row['allergies'] as List?) ?? const []) a.toString()
      ],
      allergyNote: row['allergy_note'] as String? ?? '',
      consentVersion: row['consent_version'] as String?,
      consentAt: (row['consent_at'] as num?)?.toInt(),
    );
  }
}

enum ProfileSyncAction { none, push, pull }

/// What to do with this device's profile ([local], null before setup) and
/// the cloud's ([remote]): the newer `updatedAt` wins, but a cloud profile
/// without goals never replaces a real one.
ProfileSyncAction decideProfileSync({
  required ProfileSnapshot? local,
  required ProfileSnapshot? remote,
}) {
  final remoteUsable = remote != null && remote.hasGoals;
  if (local == null) {
    return remoteUsable ? ProfileSyncAction.pull : ProfileSyncAction.none;
  }
  if (!remoteUsable) return ProfileSyncAction.push;
  if (remote.updatedAt > local.updatedAt) return ProfileSyncAction.pull;
  if (local.updatedAt > remote.updatedAt) return ProfileSyncAction.push;
  return ProfileSyncAction.none;
}
