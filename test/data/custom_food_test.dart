import 'package:denge/data/custom_food.dart';
import 'package:denge/data/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('validateCustomFoodName', () {
    test('requires at least 2 non-blank characters', () {
      expect(validateCustomFoodName(''), isNotNull);
      expect(validateCustomFoodName('   '), isNotNull);
      expect(validateCustomFoodName(' a '), isNotNull);
      expect(validateCustomFoodName('Ay'), isNull);
      expect(validateCustomFoodName('Annemin böreği'), isNull);
    });
  });

  group('parseNutritionNumber', () {
    test('accepts dot or comma decimals, blank means 0', () {
      expect(parseNutritionNumber('12,5'), 12.5);
      expect(parseNutritionNumber(' 7.25 '), 7.25);
      expect(parseNutritionNumber(''), 0);
      expect(parseNutritionNumber('abc'), isNull);
    });
  });

  group('validateKcal', () {
    test('0 and positive up to 5000 are valid', () {
      expect(validateKcal('0'), isNull);
      expect(validateKcal('250'), isNull);
      expect(validateKcal('5000'), isNull);
    });

    test('negative, above 5000 and non-numbers are rejected', () {
      expect(validateKcal('-1'), isNotNull);
      expect(validateKcal('5000,5'), isNotNull);
      expect(validateKcal('5001'), isNotNull);
      expect(validateKcal('çok'), isNotNull);
    });
  });

  group('validateMacro', () {
    test('0 or positive numbers only', () {
      expect(validateMacro(''), isNull);
      expect(validateMacro('0'), isNull);
      expect(validateMacro('12,5'), isNull);
      expect(validateMacro('-0,1'), isNotNull);
      expect(validateMacro('x'), isNotNull);
    });
  });

  test('asFoodItem logs one serving at kcalPerServing', () {
    const food = CustomFood(
      id: 'id-1',
      name: 'Annemin böreği',
      brand: 'Ev',
      servingLabel: '1 dilim (120 g)',
      kcalPerServing: 310,
      proteinG: 9,
      carbsG: 30,
      fatG: 17,
      category: FoodCategory.hamurIsi,
    );
    final item = food.asFoodItem;
    expect(item.name, 'Annemin böreği');
    expect(item.brand, 'Ev');
    expect(item.servingLabel, '1 dilim (120 g)');
    expect(item.caloriesPer100g, 310);
    expect(item.category, FoodCategory.hamurIsi);
    expect(item.meals, MealType.values.toSet());
    expect(FoodLogEntry.fromFood(item, 2, MealType.lunch, DateTime(2026)).kcal,
        620);
  });
}
