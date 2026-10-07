import 'package:denge/data/models.dart';
import 'package:flutter_test/flutter_test.dart';

const menemen = FoodItem(
  name: 'Menemen',
  brand: 'Ev yapımı',
  caloriesPer100g: 120,
  proteinG: 6.5,
  carbsG: 5.5,
  fatG: 8.2,
  servingLabel: '1 porsiyon (200 g)',
);

void main() {
  group('FoodLogEntry.fromFood', () {
    test('copies the food and multiplies kcal/macros by amount', () {
      final now = DateTime(2026, 10, 7, 9, 15);
      final e = FoodLogEntry.fromFood(menemen, 1.5, MealType.breakfast, now);
      expect(e.date, '2026-10-07');
      expect(e.meal, MealType.breakfast);
      expect(e.foodName, 'Menemen');
      expect(e.brand, 'Ev yapımı');
      expect(e.servingLabel, '1 porsiyon (200 g)');
      expect(e.amount, 1.5);
      expect(e.kcal, 180); // caloriesPer100g * amount, unchanged formula
      expect(e.proteinG, closeTo(9.75, 1e-9));
      expect(e.carbsG, closeTo(8.25, 1e-9));
      expect(e.fatG, closeTo(12.3, 1e-9));
      expect(e.source, FoodLogSource.catalog);
      expect(e.sourceRef, isNull);
      expect(e.loggedAt, now.toUtc());
    });

    test('rounds kcal to an int', () {
      const f = FoodItem(
          name: 'X', brand: '', caloriesPer100g: 75, proteinG: 0, carbsG: 0, fatG: 0);
      expect(
          FoodLogEntry.fromFood(f, 0.5, MealType.snack, DateTime(2026)).kcal, 38);
    });

    test('23:30 belongs to that local day', () {
      final e = FoodLogEntry.fromFood(
          menemen, 1, MealType.dinner, DateTime(2026, 10, 7, 23, 30));
      expect(e.date, '2026-10-07');
    });

    test('keeps source and sourceRef', () {
      final e = FoodLogEntry.fromFood(menemen, 1, MealType.lunch, DateTime(2026),
          source: FoodLogSource.barcode, sourceRef: '8690000000000');
      expect(e.source, FoodLogSource.barcode);
      expect(e.sourceRef, '8690000000000');
    });
  });
}
