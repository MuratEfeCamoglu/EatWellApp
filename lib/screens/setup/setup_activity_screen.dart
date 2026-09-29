import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_back_button.dart';

class _ActivityOption {
  const _ActivityOption(this.level, this.title, this.subtitle, this.icon);
  final ActivityLevel level;
  final String title;
  final String subtitle;
  final IconData icon;
}

const _activityOptions = [
  _ActivityOption(ActivityLevel.sedentary, 'Hareketsiz',
      'Masa başı iş, çok az egzersiz', Icons.chair_alt_rounded),
  _ActivityOption(ActivityLevel.light, 'Az hareketli',
      'Haftada 1–3 gün hafif egzersiz', Icons.directions_walk_rounded),
  _ActivityOption(ActivityLevel.moderate, 'Orta derecede aktif',
      'Haftada 3–5 gün egzersiz', Icons.directions_run_rounded),
  _ActivityOption(ActivityLevel.active, 'Çok aktif',
      'Haftada 6–7 gün yoğun antrenman', Icons.fitness_center_rounded),
];

/// Port of project/SetupActivity.dc.html — step 5/6 of the setup flow.
class SetupActivityScreen extends StatefulWidget {
  const SetupActivityScreen({super.key});

  @override
  State<SetupActivityScreen> createState() => _SetupActivityScreenState();
}

class _SetupActivityScreenState extends State<SetupActivityScreen> {
  late ActivityLevel _level = AppState.instance.draft.activityLevel;

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
                  const _SetupProgressHeader(step: 5, label: 'Aktivite'),
                  const SizedBox(height: 32),
                  Text(
                    'Ne kadar aktifsin?',
                    style: textTheme.headlineLarge?.copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Gün içindeki hareketliliğini en iyi anlatan seçeneği seç.',
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  Column(
                    children: [
                      for (final option in _activityOptions) ...[
                        _ActivityCard(
                          option: option,
                          selected: option.level == _level,
                          onTap: () => setState(() => _level = option.level),
                        ),
                        if (option != _activityOptions.last)
                          const SizedBox(height: 12),
                      ],
                    ],
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
                    AppState.instance.draft.activityLevel = _level;
                    Navigator.of(context).pushNamed(AppRoutes.setupGoal);
                  },
                  child: const Text('Devam'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _ActivityOption option;
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
