import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_back_button.dart';

/// Port of project/SetupGender.dc.html — step 1/6 of the setup flow.
class SetupGenderScreen extends StatefulWidget {
  const SetupGenderScreen({super.key});

  @override
  State<SetupGenderScreen> createState() => _SetupGenderScreenState();
}

class _SetupGenderScreenState extends State<SetupGenderScreen> {
  late Gender _gender = AppState.instance.draft.gender;

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
                  const _SetupProgressHeader(step: 1, label: 'Cinsiyet'),
                  const SizedBox(height: 32),
                  Text(
                    'Cinsiyetin nedir?',
                    style: textTheme.headlineLarge?.copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Günlük kalori ihtiyacını doğru hesaplayabilmemiz için gerekli.',
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: _GenderCard(
                          label: 'Kadın',
                          icon: Icons.female_rounded,
                          selected: _gender == Gender.female,
                          onTap: () => setState(() => _gender = Gender.female),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _GenderCard(
                          label: 'Erkek',
                          icon: Icons.male_rounded,
                          selected: _gender == Gender.male,
                          onTap: () => setState(() => _gender = Gender.male),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: context.dengeColors.divider),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.shield_rounded,
                            size: 20,
                            color: AppTheme.primaryText(scheme.brightness)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Bu bilgi yalnızca bazal metabolizma hızını hesaplamak için kullanılır ve kimseyle paylaşılmaz.',
                            style: textTheme.bodyMedium,
                          ),
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
                    AppState.instance.draft.gender = _gender;
                    Navigator.of(context).pushNamed(AppRoutes.setupAge);
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

class _GenderCard extends StatelessWidget {
  const _GenderCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
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
          height: 184,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? scheme.primary : colors.divider,
              width: 2,
            ),
          ),
          child: Stack(
            children: [
              if (selected)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded,
                        size: 16, color: Colors.white),
                  ),
                ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: selected ? scheme.primary : colors.trackBackground,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        size: 36,
                        color: selected ? Colors.white : scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      label,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
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
