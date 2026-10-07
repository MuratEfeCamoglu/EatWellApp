/// Profile answers from the setup wizard, also editable later from the
/// Profile tab. Stored by `name` in shared_preferences.
library;

enum Gender { female, male }

enum ActivityLevel { sedentary, light, moderate, active }

extension ActivityLevelMultiplier on ActivityLevel {
  /// Standard Harris/Mifflin activity multipliers used to turn BMR into TDEE.
  double get multiplier {
    switch (this) {
      case ActivityLevel.sedentary:
        return 1.2;
      case ActivityLevel.light:
        return 1.375;
      case ActivityLevel.moderate:
        return 1.55;
      case ActivityLevel.active:
        return 1.725;
    }
  }
}

enum WeightGoal { lose, maintain, gain }

extension GenderLabel on Gender {
  String get label => switch (this) {
        Gender.female => 'Kadın',
        Gender.male => 'Erkek',
      };
}

extension ActivityLevelLabel on ActivityLevel {
  /// Same wording as the setup wizard's activity step.
  String get label => switch (this) {
        ActivityLevel.sedentary => 'Hareketsiz',
        ActivityLevel.light => 'Az hareketli',
        ActivityLevel.moderate => 'Orta derecede aktif',
        ActivityLevel.active => 'Çok aktif',
      };
}

extension WeightGoalLabel on WeightGoal {
  /// Same wording as the setup wizard's goal step.
  String get label => switch (this) {
        WeightGoal.lose => 'Kilo vermek',
        WeightGoal.maintain => 'Kilomu korumak',
        WeightGoal.gain => 'Kilo almak',
      };
}

/// `values.byName` that returns null instead of throwing for missing or
/// unknown stored names.
T? enumByName<T extends Enum>(List<T> values, String? name) =>
    name == null ? null : values.asNameMap()[name];
