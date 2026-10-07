import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/app_state.dart';
import '../../data/custom_food.dart' show parseNutritionNumber;
import '../../data/nutrition_targets.dart';
import '../../data/profile_validation.dart';
import '../../router.dart';
import '../../widgets/form_parts.dart';
import '../../widgets/section_card.dart';

const _paceOptions = [0.25, 0.5, 0.75];

/// "Hedefler ve makrolar": goal direction, goal weight and weekly pace,
/// plus the daily calorie and macro goals. The setup formula's suggestion
/// is shown alongside and can be applied with one tap; the user may also
/// type their own numbers (e.g. ones a dietitian gave them).
class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final AppState _state = context.read<AppState>();
  late WeightGoal _goal = _state.effectiveGoal;
  late double _pace = _state.weeklyPaceKg;
  late final _goalWeight =
      TextEditingController(text: _fmt(_state.user.goalWeightKg));
  late final _calories =
      TextEditingController(text: '${_state.user.calorieGoal}');
  late final _protein =
      TextEditingController(text: '${_state.user.proteinGoalG}');
  late final _carbs = TextEditingController(text: '${_state.user.carbsGoalG}');
  late final _fat = TextEditingController(text: '${_state.user.fatGoalG}');
  bool _saving = false;

  static String _fmt(double v) {
    if (v <= 0) return '';
    if (v == v.roundToDouble()) return v.round().toString();
    return v.toStringAsFixed(1).replaceAll('.', ',');
  }

  static String _paceLabel(double p) => '${_fmt(p)} kg';

  @override
  void dispose() {
    for (final c in [_goalWeight, _calories, _protein, _carbs, _fat]) {
      c.dispose();
    }
    super.dispose();
  }

  void _setGoal(WeightGoal goal) {
    setState(() {
      _goal = goal;
      // Maintaining always targets the current weight, like the wizard.
      if (goal == WeightGoal.maintain) {
        _goalWeight.text = _fmt(_state.user.weightKg);
      }
    });
  }

  void _applySuggestion(NutritionTargets t) {
    setState(() {
      _calories.text = '${t.calories}';
      _protein.text = '${t.proteinG}';
      _carbs.text = '${t.carbsG}';
      _fat.text = '${t.fatG}';
    });
  }

  String? _validateGoalWeight(String v) {
    final base = validateGoalWeight(v);
    if (base != null) return base;
    final kg = parseNutritionNumber(v)!;
    final current = _state.user.weightKg;
    if (current > 0 && _goal == WeightGoal.lose && kg >= current) {
      return 'Kilo vermek için hedef, şu anki kilondan ($current kg) düşük olmalı';
    }
    if (current > 0 && _goal == WeightGoal.gain && kg <= current) {
      return 'Kilo almak için hedef, şu anki kilondan ($current kg) yüksek olmalı';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _saving = true);
    try {
      await _state.updateGoals(
        goal: _goal,
        goalWeightKg: parseNutritionNumber(_goalWeight.text)!,
        weeklyPaceKg: _pace,
        calorieGoal: int.parse(_calories.text.trim()),
        proteinG: int.parse(_protein.text.trim()),
        carbsG: int.parse(_carbs.text.trim()),
        fatG: int.parse(_fat.text.trim()),
      );
    } catch (_) {
      if (mounted) setState(() => _saving = false);
      messenger.showSnackBar(const SnackBar(
          content: Text('Hedefler kaydedilemedi, lütfen tekrar dene.')));
      return;
    }
    messenger.showSnackBar(
        const SnackBar(content: Text('Hedeflerin güncellendi')));
    navigator.pop();
  }

  /// Total kcal of the typed macros, and how far it is from the typed
  /// calorie goal (null while either can't be parsed).
  (int, int)? _macroCheck() {
    final cal = int.tryParse(_calories.text.trim());
    final p = int.tryParse(_protein.text.trim());
    final c = int.tryParse(_carbs.text.trim());
    final f = int.tryParse(_fat.text.trim());
    if (cal == null || cal <= 0 || p == null || c == null || f == null) {
      return null;
    }
    final total = macroKcal(proteinG: p, carbsG: c, fatG: f);
    return (total, ((total - cal) * 100 / cal).round());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.watch<AppState>();
    final suggestion = state.suggestedTargets(
        goal: _goal,
        weeklyPaceKg: _goal == WeightGoal.maintain ? 0 : _pace);
    final check = _macroCheck();
    final paces = {..._paceOptions, _pace}.toList()..sort();
    void refresh(String _) => setState(() {});

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const FormScreenHeader('Hedefler ve makrolar'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ChoiceChipGroup<WeightGoal>(
                        label: 'Hedefin',
                        options: [
                          for (final g in WeightGoal.values) (g, g.label)
                        ],
                        selected: _goal,
                        onSelected: _setGoal,
                      ),
                      LabeledTextField(
                        label: 'Hedef kilo',
                        controller: _goalWeight,
                        suffix: 'kg',
                        enabled: _goal != WeightGoal.maintain,
                        keyboardType: LabeledTextField.number,
                        validator: _validateGoalWeight,
                      ),
                      if (_goal != WeightGoal.maintain)
                        ChoiceChipGroup<double>(
                          label: 'Haftalık tempo',
                          options: [for (final p in paces) (p, _paceLabel(p))],
                          selected: _pace,
                          onSelected: (p) => setState(() => _pace = p),
                        ),
                      _SuggestionCard(
                        suggestion: suggestion,
                        onApply: suggestion == null
                            ? null
                            : () => _applySuggestion(suggestion),
                        onCompleteProfile: () => Navigator.of(context)
                            .push(AppRoutes.pushPersonalInfo()),
                      ),
                      const SizedBox(height: 20),
                      LabeledTextField(
                        label: 'Günlük kalori hedefi',
                        controller: _calories,
                        suffix: 'kcal',
                        keyboardType: TextInputType.number,
                        validator: validateCalorieGoal,
                        onChanged: refresh,
                      ),
                      LabeledTextField(
                        label: 'Protein',
                        controller: _protein,
                        suffix: 'g',
                        keyboardType: TextInputType.number,
                        validator: validateMacroGoal,
                        onChanged: refresh,
                      ),
                      LabeledTextField(
                        label: 'Karbonhidrat',
                        controller: _carbs,
                        suffix: 'g',
                        keyboardType: TextInputType.number,
                        validator: validateMacroGoal,
                        onChanged: refresh,
                      ),
                      LabeledTextField(
                        label: 'Yağ',
                        controller: _fat,
                        suffix: 'g',
                        keyboardType: TextInputType.number,
                        validator: validateMacroGoal,
                        onChanged: refresh,
                      ),
                      if (check != null)
                        Text(
                          check.$2.abs() > 10
                              ? 'Makroların toplamı ${check.$1} kcal; kalori '
                                  'hedefinden %${check.$2.abs()} '
                                  '${check.$2 > 0 ? 'fazla' : 'az'}.'
                              : 'Makroların toplamı ${check.$1} kcal, '
                                  'kalori hedefinle uyumlu.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: check.$2.abs() > 10
                                ? theme.colorScheme.error
                                : null,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: const Icon(Icons.check_rounded),
                label: const Text('Kaydet'),
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({
    required this.suggestion,
    required this.onApply,
    required this.onCompleteProfile,
  });

  final NutritionTargets? suggestion;
  final VoidCallback? onApply;
  final VoidCallback onCompleteProfile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = suggestion;
    return SectionCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Önerilen hedef', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          if (s == null) ...[
            Text(
              'Öneri için Kişisel bilgiler\'de cinsiyet, yaş, boy ve aktivite '
              'düzeyini doldur.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onCompleteProfile,
              child: const Text('Kişisel bilgilere git'),
            ),
          ] else ...[
            Text(
              '${s.calories} kcal · P ${s.proteinG} g · K ${s.carbsG} g · '
              'Y ${s.fatG} g',
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              'Boy, kilo, yaş ve aktivite düzeyine göre (Mifflin-St Jeor).',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onApply,
              child: const Text('Önerileni kullan'),
            ),
          ],
        ],
      ),
    );
  }
}
