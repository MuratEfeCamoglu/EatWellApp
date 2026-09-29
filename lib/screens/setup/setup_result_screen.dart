import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

const _months = [
  'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
  'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
];

/// Port of project/SetupResult.dc.html — the final "here's your plan"
/// screen shown after the 6-step setup flow.
///
/// Simplification: the design's scattered confetti-dot SVG background is
/// left out; everything else (the calorie ring, headline, target date and
/// macro split) uses the profile [AppState.completeSetup] just computed
/// from what was actually answered in the wizard.
class SetupResultScreen extends StatelessWidget {
  const SetupResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.dengeColors;
    final textTheme = Theme.of(context).textTheme;
    final user = AppState.instance.user;

    final weeklyPaceKg = AppState.instance.draft.weeklyPaceKg;
    final weightToLoseKg = (user.weightKg - user.goalWeightKg).abs();
    final weeksToGoal = weeklyPaceKg > 0
        ? (weightToLoseKg / weeklyPaceKg).ceil()
        : 0;
    final targetDate = DateTime.now().add(Duration(days: weeksToGoal * 7));
    final targetDateLabel = '${targetDate.day} ${_months[targetDate.month - 1]}';
    final firstName = user.name.split(' ').first;

    final proteinPct = (user.proteinGoalG * 4 * 100 / user.calorieGoal).round();
    final carbsPct = (user.carbsGoalG * 4 * 100 / user.calorieGoal).round();
    final fatPct = (user.fatGoalG * 9 * 100 / user.calorieGoal).round();

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 140),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 208,
                    height: 208,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: scheme.surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: scheme.primaryContainer, width: 8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.07),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Günlük hedefin', style: textTheme.bodyMedium),
                            const SizedBox(height: 4),
                            Text(
                              _thousands(user.calorieGoal),
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1,
                                color: AppTheme.primaryText(scheme.brightness),
                              ),
                            ),
                            Text('kcal',
                                style: textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Planın hazır, $firstName!',
                    textAlign: TextAlign.center,
                    style: textTheme.headlineLarge?.copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 8),
                  Text.rich(
                    TextSpan(
                      style: textTheme.bodyMedium?.copyWith(fontSize: 16, height: 1.5),
                      children: [
                        TextSpan(
                          text: 'Bu hedefle haftada '
                              '${weeklyPaceKg.toString().replaceAll('.', ',')} kg vererek ',
                        ),
                        TextSpan(
                          text: targetDateLabel,
                          style: TextStyle(
                              fontWeight: FontWeight.w800, color: scheme.onSurface),
                        ),
                        TextSpan(
                          text: ' civarında ${user.goalWeightKg.round()} kg’a ulaşabilirsin.',
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _MacroCard(
                          color: colors.protein,
                          label: 'Protein',
                          value: '${user.proteinGoalG} g',
                          percent: '%$proteinPct',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MacroCard(
                          color: colors.carbs,
                          label: 'Karbonhidrat',
                          value: '${user.carbsGoalG} g',
                          percent: '%$carbsPct',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MacroCard(
                          color: colors.fat,
                          label: 'Yağ',
                          value: '${user.fatGoalG} g',
                          percent: '%$fatPct',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context)
                          .pushNamedAndRemoveUntil(AppRoutes.main, (route) => false),
                      icon: const Icon(Icons.auto_awesome_rounded, size: 20),
                      label: const Text('Hadi başlayalım'),
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Hedefimi düzenle'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _thousands(int value) {
    final s = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
      buffer.write(s[i]);
    }
    return buffer.toString();
  }
}

class _MacroCard extends StatelessWidget {
  const _MacroCard({
    required this.color,
    required this.label,
    required this.value,
    required this.percent,
  });

  final Color color;
  final String label;
  final String value;
  final String percent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(percent, style: textTheme.bodySmall),
        ],
      ),
    );
  }
}
