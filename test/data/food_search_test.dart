import 'package:denge/data/custom_food.dart';
import 'package:denge/data/food_search.dart';
import 'package:denge/data/models.dart';
import 'package:flutter_test/flutter_test.dart';

const catalog = [
  FoodItem(
      name: 'Menemen', brand: 'Ev yapımı', caloriesPer100g: 120,
      proteinG: 6, carbsG: 5, fatG: 8,
      meals: {MealType.breakfast}, category: FoodCategory.kahvaltilik),
  FoodItem(
      name: 'Su böreği', brand: 'Fırın', caloriesPer100g: 300,
      proteinG: 9, carbsG: 30, fatG: 15, category: FoodCategory.hamurIsi),
  FoodItem(
      name: 'Karnıyarık', brand: 'Ev yapımı', caloriesPer100g: 250,
      proteinG: 10, carbsG: 15, fatG: 18,
      meals: {MealType.dinner}, category: FoodCategory.sebze),
];

const mine = [
  CustomFood(
      id: '1', name: 'Annemin böreği', servingLabel: '1 dilim',
      kcalPerServing: 310, proteinG: 9, carbsG: 30, fatG: 17,
      category: FoodCategory.hamurIsi),
  CustomFood(
      id: '2', name: 'Protein smoothie', servingLabel: '1 bardak',
      kcalPerServing: 220, proteinG: 25, carbsG: 20, fatG: 4,
      category: FoodCategory.icecek),
];

void main() {
  test('own foods match the query and come back separately, first', () {
    final r = searchFoods(catalog: catalog, custom: mine, query: 'böreği',
        meal: MealType.lunch);
    expect(r.custom.map((c) => c.name), ['Annemin böreği']);
    expect(r.catalog.map((f) => f.name), ['Su böreği']);
    expect(r.all.first.name, 'Annemin böreği');
  });

  test('empty query lists all own foods and the meal-appropriate catalog',
      () {
    final r = searchFoods(catalog: catalog, custom: mine, query: '',
        meal: MealType.breakfast);
    expect(r.custom, hasLength(2), reason: 'own foods fit any meal');
    expect(r.catalog.map((f) => f.name), ['Menemen', 'Su böreği']);
  });

  test('category filter applies to own foods too', () {
    final r = searchFoods(catalog: catalog, custom: mine, query: '',
        meal: MealType.dinner, category: FoodCategory.icecek);
    expect(r.custom.map((c) => c.name), ['Protein smoothie']);
    expect(r.catalog, isEmpty);
  });

  test('matching is case-insensitive (Turkish İ/ı included) and checks brand',
      () {
    expect(
        searchFoods(catalog: catalog, custom: mine, query: 'KARNIYARIK',
                meal: MealType.dinner)
            .catalog
            .single
            .name,
        'Karnıyarık');
    expect(
        searchFoods(catalog: catalog, custom: mine, query: 'fırın',
                meal: MealType.lunch)
            .catalog
            .single
            .name,
        'Su böreği');
  });

  test('no match anywhere is empty', () {
    final r = searchFoods(catalog: catalog, custom: mine, query: 'pizza',
        meal: MealType.lunch);
    expect(r.isEmpty, isTrue);
  });
}
