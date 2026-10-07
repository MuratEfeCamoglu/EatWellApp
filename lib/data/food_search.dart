import 'custom_food.dart';
import 'models.dart';

/// Result of [searchFoods]: the user's own foods are kept apart so the
/// search screen can list them above the catalog.
class FoodSearchResult {
  const FoodSearchResult(this.custom, this.catalog);

  final List<CustomFood> custom;
  final List<FoodItem> catalog;

  bool get isEmpty => custom.isEmpty && catalog.isEmpty;

  /// Own foods first, then catalog foods.
  List<FoodItem> get all => [...custom.map((c) => c.asFoodItem), ...catalog];
}

/// Lower-cases with Turkish dotted/dotless I rules and then folds `ı` into
/// `i`, so "KARNIYARIK", "karnıyarık" and "karniyarik" all match.
String foldForSearch(String s) => s
    .replaceAll('İ', 'i')
    .replaceAll('I', 'ı')
    .toLowerCase()
    .replaceAll('ı', 'i');

/// Filters [catalog] (only foods suited to [meal]) and [custom] (any meal)
/// by [query] against name and brand, and by [category] when given.
FoodSearchResult searchFoods({
  required Iterable<FoodItem> catalog,
  required Iterable<CustomFood> custom,
  required String query,
  required MealType meal,
  FoodCategory? category,
}) {
  final q = foldForSearch(query.trim());
  bool matches(String name, String brand) =>
      q.isEmpty ||
      foldForSearch(name).contains(q) ||
      foldForSearch(brand).contains(q);

  return FoodSearchResult(
    [
      for (final c in custom)
        if ((category == null || c.category == category) &&
            matches(c.name, c.brand))
          c,
    ],
    [
      for (final f in catalog)
        if (f.meals.contains(meal) &&
            (category == null || f.category == category) &&
            matches(f.name, f.brand))
          f,
    ],
  );
}
