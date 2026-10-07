import 'profile_enums.dart';

/// Daily calorie and macro goals.
class NutritionTargets {
  const NutritionTargets({
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });

  final int calories;
  final int proteinG;
  final int carbsG;
  final int fatG;
}

/// Basal metabolic rate via the Mifflin-St Jeor equation.
double _bmr(Gender gender, double weightKg, double heightCm, int age) {
  final base = 10 * weightKg + 6.25 * heightCm - 5 * age;
  return gender == Gender.male ? base + 5 : base - 161;
}

/// The goals the setup wizard computes (and the goals screen suggests):
/// BMR × activity multiplier, ± the weekly pace (1 kg of body fat ≈ 7700
/// kcal), clamped to a safe floor; protein 1.8 g/kg, fat 27 % of kcal and
/// carbs the remainder.
NutritionTargets computeTargets({
  required Gender gender,
  required int age,
  required double heightCm,
  required double weightKg,
  required ActivityLevel activity,
  required WeightGoal goal,
  required double weeklyPaceKg,
}) {
  final tdee = _bmr(gender, weightKg, heightCm, age) * activity.multiplier;
  final dailyDeltaKcal = weeklyPaceKg * 7700 / 7;
  var calorieGoal = switch (goal) {
    WeightGoal.lose => tdee - dailyDeltaKcal,
    WeightGoal.gain => tdee + dailyDeltaKcal,
    WeightGoal.maintain => tdee,
  };
  final floor = gender == Gender.male ? 1500.0 : 1200.0;
  calorieGoal = calorieGoal.clamp(floor, 4000.0);

  final proteinG = (weightKg * 1.8).round();
  final fatG = (calorieGoal * 0.27 / 9).round();
  final carbsG =
      ((calorieGoal - proteinG * 4 - fatG * 9) / 4).round().clamp(0, 999);
  return NutritionTargets(
    calories: calorieGoal.round(),
    proteinG: proteinG,
    carbsG: carbsG,
    fatG: fatG,
  );
}
