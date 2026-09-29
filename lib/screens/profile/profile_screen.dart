import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/app_state.dart';
import '../../data/mock_data.dart';
import '../../router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/section_card.dart';

const _months = [
  'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
  'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
];

/// Denge's Profile tab (project/Profile.dc.html / Profile-dark.dc.html):
/// avatar header with streak/log/badge stats, a weight-goal progress card,
/// a badges grid, and a menu list. The gear icon and the "Ayarlar" row push
/// [SettingsScreen]; the remaining rows are inert (no backend to open them).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final colors = context.dengeColors;
    final state = context.watch<AppState>();
    final user = state.user;

    // The design's weight-goal card shows a starting weight above the
    // current one; use the first real logged weight (from setup) rather
    // than a fabricated "already lost some" guess — a brand-new profile
    // should show 0% progress, not invented history.
    final startWeight =
        state.weightHistory.isEmpty ? user.weightKg : state.weightHistory.first.kg;
    final remaining = (user.weightKg - user.goalWeightKg).clamp(0, 999);
    final weightSpan = startWeight - user.goalWeightKg;
    final progress = weightSpan == 0
        ? 0.0
        : ((startWeight - user.weightKg) / weightSpan).clamp(0.0, 1.0);

    final weeklyPace = state.weeklyPaceKg;
    final weeksToGoal = remaining <= 0 ? 0 : (remaining / weeklyPace).ceil();
    final etaDate = DateTime.now().add(Duration(days: weeksToGoal * 7));
    final etaLabel =
        weeksToGoal == 0 ? null : '${etaDate.day} ${_months[etaDate.month - 1]}';

    // Infer the goal direction from the actual weight numbers (rather than
    // the setup wizard's transient draft, which doesn't survive an app
    // restart) so this never contradicts what the user actually chose.
    final goalDelta = user.goalWeightKg - user.weightKg;
    final IconData goalIcon;
    final String goalTitle;
    if (goalDelta.abs() < 0.5) {
      goalIcon = Icons.drag_handle_rounded;
      goalTitle = 'Kilo koruma hedefi';
    } else if (goalDelta < 0) {
      goalIcon = Icons.trending_down_rounded;
      goalTitle = 'Kilo verme hedefi';
    } else {
      goalIcon = Icons.trending_up_rounded;
      goalTitle = 'Kilo alma hedefi';
    }
    final paceLabel = goalDelta.abs() < 0.5
        ? _thousands(user.calorieGoal)
        : 'Haftada ${_fmt1(weeklyPace)} kg · ${_thousands(user.calorieGoal)}';

    final daysLogged = state.hasLoggedFoodToday ? 1 : 0;
    final badgeFirstStep = state.hasLoggedFoodToday;
    final badgeStreak7 = user.streakDays >= 7;
    final badgeWaterMaster = state.waterGlasses >= MockData.waterGlassesGoal;
    final badgeProteinHunter =
        user.proteinGoalG > 0 && state.proteinConsumedG >= user.proteinGoalG;
    final unlockedBadges = [
      badgeFirstStep,
      badgeStreak7,
      badgeWaterMaster,
      badgeProteinHunter,
    ].where((b) => b).length;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Profil',
                      style: textTheme.headlineLarge?.copyWith(fontSize: 28),
                    ),
                    _SquareIconButton(
                      icon: Icons.settings_rounded,
                      semanticLabel: 'Ayarlar',
                      onTap: () =>
                          Navigator.of(context).push(AppRoutes.pushSettings()),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Column(
                  children: [
                    // Avatar / name / stats card.
                    SectionCard(
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 36,
                                backgroundColor: scheme.primaryContainer,
                                child: Text(
                                  user.initials,
                                  style: textTheme.titleLarge?.copyWith(
                                    fontSize: 24,
                                    color: scheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.name,
                                      style: textTheme.titleLarge
                                          ?.copyWith(fontSize: 20),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(user.email,
                                        style: textTheme.bodyMedium),
                                    const SizedBox(height: 2),
                                    if (state.memberSince != null)
                                      Text(
                                        '${_months[state.memberSince!.month - 1]} '
                                        '${state.memberSince!.year}’dan beri üye',
                                        style: textTheme.bodySmall,
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              _SquareIconButton(
                                icon: Icons.edit_rounded,
                                semanticLabel: 'Profili düzenle',
                                onTap: () {},
                              ),
                            ],
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 20),
                            padding: const EdgeInsets.only(top: 16),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(color: colors.divider),
                              ),
                            ),
                            child: Row(
                              children: [
                                _StatColumn(
                                    value: '${user.streakDays}',
                                    label: 'gün seri'),
                                _StatColumn(value: '$daysLogged', label: 'gün kayıt'),
                                _StatColumn(value: '$unlockedBadges', label: 'rozet'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Weight-goal progress card.
                    SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: scheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Icon(goalIcon,
                                    size: 20, color: scheme.onPrimaryContainer),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(goalTitle,
                                        style: textTheme.titleSmall
                                            ?.copyWith(fontSize: 16)),
                                    Text(
                                      '$paceLabel kcal/gün',
                                      style: textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${_fmt1(startWeight)} kg',
                                  style: textTheme.bodySmall
                                      ?.copyWith(fontSize: 14)),
                              Text(
                                '${_fmt1(user.weightKg)} kg',
                                style: textTheme.headlineMedium?.copyWith(
                                    fontSize: 28, letterSpacing: -0.5),
                              ),
                              Text('${_fmt1(user.goalWeightKg)} kg',
                                  style: textTheme.bodySmall
                                      ?.copyWith(fontSize: 14)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 10,
                              backgroundColor: colors.trackBackground,
                              valueColor:
                                  AlwaysStoppedAnimation(scheme.primary),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            etaLabel == null
                                ? 'Hedefe ${_fmt1(remaining.toDouble())} kg kaldı'
                                : 'Hedefe ${_fmt1(remaining.toDouble())} kg kaldı · tahmini $etaLabel',
                            style: textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                              color: scheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Badges card.
                    SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Rozetler',
                                  style: textTheme.titleSmall
                                      ?.copyWith(fontSize: 16)),
                              TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text('Tümü (4)'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _Badge(
                                  icon: Icons.emoji_events_rounded,
                                  label: 'İlk adım',
                                  color: badgeFirstStep ? colors.carbs : null,
                                ),
                              ),
                              Expanded(
                                child: _Badge(
                                  icon: Icons.local_fire_department_rounded,
                                  label: '7 gün seri',
                                  color: badgeStreak7 ? colors.streak : null,
                                ),
                              ),
                              Expanded(
                                child: _Badge(
                                  icon: Icons.water_drop_rounded,
                                  label: 'Su ustası',
                                  color: badgeWaterMaster ? colors.water : null,
                                ),
                              ),
                              Expanded(
                                child: _Badge(
                                  icon: Icons.bolt_rounded,
                                  label: 'Protein avcısı',
                                  color: badgeProteinHunter ? colors.protein : null,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Menu list.
                    SectionCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          _MenuRow(
                            icon: Icons.person_outline_rounded,
                            label: 'Kişisel bilgiler',
                            onTap: () {},
                          ),
                          _MenuRow(
                            icon: Icons.track_changes_rounded,
                            label: 'Hedefler ve makrolar',
                            trailingText:
                                '${_thousands(user.calorieGoal)} kcal',
                            showTopDivider: true,
                            onTap: () {},
                          ),
                          _MenuRow(
                            icon: Icons.notifications_none_rounded,
                            label: 'Bildirimler',
                            showTopDivider: true,
                            onTap: () {},
                          ),
                          _MenuRow(
                            icon: Icons.tune_rounded,
                            label: 'Ayarlar',
                            showTopDivider: true,
                            onTap: () => Navigator.of(context)
                                .push(AppRoutes.pushSettings()),
                          ),
                          _MenuRow(
                            icon: Icons.help_outline_rounded,
                            label: 'Yardım ve destek',
                            showTopDivider: true,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
              const SizedBox(height: 88),
            ],
          ),
        ),
      ),
    );
  }
}

String _fmt1(double v) => v.toStringAsFixed(1).replaceAll('.', ',');

String _thousands(int n) {
  final s = n.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return buf.toString();
}

class _SquareIconButton extends StatelessWidget {
  const _SquareIconButton({
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: context.dengeColors.divider),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Semantics(
            label: semanticLabel,
            child: Icon(icon, size: 22, color: scheme.onSurface),
          ),
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        children: [
          Text(value, style: textTheme.titleLarge?.copyWith(fontSize: 20)),
          const SizedBox(height: 2),
          Text(label, style: textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = context.dengeColors;
    final locked = color == null;
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: locked ? null : color!.withValues(alpha: 0.16),
            border: locked
                ? Border.all(color: colors.divider, width: 2)
                : null,
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: locked ? 22 : 28, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(height: 1.3),
        ),
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailingText,
    this.showTopDivider = false,
  });

  final IconData icon;
  final String label;
  final String? trailingText;
  final bool showTopDivider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = context.dengeColors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: showTopDivider
              ? BoxDecoration(
                  border: Border(top: BorderSide(color: colors.divider)))
              : null,
          constraints: const BoxConstraints(minHeight: 60),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.trackBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label,
                    style:
                        textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
              ),
              if (trailingText != null) ...[
                Text(trailingText!,
                    style: textTheme.bodySmall?.copyWith(fontSize: 14)),
                const SizedBox(width: 4),
              ],
              Icon(Icons.chevron_right_rounded,
                  color: Theme.of(context).textTheme.bodyMedium?.color),
            ],
          ),
        ),
      ),
    );
  }
}
