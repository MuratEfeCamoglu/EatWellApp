import 'package:denge/data/models.dart';
import 'package:denge/data/stats/daily_summary.dart';
import 'package:flutter_test/flutter_test.dart';

FoodLogEntry entry(MealType meal, int kcal,
        {double p = 0, double c = 0, double f = 0, String name = 'Yemek'}) =>
    FoodLogEntry(
      id: name,
      date: '2026-10-07',
      meal: meal,
      foodName: name,
      servingLabel: '1 porsiyon',
      amount: 1,
      kcal: kcal,
      proteinG: p,
      carbsG: c,
      fatG: f,
      loggedAt: DateTime.utc(2026, 10, 7),
    );

void main() {
  test('empty day is all zeros with every meal present and empty', () {
    final s = DailySummary.fromEntries(const []);
    expect(s.kcal, 0);
    expect(s.proteinG, 0);
    expect(s.carbsG, 0);
    expect(s.fatG, 0);
    expect(s.isEmpty, isTrue);
    for (final type in MealType.values) {
      expect(s.meal(type).kcal, 0);
      expect(s.meal(type).entries, isEmpty);
    }
  });

  test('single entry', () {
    final s = DailySummary.fromEntries(
        [entry(MealType.lunch, 350, p: 20, c: 30, f: 10)]);
    expect(s.kcal, 350);
    expect(s.proteinG, 20);
    expect(s.carbsG, 30);
    expect(s.fatG, 10);
    expect(s.meal(MealType.lunch).kcal, 350);
    expect(s.meal(MealType.breakfast).kcal, 0);
    expect(s.isEmpty, isFalse);
  });

  test('many entries sum per meal and per day, keeping order', () {
    final s = DailySummary.fromEntries([
      entry(MealType.breakfast, 120, p: 6.5, name: 'Menemen'),
      entry(MealType.breakfast, 80, p: 2.5, name: 'Simit'),
      entry(MealType.dinner, 500, f: 20.25, name: 'Köfte'),
    ]);
    expect(s.kcal, 700);
    expect(s.proteinG, closeTo(9, 1e-9));
    expect(s.fatG, closeTo(20.25, 1e-9));
    expect(s.meal(MealType.breakfast).kcal, 200);
    expect(s.meal(MealType.breakfast).entries.map((e) => e.foodName),
        ['Menemen', 'Simit']);
    expect(s.meal(MealType.dinner).entries, hasLength(1));
    expect(s.meal(MealType.snack).entries, isEmpty);
  });
}
