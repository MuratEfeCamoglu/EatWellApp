import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/app_state.dart';
import '../../data/models.dart';
import '../../router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/section_card.dart';

/// Ports project/Diary.dc.html (light), project/Diary-dark.dc.html (dark,
/// via the shared theme) and project/DiaryEmpty.dc.html.
///
/// Local state holds the selected day (a Monday-start week strip, plus a
/// native date picker behind the calendar button) and the list of today's
/// logged meals, seeded from [MockData.todaysMeals]. The mock data set only
/// models "today" — so selecting any other day naturally reaches the empty
/// state from DiaryEmpty.dc.html, which doubles as a way to demo it without
/// a forced "clear" debug action.
///
/// Per-meal calorie goals (breakfast/lunch/dinner/snack) aren't part of the
/// shared mock-data model, so a small local split of the overall
/// [UserProfile.calorieGoal] is used here purely for display, matching the
/// exact numbers shown in Diary.dc.html (460/650/550/190, summing to 1850).
/// The design's per-meal food-item breakdown (with individual icons/kcal
/// per ingredient) isn't in the shared [MealEntry] model either, so each
/// meal card instead shows its aggregate description text — the same
/// simplification Home.dc.html's summary already uses.
class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  late DateTime _selectedDate = _dateOnly(DateTime.now());

  static const _weekdayShort = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
  static const _monthNames = [
    'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
  ];
  static const _mealIcons = {
    MealType.breakfast: Icons.free_breakfast_rounded,
    MealType.lunch: Icons.wb_sunny_rounded,
    MealType.dinner: Icons.nightlight_rounded,
    MealType.snack: Icons.cookie_rounded,
  };
  static const _mealGoals = {
    MealType.breakfast: 460,
    MealType.lunch: 650,
    MealType.dinner: 550,
    MealType.snack: 190,
  };

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<DateTime> get _weekDays {
    final monday = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  void _shiftWeek(int deltaDays) {
    setState(() => _selectedDate = _selectedDate.add(Duration(days: deltaDays)));
  }

  Future<void> _openCalendar() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      setState(() => _selectedDate = _dateOnly(picked));
    }
  }

  static String _thousands(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.dengeColors;
    final state = context.watch<AppState>();
    final isToday = _isSameDay(_selectedDate, DateTime.now());
    final showEmpty = !isToday || state.todaysMeals.isEmpty;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 140),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              _buildWeekNav(context),
              const SizedBox(height: 8),
              _buildDayStrip(context),
              const SizedBox(height: 16),
              if (showEmpty)
                _buildEmpty(context)
              else
                _buildFilled(context, theme, colors, state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.dengeColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Row(
        children: [
          Expanded(child: Text('Günlük', style: theme.textTheme.headlineLarge)),
          Material(
            color: theme.colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: colors.divider),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _openCalendar,
              child: SizedBox(
                width: 48,
                height: 48,
                child: Icon(Icons.calendar_today_rounded,
                    size: 20, color: theme.textTheme.bodyLarge?.color),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekNav(BuildContext context) {
    final theme = Theme.of(context);
    final label = '${_monthNames[_selectedDate.month - 1]} ${_selectedDate.year}';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => _shiftWeek(-7),
            icon: const Icon(Icons.chevron_left_rounded),
            tooltip: 'Önceki hafta',
          ),
          Text(label, style: theme.textTheme.titleMedium),
          IconButton(
            onPressed: () => _shiftWeek(7),
            icon: const Icon(Icons.chevron_right_rounded),
            tooltip: 'Sonraki hafta',
          ),
        ],
      ),
    );
  }

  Widget _buildDayStrip(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final colors = context.dengeColors;
    final today = _dateOnly(DateTime.now());
    return SizedBox(
      height: 80,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final day = _weekDays[i];
          final selected = _isSameDay(day, _selectedDate);
          final isToday = _isSameDay(day, today);
          return Material(
            color: selected ? scheme.primary : scheme.surface,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => setState(() => _selectedDate = day),
              child: Container(
                width: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: selected ? null : Border.all(color: colors.divider),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _weekdayShort[i],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: selected ? Colors.white : theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${day.day}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: selected ? Colors.white : theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected
                            ? Colors.white
                            : (isToday ? scheme.primary : Colors.transparent),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilled(
      BuildContext context, ThemeData theme, DengeColors colors, AppState state) {
    final goal = state.user.calorieGoal;
    final consumed = state.caloriesConsumedToday;
    final remaining = (goal - consumed).clamp(0, goal == 0 ? 0 : goal);
    final progress = goal == 0 ? 0.0 : (consumed / goal).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: Column(
        children: [
          SectionCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Bugün',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(fontWeight: FontWeight.w800)),
                    RichText(
                      text: TextSpan(
                        style: theme.textTheme.bodyMedium,
                        children: [
                          TextSpan(
                            text: '${_thousands(consumed)} ',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          TextSpan(text: '/ ${_thousands(goal)} kcal'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: colors.trackBackground,
                    valueColor: AlwaysStoppedAnimation(AppTheme.ring(theme.brightness)),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _macroDot(colors.protein, 'P ${state.proteinConsumedG.round()} g', theme),
                    _macroDot(colors.carbs, 'K ${state.carbsConsumedG.round()} g', theme),
                    _macroDot(colors.fat, 'Y ${state.fatConsumedG.round()} g', theme),
                    Text('$remaining kcal kaldı',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryText(theme.brightness),
                        )),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (final type in MealType.values) ...[
            _buildMealCard(context, theme, colors, state, type),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _macroDot(Color color, String label, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: theme.textTheme.bodyMedium?.color,
            )),
      ],
    );
  }

  Widget _buildMealCard(BuildContext context, ThemeData theme, DengeColors colors,
      AppState state, MealType type) {
    final meal = state.todaysMeals.firstWhere((m) => m.type == type);
    final goal = _mealGoals[type]!;
    final scheme = theme.colorScheme;

    return SectionCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.trackBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(_mealIcons[type], color: theme.textTheme.bodyLarge?.color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(meal.title, style: theme.textTheme.titleMedium),
                    RichText(
                      text: TextSpan(
                        style: theme.textTheme.bodyMedium,
                        children: [
                          TextSpan(
                            text: '${meal.calories}',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          TextSpan(text: ' / $goal kcal'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Material(
                color: scheme.primaryContainer,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.of(context)
                      .push(AppRoutes.pushSearch(initialMeal: type)),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(Icons.add_rounded,
                        color: scheme.onPrimaryContainer, size: 22),
                  ),
                ),
              ),
            ],
          ),
          if (meal.logged) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: colors.divider)),
              ),
              child: Text(meal.description, style: theme.textTheme.bodyMedium),
            ),
          ] else ...[
            const SizedBox(height: 16),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => Navigator.of(context)
                    .push(AppRoutes.pushSearch(initialMeal: type)),
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: colors.divider,
                      width: 1.5,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_rounded,
                          size: 18, color: AppTheme.primaryText(theme.brightness)),
                      const SizedBox(width: 8),
                      Text(
                        '${meal.title} ekle',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryText(theme.brightness),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 0),
      child: Column(
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.restaurant_rounded,
                size: 56, color: scheme.onPrimaryContainer),
          ),
          const SizedBox(height: 16),
          Text('Tabağın henüz boş',
              textAlign: TextAlign.center, style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Bugün ne yediğini ekleyerek güne başla. İlk öğününü eklemek sadece birkaç saniye sürer.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.search),
              icon: const Icon(Icons.add_rounded),
              label: const Text('İlk öğününü ekle'),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _quickAddChip(context, Icons.free_breakfast_rounded, 'Kahvaltı', MealType.breakfast),
              _quickAddChip(context, Icons.wb_sunny_rounded, 'Öğle', MealType.lunch),
              _quickAddChip(context, Icons.nightlight_rounded, 'Akşam', MealType.dinner),
              _quickAddChip(context, Icons.cookie_rounded, 'Ara öğün', MealType.snack),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickAddChip(
      BuildContext context, IconData icon, String label, MealType type) {
    final theme = Theme.of(context);
    final colors = context.dengeColors;
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () =>
            Navigator.of(context).push(AppRoutes.pushSearch(initialMeal: type)),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.divider),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: AppTheme.primaryText(theme.brightness)),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: theme.textTheme.bodyLarge?.color,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
