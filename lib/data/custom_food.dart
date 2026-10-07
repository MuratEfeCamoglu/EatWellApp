import 'models.dart';

/// A food the user created themselves because it isn't in the bundled
/// catalog (or a scanned barcode wasn't recognised).
class CustomFood {
  const CustomFood({
    required this.id,
    required this.name,
    this.brand = '',
    required this.servingLabel,
    required this.kcalPerServing,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.category,
    this.barcode,
  });

  /// UUID; empty until saved.
  final String id;
  final String name;
  final String brand;
  final String servingLabel;

  /// Nutrition for one [servingLabel] serving.
  final int kcalPerServing;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final FoodCategory category;

  /// Set when saved from an unrecognised barcode, so the next scan finds it.
  final String? barcode;

  /// One serving as a [FoodItem], so it is logged through the same path as
  /// catalog foods (whose `caloriesPer100g` is likewise per serving).
  FoodItem get asFoodItem => FoodItem(
        name: name,
        brand: brand,
        caloriesPer100g: kcalPerServing,
        proteinG: proteinG,
        carbsG: carbsG,
        fatG: fatG,
        servingLabel: servingLabel,
        icon: category.icon,
        category: category,
      );

  CustomFood copyWith({
    String? id,
    String? name,
    String? brand,
    String? servingLabel,
    int? kcalPerServing,
    double? proteinG,
    double? carbsG,
    double? fatG,
    FoodCategory? category,
  }) {
    return CustomFood(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      servingLabel: servingLabel ?? this.servingLabel,
      kcalPerServing: kcalPerServing ?? this.kcalPerServing,
      proteinG: proteinG ?? this.proteinG,
      carbsG: carbsG ?? this.carbsG,
      fatG: fatG ?? this.fatG,
      category: category ?? this.category,
      barcode: barcode,
    );
  }
}

/// Upper bound for one serving's calories; anything above is a typo.
const maxKcalPerServing = 5000;

/// Turkish error text, or null when [value] is an acceptable food name.
String? validateCustomFoodName(String value) {
  if (value.trim().length < 2) return 'Ad en az 2 karakter olmalı';
  return null;
}

/// Parses a user-typed number, accepting `,` or `.` as the decimal mark.
/// Blank means 0; returns null for anything that isn't a number.
double? parseNutritionNumber(String text) {
  final t = text.trim().replaceAll(',', '.');
  if (t.isEmpty) return 0;
  return double.tryParse(t);
}

String? validateKcal(String text) {
  final v = parseNutritionNumber(text);
  if (v == null) return 'Geçerli bir sayı gir';
  if (v < 0) return '0 veya daha büyük olmalı';
  if (v > maxKcalPerServing) return 'En fazla $maxKcalPerServing kcal olabilir';
  return null;
}

String? validateMacro(String text) {
  final v = parseNutritionNumber(text);
  if (v == null) return 'Geçerli bir sayı gir';
  if (v < 0) return '0 veya daha büyük olmalı';
  return null;
}
