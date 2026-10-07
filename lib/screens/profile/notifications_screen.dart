import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/app_state.dart';
import '../../data/reminders.dart';
import '../../theme/app_colors.dart';
import '../../widgets/form_parts.dart';
import '../../widgets/section_card.dart';

/// "Bildirimler": meal, water and weekly-summary reminders. Every change is
/// saved and (re)scheduled immediately as a local notification on the
/// phone; turning one on asks for the notification permission.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  Future<void> _update(BuildContext context, NotificationSettings next) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final granted =
          await context.read<AppState>().updateNotificationSettings(next);
      if (!granted) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(
            content: Text('Bildirim izni verilmedi. Hatırlatıcıların gelmesi '
                'için telefonunun ayarlarından Denge\'ye izin ver.'),
            duration: Duration(seconds: 6),
          ));
      }
    } catch (_) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
            content: Text('Hatırlatıcılar ayarlanamadı, lütfen tekrar dene.')));
    }
  }

  Future<void> _pickTime(BuildContext context, int minutes,
      NotificationSettings Function(int) apply) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
      helpText: 'Hatırlatma saati',
      cancelText: 'Vazgeç',
      confirmText: 'Tamam',
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked == null || !context.mounted) return;
    await _update(context, apply(picked.hour * 60 + picked.minute));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = context.watch<AppState>().notificationSettings;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const FormScreenHeader('Bildirimler'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          _SwitchTile(
                            icon: Icons.restaurant_menu_rounded,
                            title: 'Öğün hatırlatıcıları',
                            subtitle: 'Öğün saatinde günlüğünü doldurmanı hatırlatır',
                            value: s.mealReminders,
                            onChanged: (v) =>
                                _update(context, s.copyWith(mealReminders: v)),
                          ),
                          for (final (label, minutes, apply) in [
                            (
                              'Kahvaltı',
                              s.breakfastMinutes,
                              (int m) => s.copyWith(breakfastMinutes: m)
                            ),
                            (
                              'Öğle yemeği',
                              s.lunchMinutes,
                              (int m) => s.copyWith(lunchMinutes: m)
                            ),
                            (
                              'Akşam yemeği',
                              s.dinnerMinutes,
                              (int m) => s.copyWith(dinnerMinutes: m)
                            ),
                          ])
                            _TimeTile(
                              label: label,
                              time: formatMinutes(minutes),
                              enabled: s.mealReminders,
                              onTap: () => _pickTime(context, minutes, apply),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SectionCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SwitchTile(
                            icon: Icons.water_drop_rounded,
                            title: 'Su hatırlatıcıları',
                            subtitle:
                                '09:00–21:00 arası, her ${s.waterIntervalHours} saatte bir',
                            value: s.waterReminders,
                            onChanged: (v) =>
                                _update(context, s.copyWith(waterReminders: v)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: ChoiceChipGroup<int>(
                              label: 'Hatırlatma aralığı',
                              options: [for (final h in [1, 2, 3, 4]) (h, '$h saat')],
                              selected: s.waterIntervalHours,
                              onSelected: (h) => _update(
                                  context, s.copyWith(waterIntervalHours: h)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SectionCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _SwitchTile(
                        icon: Icons.insights_rounded,
                        title: 'Haftalık özet',
                        subtitle: 'Pazar akşamı 20:00\'de ilerlemene göz atmanı hatırlatır',
                        value: s.weeklySummary,
                        onChanged: (v) =>
                            _update(context, s.copyWith(weeklySummary: v)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Hatırlatıcılar telefonunda yerel olarak planlanır; internet '
                      'gerekmez ve hiçbir veri dışarı gönderilmez.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
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
    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  Text(subtitle, style: textTheme.bodyMedium),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

class _TimeTile extends StatelessWidget {
  const _TimeTile({
    required this.label,
    required this.time,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final String time;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: context.dengeColors.divider))),
      constraints: const BoxConstraints(minHeight: 56),
      child: Row(
        children: [
          const SizedBox(width: 36),
          Expanded(
            child: Text(label,
                style: theme.textTheme.bodyLarge?.copyWith(
                    color: enabled ? null : theme.disabledColor)),
          ),
          TextButton(
            onPressed: enabled ? onTap : null,
            style: TextButton.styleFrom(
              backgroundColor: enabled ? scheme.primaryContainer : null,
              foregroundColor: scheme.onPrimaryContainer,
              minimumSize: const Size(88, 44),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(time,
                semanticsLabel: '$label saati $time',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}
