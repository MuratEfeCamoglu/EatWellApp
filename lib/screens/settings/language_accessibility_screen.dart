import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/app_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/section_card.dart';

/// Denge's "Dil ve erişilebilirlik" (Language & accessibility) screen,
/// reached from Settings. Unlike the row it replaces, everything here is
/// real: text size and reduce-motion apply app-wide immediately, and the
/// language picker is honest about what's actually supported today rather
/// than silently doing nothing when tapped.
class LanguageAccessibilityScreen extends StatelessWidget {
  const LanguageAccessibilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final state = context.watch<AppState>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: Row(
                  children: [
                    const AppBackButton(),
                    Expanded(
                      child: Text(
                        'Dil ve erişilebilirlik',
                        textAlign: TextAlign.center,
                        style: textTheme.titleSmall?.copyWith(fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader('DİL'),
                    const SizedBox(height: 8),
                    SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _LanguageOption(
                            label: 'Türkçe',
                            selected: state.locale.languageCode == 'tr',
                            onTap: () =>
                                context.read<AppState>().setLocale(const Locale('tr')),
                          ),
                          const SizedBox(height: 8),
                          _LanguageOption(
                            label: 'English',
                            subtitle: 'Çok yakında',
                            selected: false,
                            enabled: false,
                            onTap: () {
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(const SnackBar(
                                    content: Text('İngilizce desteği yakında ekleniyor')));
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _SectionHeader('METİN BOYUTU'),
                    const SizedBox(height: 8),
                    SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Uygulama genelinde yazı boyutunu değiştirir.',
                            style: textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final option in TextScaleOption.values)
                                _TextScaleChip(
                                  option: option,
                                  selected: state.textScale == option,
                                  onTap: () =>
                                      context.read<AppState>().setTextScale(option),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Örnek metin',
                            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _SectionHeader('HAREKET'),
                    const SizedBox(height: 8),
                    SectionCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _SwitchRow(
                        icon: Icons.motion_photos_off_rounded,
                        title: 'Azaltılmış hareket',
                        subtitle: 'Sayfa geçişlerindeki animasyonu kapatır',
                        value: state.reduceMotion,
                        onChanged: (v) => context.read<AppState>().setReduceMotion(v),
                      ),
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.enabled = true,
  });

  final String label;
  final String? subtitle;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.dengeColors;
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: selected ? scheme.primaryContainer : scheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected ? scheme.primary : colors.divider, width: 1.5),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: enabled ? null : textTheme.bodyMedium?.color,
                      ),
                    ),
                    if (subtitle != null)
                      Text(subtitle!, style: textTheme.bodySmall),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle_rounded, color: scheme.primary, size: 22)
              else if (!enabled)
                Icon(Icons.lock_clock_rounded, color: textTheme.bodyMedium?.color, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _TextScaleChip extends StatelessWidget {
  const _TextScaleChip({required this.option, required this.selected, required this.onTap});

  final TextScaleOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.dengeColors;
    return Material(
      color: selected ? scheme.primary : scheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? scheme.primary : colors.divider, width: 1.5),
          ),
          child: Text(
            option.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: selected ? scheme.onPrimary : scheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      height: 72,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.dengeColors.trackBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(subtitle, style: textTheme.bodyMedium),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
