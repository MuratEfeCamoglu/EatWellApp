import '../models.dart';

/// One meal's share of a day: its entries (in logged order) and their kcal.
class MealSummary {
  const MealSummary(this.meal, this.entries, this.kcal);

  final MealType meal;
  final List<FoodLogEntry> entries;
  final int kcal;
}

/// A day's calorie/macro totals, always derived from its diary entries
/// rather than kept as separate counters (CLAUDE.md §4.4).
class DailySummary {
  const DailySummary._({
    required this.kcal,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required Map<MealType, MealSummary> meals,
  }) : _meals = meals;

  factory DailySummary.fromEntries(List<FoodLogEntry> entries) {
    var kcal = 0;
    var protein = 0.0;
    var carbs = 0.0;
    var fat = 0.0;
    final byMeal = {for (final type in MealType.values) type: <FoodLogEntry>[]};
    for (final e in entries) {
      kcal += e.kcal;
      protein += e.proteinG;
      carbs += e.carbsG;
      fat += e.fatG;
      byMeal[e.meal]!.add(e);
    }
    return DailySummary._(
      kcal: kcal,
      proteinG: protein,
      carbsG: carbs,
      fatG: fat,
      meals: {
        for (final MapEntry(key: type, value: list) in byMeal.entries)
          type: MealSummary(
            type,
            List.unmodifiable(list),
            list.fold(0, (sum, e) => sum + e.kcal),
          ),
      },
    );
  }

  static final empty = DailySummary.fromEntries(const []);

  final int kcal;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final Map<MealType, MealSummary> _meals;

  MealSummary meal(MealType type) => _meals[type]!;

  bool get isEmpty => _meals.values.every((m) => m.entries.isEmpty);
}
