import 'package:flutter/material.dart';

/// Extra semantic colors used across Denge that don't map cleanly onto
/// Material's [ColorScheme] (macro nutrient colors, streak/water accents,
/// chart track colors, dividers). Extracted from the "Denge" design canvas.
@immutable
class DengeColors extends ThemeExtension<DengeColors> {
  const DengeColors({
    required this.divider,
    required this.trackBackground,
    required this.streak,
    required this.streakContainer,
    required this.streakOnContainer,
    required this.water,
    required this.waterContainer,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  final Color divider;
  final Color trackBackground;

  final Color streak;
  final Color streakContainer;
  final Color streakOnContainer;

  final Color water;
  final Color waterContainer;

  final Color protein;
  final Color carbs;
  final Color fat;

  static const light = DengeColors(
    divider: Color(0xFFE1E9E3),
    trackBackground: Color(0xFFEEF3EE),
    streak: Color(0xFFF2744E),
    streakContainer: Color(0xFFFDEBE3),
    streakOnContainer: Color(0xFFB2431C),
    water: Color(0xFF2B97D6),
    waterContainer: Color(0xFFE2F1FA),
    protein: Color(0xFF6A5FE0),
    carbs: Color(0xFFE39A17),
    fat: Color(0xFFDE5288),
  );

  static const dark = DengeColors(
    divider: Color(0xFF27342C),
    trackBackground: Color(0xFF1F2A23),
    streak: Color(0xFFF58462),
    streakContainer: Color(0xFF3A2219),
    streakOnContainer: Color(0xFFFF9F80),
    water: Color(0xFF4DB2EC),
    waterContainer: Color(0xFF132A3A),
    protein: Color(0xFF8E86F2),
    carbs: Color(0xFFF2B544),
    fat: Color(0xFFEE7CA6),
  );

  @override
  DengeColors copyWith({
    Color? divider,
    Color? trackBackground,
    Color? streak,
    Color? streakContainer,
    Color? streakOnContainer,
    Color? water,
    Color? waterContainer,
    Color? protein,
    Color? carbs,
    Color? fat,
  }) {
    return DengeColors(
      divider: divider ?? this.divider,
      trackBackground: trackBackground ?? this.trackBackground,
      streak: streak ?? this.streak,
      streakContainer: streakContainer ?? this.streakContainer,
      streakOnContainer: streakOnContainer ?? this.streakOnContainer,
      water: water ?? this.water,
      waterContainer: waterContainer ?? this.waterContainer,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
    );
  }

  @override
  DengeColors lerp(ThemeExtension<DengeColors>? other, double t) {
    if (other is! DengeColors) return this;
    return DengeColors(
      divider: Color.lerp(divider, other.divider, t)!,
      trackBackground: Color.lerp(trackBackground, other.trackBackground, t)!,
      streak: Color.lerp(streak, other.streak, t)!,
      streakContainer: Color.lerp(streakContainer, other.streakContainer, t)!,
      streakOnContainer:
          Color.lerp(streakOnContainer, other.streakOnContainer, t)!,
      water: Color.lerp(water, other.water, t)!,
      waterContainer: Color.lerp(waterContainer, other.waterContainer, t)!,
      protein: Color.lerp(protein, other.protein, t)!,
      carbs: Color.lerp(carbs, other.carbs, t)!,
      fat: Color.lerp(fat, other.fat, t)!,
    );
  }
}

extension DengeColorsContext on BuildContext {
  DengeColors get dengeColors =>
      Theme.of(this).extension<DengeColors>() ?? DengeColors.light;
}
