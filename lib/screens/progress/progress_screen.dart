import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/app_state.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';
import '../../data/stats/weight_series.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/weight_input_dialog.dart';

/// İlerleme (Progress) tab: weight trend chart, goal progress and a couple
/// of streak/water stat tiles, driven by [AppState]'s stored weight log
/// (the last measurement of each day; the last 7 or 30 days on the chart)
/// rather than a fabricated multi-week trend.
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  bool _weekly = true;

  static const _monthShort = [
    'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
    'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara',
  ];

  String _formatKg(double v) => v.toStringAsFixed(1).replaceAll('.', ',');

  String _shortDate(DateTime d) => '${d.day} ${_monthShort[d.month - 1]}';

  Future<void> _logWeight(BuildContext context, double currentWeight) async {
    final result = await showWeightInputDialog(
      context,
      title: 'Kilonu güncelle',
      initialKg: currentWeight,
    );
    if (result == null || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await context.read<AppState>().logWeight(result);
    } catch (_) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
            content: Text('Kilo kaydedilemedi, lütfen tekrar dene.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dengeColors = context.dengeColors;

    final state = context.watch<AppState>();
    final user = state.user;
    final now = state.clock();
    final daily = state.weightHistory.isEmpty
        ? [WeightEntry(now, user.weightKg)]
        : latestPerDay(state.weightHistory);
    final history = lastDays(daily, now, _weekly ? 7 : 30);
    final startWeight = daily.first.kg;
    final currentWeight = daily.last.kg;
    final goalWeight = user.goalWeightKg;
    final remainingKg = (currentWeight - goalWeight).clamp(0, double.infinity);
    final totalToLose = (startWeight - goalWeight).abs();
    final progressPct = totalToLose == 0
        ? 0.0
        : (((startWeight - currentWeight) / totalToLose).clamp(0.0, 1.0));

    // Change across the visible window (last 7 / 30 days).
    final change = history.last.kg - history.first.kg;
    final changeLabel = _weekly ? 'son 7 gün' : 'son 30 gün';

    final waterPct = MockData.waterGlassesGoal == 0
        ? 0
        : ((state.waterGlasses / MockData.waterGlassesGoal) * 100).round();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('İlerleme', style: theme.textTheme.headlineLarge),
                  _RoundIconButton(
                    icon: Icons.calendar_month_rounded,
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _SegmentedTabs(
                weekly: _weekly,
                onChanged: (weekly) => setState(() => _weekly = weekly),
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionCardLike(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Kilo', style: theme.textTheme.titleSmall),
                              const SizedBox(height: AppSpacing.xs),
                              RichText(
                                text: TextSpan(
                                  style: theme.textTheme.headlineMedium
                                      ?.copyWith(fontSize: 32),
                                  children: [
                                    TextSpan(text: _formatKg(currentWeight)),
                                    TextSpan(
                                      text: ' kg',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    change <= 0
                                        ? Icons.trending_down_rounded
                                        : Icons.trending_up_rounded,
                                    size: 16,
                                    color: AppTheme.primaryText(
                                        theme.brightness),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${change <= 0 ? '' : '+'}${_formatKg(change)} kg',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.primaryText(
                                          theme.brightness),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    changeLabel,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _logWeight(context, currentWeight),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(0, 48),
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg),
                            textStyle: const TextStyle(fontSize: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(Icons.add_rounded, size: 20),
                          label: const Text('Kilo ekle'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      height: 180,
                      child: _WeightChart(
                        history: history,
                        color: scheme.primary,
                        gridColor: dengeColors.divider,
                        labelColor: theme.textTheme.bodySmall?.color ??
                            scheme.onSurface,
                        labelFor: _shortDate,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionCardLike(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Hedefe ilerleme',
                            style: theme.textTheme.titleSmall),
                        Text(
                          '%${(progressPct * 100).round()}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryText(theme.brightness),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: LinearProgressIndicator(
                        value: progressPct,
                        minHeight: 12,
                        backgroundColor: dengeColors.trackBackground,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(scheme.primary),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _GoalStat(
                          label: 'Başlangıç',
                          value: '${_formatKg(startWeight)} kg',
                          alignment: CrossAxisAlignment.start,
                        ),
                        _GoalStat(
                          label: 'Kalan',
                          value: '${_formatKg(remainingKg.toDouble())} kg',
                          alignment: CrossAxisAlignment.center,
                        ),
                        _GoalStat(
                          label: 'Hedef',
                          value: '${_formatKg(goalWeight)} kg',
                          alignment: CrossAxisAlignment.end,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      icon: Icons.local_fire_department_rounded,
                      iconColor: dengeColors.streak,
                      iconBg: dengeColors.streakContainer,
                      value: '${user.streakDays}',
                      label: 'gün seri',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _StatTile(
                      icon: Icons.water_drop_rounded,
                      iconColor: dengeColors.water,
                      iconBg: dengeColors.waterContainer,
                      value: '%$waterPct',
                      label: 'su hedefi',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A [SectionCard]-alike, but declared locally so we don't need to modify
/// the shared widget; kept in sync with its padding/shadow for cohesion.
class SectionCardLike extends StatelessWidget {
  const SectionCardLike({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.07),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
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
          child: Icon(icon, size: 20, color: scheme.onSurface),
        ),
      ),
    );
  }
}

class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs({required this.weekly, required this.onChanged});

  final bool weekly;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.dengeColors.trackBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
              child: _SegmentButton(
                  label: 'Haftalık',
                  selected: weekly,
                  onTap: () => onChanged(true))),
          Expanded(
              child: _SegmentButton(
                  label: 'Aylık',
                  selected: !weekly,
                  onTap: () => onChanged(false))),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton(
      {required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: selected ? scheme.surface : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: selected
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withValues(alpha: theme.brightness == Brightness.dark ? 0.2 : 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                )
              : null,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: selected ? scheme.onSurface : theme.textTheme.bodyMedium?.color,
            ),
          ),
        ),
      ),
    );
  }
}

class _GoalStat extends StatelessWidget {
  const _GoalStat(
      {required this.label, required this.value, required this.alignment});

  final String label;
  final String value;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(label, style: theme.textTheme.bodySmall),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(fontSize: 16),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectionCardLike(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(value,
                style:
                    theme.textTheme.titleLarge?.copyWith(fontSize: 20)),
            const SizedBox(height: 2),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _WeightChart extends StatelessWidget {
  const _WeightChart({
    required this.history,
    required this.color,
    required this.gridColor,
    required this.labelColor,
    required this.labelFor,
  });

  final List<WeightEntry> history;
  final Color color;
  final Color gridColor;
  final Color labelColor;
  final String Function(DateTime) labelFor;

  @override
  Widget build(BuildContext context) {
    final spots = [
      for (var i = 0; i < history.length; i++)
        FlSpot(i.toDouble(), history[i].kg),
    ];
    final minKg = history.map((e) => e.kg).reduce((a, b) => a < b ? a : b);
    final maxKg = history.map((e) => e.kg).reduce((a, b) => a > b ? a : b);
    final pad = ((maxKg - minKg).abs() < 1 ? 1.0 : (maxKg - minKg) * 0.3);

    final labelStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: labelColor,
    );

    return LineChart(
      LineChartData(
        minY: minKg - pad,
        maxY: maxKg + pad,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: ((maxKg + pad) - (minKg - pad)) / 3,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: gridColor, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 34,
              interval: ((maxKg + pad) - (minKg - pad)) / 3,
              getTitlesWidget: (value, meta) =>
                  Text(value.toStringAsFixed(0), style: labelStyle),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (value, meta) {
                final i = value.round();
                if (i != 0 && i != history.length - 1) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(labelFor(history[i].date), style: labelStyle),
                );
              },
            ),
          ),
        ),
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.25,
            color: color,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) {
                final isLast = index == spots.length - 1;
                return FlDotCirclePainter(
                  radius: isLast ? 5.5 : 3,
                  color: isLast ? color : Colors.white,
                  strokeColor: color,
                  strokeWidth: 2,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: color.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}
