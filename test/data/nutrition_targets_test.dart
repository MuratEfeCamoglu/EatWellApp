import 'package:denge/data/nutrition_targets.dart';
import 'package:denge/data/profile_enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('matches the setup wizard maths (Mifflin-St Jeor, 7700 kcal/kg)', () {
    // BMR 1454 * 1.55 = 2253.7, minus 0.5 kg/week (550 kcal/day).
    final t = computeTargets(
      gender: Gender.female,
      age: 27,
      heightCm: 168,
      weightKg: 70,
      activity: ActivityLevel.moderate,
      goal: WeightGoal.lose,
      weeklyPaceKg: 0.5,
    );
    expect(t.calories, 1704);
    expect(t.proteinG, 126); // 1.8 g/kg
    expect(t.fatG, 51); // 27 % of kcal
    expect(t.carbsG, 185); // the rest
  });

  test('maintain ignores the pace, gain adds it', () {
    TargetsFn f(WeightGoal g) => (pace) => computeTargets(
          gender: Gender.male,
          age: 30,
          heightCm: 180,
          weightKg: 80,
          activity: ActivityLevel.light,
          goal: g,
          weeklyPaceKg: pace,
        );
    expect(f(WeightGoal.maintain)(0.25).calories,
        f(WeightGoal.maintain)(0.75).calories);
    expect(f(WeightGoal.gain)(0.5).calories,
        f(WeightGoal.maintain)(0.5).calories + 550);
  });

  test('calories are clamped to the safe floor per gender and to 4000', () {
    NutritionTargets low(Gender g) => computeTargets(
          gender: g,
          age: 70,
          heightCm: 150,
          weightKg: 45,
          activity: ActivityLevel.sedentary,
          goal: WeightGoal.lose,
          weeklyPaceKg: 0.75,
        );
    expect(low(Gender.female).calories, 1200);
    expect(low(Gender.male).calories, 1500);

    final high = computeTargets(
      gender: Gender.male,
      age: 20,
      heightCm: 200,
      weightKg: 150,
      activity: ActivityLevel.active,
      goal: WeightGoal.gain,
      weeklyPaceKg: 0.75,
    );
    expect(high.calories, 4000);
  });

  test('labels are Turkish', () {
    expect(Gender.female.label, 'Kadın');
    expect(ActivityLevel.moderate.label, 'Orta derecede aktif');
    expect(WeightGoal.maintain.label, 'Kilomu korumak');
  });
}

typedef TargetsFn = NutritionTargets Function(double pace);
