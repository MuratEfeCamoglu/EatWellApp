import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_back_button.dart';

class _GoalOption {
  const _GoalOption(this.goal, this.title, this.subtitle, this.icon);
  final WeightGoal goal;
  final String title;
  final String subtitle;
  final IconData icon;
}

const _goalOptions = [
  _GoalOption(WeightGoal.lose, 'Kilo vermek', 'Sağlıklı bir kalori açığıyla',
      Icons.trending_down_rounded),
  _GoalOption(WeightGoal.maintain, 'Kilomu korumak',
      'Dengeli ve sürdürülebilir beslenme', Icons.drag_handle_rounded),
  _GoalOption(WeightGoal.gain, 'Kilo almak', 'Kas kütlesi ve enerji için',
      Icons.trending_up_rounded),
];

const _weeklyPaceOptions = [0.25, 0.5, 0.75];

/// Port of project/SetupGoal.dc.html — step 6/6 of the setup flow.
///
/// The "Hedef kilo" used to always show a fixed mock number regardless of
/// what was actually picked here — someone choosing "Kilomu korumak" would
/// still see a lower target weight than their current one. It now reacts to
/// the chosen goal (locked to the current weight for "maintain") and stays
/// user-editable for lose/gain, since only the user actually knows their
/// real target.
class SetupGoalScreen extends StatefulWidget {
  const SetupGoalScreen({super.key});

  @override
  State<SetupGoalScreen> createState() => _SetupGoalScreenState();
}

class _SetupGoalScreenState extends State<SetupGoalScreen> {
  late final double _currentWeightKg = AppState.instance.draft.weightKg;
  WeightGoal _goal = AppState.instance.draft.goal;
  double _weeklyPace = AppState.instance.draft.weeklyPaceKg;
  late double _goalWeightKg = AppState.instance.draft.goalWeightKg ??
      AppState.instance.suggestedGoalWeightKg(_goal, _currentWeightKg);
  bool _goalWeightEditedByUser = false;

  void _onGoalChanged(WeightGoal goal) {
    setState(() {
      _goal = goal;
      if (goal == WeightGoal.maintain) {
        // Maintaining never makes sense with a different target weight.
        _goalWeightKg = _currentWeightKg;
        _goalWeightEditedByUser = false;
      } else if (!_goalWeightEditedByUser) {
        _goalWeightKg =
            AppState.instance.suggestedGoalWeightKg(goal, _currentWeightKg);
      }
    });
  }

  Future<void> _editGoalWeight() async {
    final controller = TextEditingController(text: _goalWeightKg.round().toString());
    final result = await showDialog<double>(
      context: context,
      builder: (context) {
        String? error;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            void submit() {
              final value = double.tryParse(controller.text.replaceAll(',', '.'));
              if (value == null || value < 30 || value > 300) {
                setDialogState(() => error = 'Geçerli bir kilo girin');
                return;
              }
              if (_goal == WeightGoal.lose && value >= _currentWeightKg) {
                setDialogState(
                    () => error = 'Hedef, şu anki kilondan (${_currentWeightKg.round()} kg) düşük olmalı');
                return;
              }
              if (_goal == WeightGoal.gain && value <= _currentWeightKg) {
                setDialogState(
                    () => error = 'Hedef, şu anki kilondan (${_currentWeightKg.round()} kg) yüksek olmalı');
                return;
              }
              Navigator.of(context).pop(value);
            }

            return AlertDialog(
              title: const Text('Hedef kilon'),
              content: TextField(
                controller: controller,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  suffixText: 'kg',
                  errorText: error,
                ),
                onSubmitted: (_) => submit(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Vazgeç'),
                ),
                ElevatedButton(
                  onPressed: submit,
                  child: const Text('Kaydet'),
                ),
              ],
            );
          },
        );
      },
    );
    controller.dispose();
    if (result != null) {
      setState(() {
        _goalWeightKg = result;
        _goalWeightEditedByUser = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SetupProgressHeader(step: 6, label: 'Hedef'),
                  const SizedBox(height: 32),
                  Text(
                    'Hedefin ne?',
                    style: textTheme.headlineLarge?.copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Planını hedefine göre kişiselleştireceğiz.',
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  Column(
                    children: [
                      for (final option in _goalOptions) ...[
                        _GoalCard(
                          option: option,
                          selected: option.goal == _goal,
                          onTap: () => _onGoalChanged(option.goal),
                        ),
                        if (option != _goalOptions.last) const SizedBox(height: 12),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Hedef kilo',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w800)),
                            if (_goal == WeightGoal.maintain)
                              Text(
                                '${_goalWeightKg.round()} kg',
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w800),
                              )
                            else
                              InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: _editGoalWeight,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 2),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${_goalWeightKg.round()} kg',
                                        style: const TextStyle(
                                            fontSize: 20, fontWeight: FontWeight.w800),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(Icons.edit_rounded,
                                          size: 16, color: scheme.primary),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text('Haftalık tempo', style: textTheme.bodyMedium),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            for (final pace in _weeklyPaceOptions) ...[
                              Expanded(
                                child: _PaceChip(
                                  label: '${pace.toString().replaceAll('.', ',')} kg',
                                  selected: pace == _weeklyPace,
                                  onTap: () => setState(() => _weeklyPace = pace),
                                ),
                              ),
                              if (pace != _weeklyPaceOptions.last)
                                const SizedBox(width: 8),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final draft = AppState.instance.draft;
                    draft.goal = _goal;
                    draft.weeklyPaceKg = _weeklyPace;
                    draft.goalWeightKg = _goalWeightKg;
                    AppState.instance.completeSetup();
                    Navigator.of(context).pushNamed(AppRoutes.setupResult);
                  },
                  child: const Text('Planımı hesapla'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _GoalOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.dengeColors;
    return Material(
      color: selected ? scheme.primaryContainer : scheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 80),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? scheme.primary : colors.divider,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: selected ? scheme.primary : colors.trackBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  option.icon,
                  size: 24,
                  color: selected ? Colors.white : scheme.onSurface,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(option.title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(option.subtitle, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: selected ? scheme.primary : Colors.transparent,
                  shape: BoxShape.circle,
                  border: selected ? null : Border.all(color: colors.divider, width: 2),
                ),
                child: selected
                    ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaceChip extends StatelessWidget {
  const _PaceChip({required this.label, required this.selected, required this.onTap});

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
            border: Border.all(
              color: selected ? scheme.primary : colors.divider,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: selected
                  ? (scheme.brightness == Brightness.dark
                      ? const Color(0xFF6FD49B)
                      : const Color(0xFF1D7445))
                  : scheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

/// The "Adım X / 6" step header + back button + progress dots used by every
/// screen in the setup flow (project/Setup*.dc.html). Duplicated privately in
/// each setup screen file rather than extracted to a shared widget, since
/// each of these screens is edited independently.
class _SetupProgressHeader extends StatelessWidget {
  const _SetupProgressHeader({
    required this.step,
    required this.label,
  });

  static const totalSteps = 6;

  final int step;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.dengeColors;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const AppBackButton(),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Adım $step / $totalSteps',
                      style: textTheme.bodySmall
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  Text(label,
                      style: textTheme.bodySmall
                          ?.copyWith(fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(totalSteps, (i) {
                  final filled = i < step;
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: i == totalSteps - 1 ? 0 : 4),
                      height: 6,
                      decoration: BoxDecoration(
                        color: filled ? scheme.primary : colors.trackBackground,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
