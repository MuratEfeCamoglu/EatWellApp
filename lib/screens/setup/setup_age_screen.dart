import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_back_button.dart';

/// Port of project/SetupAge.dc.html — step 2/6 of the setup flow.
///
/// The design shows a static wheel-picker mock; here it's a working
/// [ListWheelScrollView] the user can flick/drag to change the age.
class SetupAgeScreen extends StatefulWidget {
  const SetupAgeScreen({super.key});

  @override
  State<SetupAgeScreen> createState() => _SetupAgeScreenState();
}

class _SetupAgeScreenState extends State<SetupAgeScreen> {
  static const _minAge = 10;
  static const _maxAge = 100;
  late int _age = AppState.instance.draft.age;

  late final FixedExtentScrollController _controller =
      FixedExtentScrollController(initialItem: _age - _minAge);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SetupProgressHeader(step: 2, label: 'Yaş'),
                  const SizedBox(height: 32),
                  Text(
                    'Kaç yaşındasın?',
                    style: textTheme.headlineLarge?.copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Yaş, metabolizma hızını etkileyen önemli bir etken.',
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  Container(
                    height: 320,
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
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          height: 64,
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        ListWheelScrollView.useDelegate(
                          controller: _controller,
                          itemExtent: 64,
                          diameterRatio: 2.2,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (i) =>
                              setState(() => _age = _minAge + i),
                          childDelegate: ListWheelChildBuilderDelegate(
                            childCount: _maxAge - _minAge + 1,
                            builder: (context, i) {
                              final age = _minAge + i;
                              final diff = (age - _age).abs();
                              if (diff == 0) {
                                return Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        '$age',
                                        style: TextStyle(
                                          fontSize: 40,
                                          fontWeight: FontWeight.w800,
                                          color: scheme.brightness ==
                                                  Brightness.dark
                                              ? const Color(0xFF6FD49B)
                                              : const Color(0xFF1D7445),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text('yaş',
                                          style: textTheme.bodyMedium
                                              ?.copyWith(fontSize: 16)),
                                    ],
                                  ),
                                );
                              }
                              final opacity = diff == 1
                                  ? 0.5
                                  : diff == 2
                                      ? 0.25
                                      : 0.12;
                              final fontSize = diff == 1 ? 24.0 : 20.0;
                              return Center(
                                child: Opacity(
                                  opacity: opacity,
                                  child: Text(
                                    '$age',
                                    style: TextStyle(
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.w800,
                                      color: scheme.onSurface,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text('Kaydırarak yaşını seç',
                        style: textTheme.bodyMedium),
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
                    AppState.instance.draft.age = _age;
                    Navigator.of(context).pushNamed(AppRoutes.setupHeight);
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
