/// Turkish validation messages for the profile edit screens; each returns
/// null when the input is acceptable.
library;

import 'custom_food.dart' show parseNutritionNumber;

String? validateName(String v) =>
    v.trim().isEmpty ? 'Ad gerekli' : null;

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

String? validateEmail(String v) {
  final t = v.trim();
  if (t.isEmpty) return null;
  return _emailPattern.hasMatch(t) ? null : 'Geçerli bir e-posta gir';
}

String? _wholeInRange(String v, int min, int max, String unit) {
  final n = int.tryParse(v.trim());
  if (n == null) return 'Tam sayı gir';
  if (n < min || n > max) return '$min–$max $unit arası olmalı';
  return null;
}

String? _decimalInRange(String v, double min, double max, String unit) {
  if (v.trim().isEmpty) return 'Bir değer gir';
  final n = parseNutritionNumber(v);
  if (n == null) return 'Geçerli bir sayı gir';
  if (n < min || n > max) {
    return '${min.round()}–${max.round()} $unit arası olmalı';
  }
  return null;
}

String? validateAge(String v) => _wholeInRange(v, 13, 100, 'yaş');

String? validateHeight(String v) => _decimalInRange(v, 100, 250, 'cm');

String? validateGoalWeight(String v) => _decimalInRange(v, 30, 300, 'kg');

String? validateCalorieGoal(String v) => _wholeInRange(v, 800, 6000, 'kcal');

String? validateMacroGoal(String v) => _wholeInRange(v, 0, 1000, 'g');

/// Calories the given macro grams add up to (4 / 4 / 9 kcal per gram).
int macroKcal({required int proteinG, required int carbsG, required int fatG}) =>
    proteinG * 4 + carbsG * 4 + fatG * 9;
