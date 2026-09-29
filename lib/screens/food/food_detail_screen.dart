import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/app_state.dart';
import '../../data/models.dart';
import '../search/search_screen.dart' show defaultMealForNow;
import '../../theme/app_colors.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/section_card.dart';

/// Ports project/FoodDetail.dc.html (light, theme-aware for
/// FoodDetail-dark.dc.html). A serving-size stepper live-recalculates
/// calories/macros from [food]'s per-100g values.
class FoodDetailScreen extends StatefulWidget {
  const FoodDetailScreen({super.key, required this.food, this.initialMeal});

  final FoodItem food;

  /// The meal to add to; defaults to whichever meal fits the current time
  /// of day when this screen is opened without a specific target (e.g. a
  /// standalone search).
  final MealType? initialMeal;

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

const _mealOrder = [MealType.breakfast, MealType.lunch, MealType.dinner, MealType.snack];
const _mealLabels = {
  MealType.breakfast: 'Kahvaltı',
  MealType.lunch: 'Öğle',
  MealType.dinner: 'Akşam',
  MealType.snack: 'Ara öğün',
};
const _mealCtas = {
  MealType.breakfast: 'Kahvaltıya ekle',
  MealType.lunch: 'Öğle yemeğine ekle',
  MealType.dinner: 'Akşam yemeğine ekle',
  MealType.snack: 'Ara öğüne ekle',
};

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  double _amount = 1;
  late MealType _meal = widget.initialMeal ?? defaultMealForNow();
  bool _isFavorite = true;

  void _dec() => setState(() => _amount = math.max(0.5, _amount - 0.5));
  void _inc() => setState(() => _amount = math.min(10, _amount + 0.5));

  String _fmtAmount(double x) {
    final rounded = (x * 10).round() / 10;
    if (rounded == rounded.roundToDouble()) return rounded.toInt().toString();
    return rounded.toStringAsFixed(1).replaceAll('.', ',');
  }

  String _fmt1(double x) {
    final rounded = (x * 10).round() / 10;
    if (rounded == rounded.roundToDouble()) return rounded.toInt().toString();
    return rounded.toStringAsFixed(1).replaceAll('.', ',');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final colors = context.dengeColors;
    final food = widget.food;

    final kcal = (food.caloriesPer100g * _amount).round();
    final protein = food.proteinG * _amount;
    final carbs = food.carbsG * _amount;
    final fat = food.fatG * _amount;

    final proteinKcal = protein * 4;
    final carbsKcal = carbs * 4;
    final fatKcal = fat * 9;
    final totalMacroKcal = proteinKcal + carbsKcal + fatKcal;

    String pct(double v) => totalMacroKcal <= 0 ? '%0' : '%${(v / totalMacroKcal * 100).round()}';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Row(
                children: [
                  AppBackButton(),
                  const Spacer(),
                  Material(
                    color: scheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: colors.divider),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => setState(() => _isFavorite = !_isFavorite),
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: Icon(
                          _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: colors.streak,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row.
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: colors.streakContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(Icons.ramen_dining_rounded, size: 40, color: colors.streak),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(food.name,
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                      fontSize: 24, color: scheme.onSurface, letterSpacing: -0.3)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.check_circle_rounded, size: 16, color: scheme.primary),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text('Doğrulanmış · ${food.brand}',
                                        style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Porsiyon stepper.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Porsiyon',
                            style:
                                theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800, fontSize: 14, color: scheme.onSurface)),
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: scheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: colors.divider),
                          ),
                          child: Row(
                            children: [
                              _StepperButton(
                                icon: Icons.remove_rounded,
                                bg: colors.trackBackground,
                                fg: scheme.onSurface,
                                onTap: _dec,
                              ),
                              SizedBox(
                                width: 56,
                                child: Center(
                                  child: Text(
                                    _fmtAmount(_amount),
                                    style: const TextStyle(
                                        fontSize: 20, fontWeight: FontWeight.w800, fontFeatures: [FontFeature.tabularFigures()]),
                                  ),
                                ),
                              ),
                              _StepperButton(
                                icon: Icons.add_rounded,
                                bg: scheme.primary,
                                fg: scheme.onPrimary,
                                onTap: _inc,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '× ${food.servingLabel}',
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    // Macro summary card.
                    SectionCard(
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _MacroRing(
                                proteinKcal: proteinKcal,
                                carbsKcal: carbsKcal,
                                fatKcal: fatKcal,
                                proteinColor: colors.protein,
                                carbsColor: colors.carbs,
                                fatColor: colors.fat,
                                trackColor: colors.trackBackground,
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Toplam · ${_fmtAmount(_amount)} × ${food.servingLabel}',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(fontWeight: FontWeight.w800, fontSize: 12),
                                    ),
                                    Text.rich(
                                      TextSpan(
                                        text: '$kcal',
                                        style: TextStyle(
                                          fontSize: 40,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -1,
                                          height: 1.1,
                                          color: scheme.onSurface,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: ' kcal',
                                            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Divider(height: 1, color: colors.divider),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _MacroStat(
                                  color: colors.protein,
                                  label: 'Protein',
                                  grams: _fmt1(protein),
                                  percent: pct(proteinKcal),
                                ),
                              ),
                              Expanded(
                                child: _MacroStat(
                                  color: colors.carbs,
                                  label: 'Karbonhidrat',
                                  grams: _fmt1(carbs),
                                  percent: pct(carbsKcal),
                                ),
                              ),
                              Expanded(
                                child: _MacroStat(
                                  color: colors.fat,
                                  label: 'Yağ',
                                  grams: _fmt1(fat),
                                  percent: pct(fatKcal),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Öğün (meal) selector.
                    Text('Öğün',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(fontWeight: FontWeight.w800, fontSize: 14, color: scheme.onSurface)),
                    const SizedBox(height: 12),
                    Row(
                      children: _mealOrder
                          .map((id) => Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(right: id == _mealOrder.last ? 0 : 8),
                                  child: _MealChip(
                                    label: _mealLabels[id]!,
                                    selected: _meal == id,
                                    onTap: () => setState(() => _meal = id),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            // Sticky bottom CTA.
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: colors.divider)),
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<AppState>().addFoodToMeal(_meal, food, _amount);
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(content: Text('${food.name} ${_mealLabels[_meal]} listesine eklendi')));
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.add_rounded),
                label: Text('${_mealCtas[_meal]} · $kcal kcal'),
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.bg, required this.fg, required this.onTap});

  final IconData icon;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(width: 48, height: 48, child: Icon(icon, color: fg)),
      ),
    );
  }
}

class _MealChip extends StatelessWidget {
  const _MealChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.dengeColors;
    return Material(
      color: selected ? scheme.primaryContainer : scheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? scheme.primary : colors.divider, width: 1.5),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: selected ? scheme.onPrimaryContainer : scheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _MacroStat extends StatelessWidget {
  const _MacroStat({required this.color, required this.label, required this.grams, required this.percent});

  final Color color;
  final String label;
  final String grams;
  final String percent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(label,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text.rich(
          TextSpan(
            text: grams,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface),
            children: [
              TextSpan(text: ' g', style: theme.textTheme.bodySmall?.copyWith(fontSize: 12)),
            ],
          ),
        ),
        Text(percent, style: theme.textTheme.bodySmall?.copyWith(fontSize: 12, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _MacroRing extends StatelessWidget {
  const _MacroRing({
    required this.proteinKcal,
    required this.carbsKcal,
    required this.fatKcal,
    required this.proteinColor,
    required this.carbsColor,
    required this.fatColor,
    required this.trackColor,
  });

  final double proteinKcal;
  final double carbsKcal;
  final double fatKcal;
  final Color proteinColor;
  final Color carbsColor;
  final Color fatColor;
  final Color trackColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      height: 88,
      child: CustomPaint(
        painter: _MacroRingPainter(
          segments: [proteinKcal, carbsKcal, fatKcal],
          colors: [proteinColor, carbsColor, fatColor],
          trackColor: trackColor,
        ),
      ),
    );
  }
}

class _MacroRingPainter extends CustomPainter {
  _MacroRingPainter({required this.segments, required this.colors, required this.trackColor});

  final List<double> segments;
  final List<Color> colors;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 12.0;
    final rect = Offset.zero & size;
    final circleRect = rect.deflate(strokeWidth / 2);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(circleRect, 0, 2 * math.pi, false, trackPaint);

    final total = segments.fold<double>(0, (a, b) => a + b);
    if (total <= 0) return;

    const gap = 0.06; // radians gap between segments
    var start = -math.pi / 2;
    for (var i = 0; i < segments.length; i++) {
      final sweepFull = 2 * math.pi * (segments[i] / total);
      if (sweepFull <= 0) {
        continue;
      }
      final sweep = math.max(0.0, sweepFull - gap);
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(circleRect, start, sweep, false, paint);
      start += sweepFull;
    }
  }

  @override
  bool shouldRepaint(covariant _MacroRingPainter oldDelegate) {
    return oldDelegate.segments.join() != segments.join() || oldDelegate.trackColor != trackColor;
  }
}
