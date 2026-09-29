import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:provider/provider.dart';

import '../../data/app_state.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';
import '../../router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/section_card.dart';

/// Ports project/Home.dc.html (light) and project/Home-dark.dc.html (dark)
/// from the design canvas: greeting header with streak pill + avatar,
/// calorie ring card, macro bars, water tracker, weekly streak strip and
/// today's meals summary.
///
/// This screen is one of [MainShell]'s tabs, so it intentionally has no
/// bottom nav / floating action button of its own — those are provided by
/// the shell. The streak pill and avatar are static (non-navigating): in
/// the design they link to sibling tabs (Progress / Profile), but this
/// screen has no way to switch MainShell's tab index without shared state,
/// so per the porting brief they're left as visually-correct, non-tappable
/// elements. Likewise the meal rows / "Günlüğe git" link are static except
/// the unlogged dinner row's "+" button, which opens food search.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _weekdayNames = [
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar',
  ];
  static const _monthNames = [
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];

  static const _mealIcons = {
    MealType.breakfast: Icons.free_breakfast_rounded,
    MealType.lunch: Icons.wb_sunny_rounded,
    MealType.dinner: Icons.nightlight_rounded,
    MealType.snack: Icons.cookie_rounded,
  };

  /// Recreates the design's `pick` logic: tapping glass [index] (0-based)
  /// fills up to and including it if it wasn't full yet, or empties back to
  /// it if it (and everything after it) was already full.
  void _pickGlass(int index, int current) {
    final state = context.read<AppState>();
    state.setWaterGlasses(index < current ? index : index + 1);
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

  static String _litresLabel(int glasses) {
    final value = glasses * 0.25;
    var s = value.toStringAsFixed(2);
    if (s.endsWith('0')) s = s.substring(0, s.length - 1);
    return s.replaceAll('.', ',');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final colors = context.dengeColors;
    final state = context.watch<AppState>();
    final now = DateTime.now();
    final dateLabel =
        '${_weekdayNames[now.weekday - 1]}, ${now.day} ${_monthNames[now.month - 1]}';
    final firstName =
        state.user.name.isEmpty ? '' : state.user.name.split(' ').first;
    final greeting = firstName.isEmpty ? 'Günaydın' : 'Günaydın, $firstName';

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 140),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(dateLabel, style: theme.textTheme.bodySmall),
                          const SizedBox(height: 2),
                          Text(greeting, style: theme.textTheme.headlineLarge),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: colors.streakContainer,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.local_fire_department_rounded,
                              size: 20, color: colors.streak),
                          const SizedBox(width: 6),
                          Text(
                            '${state.user.streakDays}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: colors.streakOnContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: scheme.primaryContainer,
                      child: Text(
                        state.user.initials,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  children: [
                    SectionCard(child: _buildCalorieCard(context, state)),
                    const SizedBox(height: 16),
                    SectionCard(child: _buildWaterCard(context, state)),
                    const SizedBox(height: 16),
                    SectionCard(child: _buildStreakCard(context, state)),
                    const SizedBox(height: 16),
                    SectionCard(child: _buildMealsCard(context, state)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalorieCard(BuildContext context, AppState state) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final colors = context.dengeColors;
    final goal = state.user.calorieGoal;
    final consumed = state.caloriesConsumedToday;
    final remaining = goal == 0 ? 0 : (goal - consumed).clamp(0, goal);
    final progress = goal == 0 ? 0.0 : (consumed / goal).clamp(0.0, 1.0);
    final ringColor = AppTheme.ring(theme.brightness);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Bugünkü kaloriler',
                  style: theme.textTheme.titleMedium),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Hedef ${_thousands(goal)} kcal',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: scheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Center(
          child: SizedBox(
            width: 208,
            height: 208,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 208,
                  height: 208,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 20,
                    strokeCap: StrokeCap.round,
                    backgroundColor: colors.trackBackground,
                    valueColor: AlwaysStoppedAnimation(ringColor),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _thousands(consumed),
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    Text('/ ${_thousands(goal)} kcal',
                        style: theme.textTheme.bodyMedium),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legendDot(context, ringColor, 'Alınan', consumed),
            const SizedBox(width: 24),
            _legendDot(context, colors.trackBackground, 'Kalan', remaining),
          ],
        ),
        const SizedBox(height: 20),
        Divider(height: 1, color: colors.divider),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _MacroBar(
                label: 'Protein',
                color: colors.protein,
                consumed: state.proteinConsumedG.round(),
                goal: state.user.proteinGoalG,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _MacroBar(
                label: 'Karb.',
                color: colors.carbs,
                consumed: state.carbsConsumedG.round(),
                goal: state.user.carbsGoalG,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _MacroBar(
                label: 'Yağ',
                color: colors.fat,
                consumed: state.fatConsumedG.round(),
                goal: state.user.fatGoalG,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _legendDot(BuildContext context, Color dotColor, String label, int value) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text('$label ', style: theme.textTheme.bodyMedium),
        Text(
          _thousands(value),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildWaterCard(BuildContext context, AppState state) {
    final theme = Theme.of(context);
    final colors = context.dengeColors;
    final waterGlasses = state.waterGlasses;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.waterContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.water_drop_rounded, color: colors.water, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Su', style: theme.textTheme.titleMedium),
                  Text('Bardağa dokunarak ekle · 250 ml',
                      style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween(begin: const Offset(0, 0.3), end: Offset.zero)
                      .animate(animation),
                  child: child,
                ),
              ),
              child: RichText(
                key: ValueKey(waterGlasses),
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                  children: [
                    TextSpan(text: _litresLabel(waterGlasses)),
                    TextSpan(
                      text: ' / ${_litresLabel(MockData.waterGlassesGoal)} L',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: MockData.waterGlassesGoal,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, i) {
            final full = i < waterGlasses;
            final next = i == waterGlasses;
            return _WaterGlassButton(
              full: full,
              next: next,
              onTap: () => _pickGlass(i, waterGlasses),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStreakCard(BuildContext context, AppState state) {
    final theme = Theme.of(context);
    final colors = context.dengeColors;
    const dayInitials = ['P', 'S', 'Ç', 'P', 'C', 'C', 'P'];
    // 0 = completed, 1 = today (in progress), 2 = upcoming/empty.
    const dayStates = [0, 0, 1, 2, 2, 2, 2];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colors.streakContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.local_fire_department_rounded,
                  color: colors.streak, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${state.user.streakDays} günlük seri!',
                      style: theme.textTheme.titleMedium),
                  Text('Bugünü de kaydet, seriyi koru.',
                      style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (i) {
            final state = dayStates[i];
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(dayInitials[i],
                    style: theme.textTheme.bodySmall
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                if (state == 0)
                  Container(
                    width: 28,
                    height: 28,
                    decoration:
                        BoxDecoration(color: colors.streak, shape: BoxShape.circle),
                    child: const Icon(Icons.check_rounded,
                        color: Colors.white, size: 14),
                  )
                else if (state == 1)
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.streak, width: 2),
                    ),
                    child: Icon(Icons.local_fire_department_rounded,
                        color: colors.streak, size: 14),
                  )
                else
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: colors.trackBackground,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _buildMealsCard(BuildContext context, AppState state) {
    final theme = Theme.of(context);
    final colors = context.dengeColors;
    final scheme = theme.colorScheme;
    final meals = state.todaysMeals;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Bugünkü öğünler', style: theme.textTheme.titleMedium),
            ),
            Text('Günlüğe git',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryText(theme.brightness),
                )),
          ],
        ),
        for (var i = 0; i < meals.length; i++)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: i == 0
                  ? null
                  : Border(top: BorderSide(color: colors.divider)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: meals[i].logged
                        ? scheme.primaryContainer
                        : colors.trackBackground,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _mealIcons[meals[i].type],
                    color: meals[i].logged
                        ? scheme.onPrimaryContainer
                        : theme.textTheme.bodyMedium?.color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(meals[i].title, style: theme.textTheme.titleSmall),
                      Text(
                        meals[i].description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                if (meals[i].logged)
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                      children: [
                        TextSpan(text: '${meals[i].calories}'),
                        TextSpan(
                          text: ' kcal',
                          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  )
                else
                  Material(
                    color: scheme.primary,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.of(context)
                          .push(AppRoutes.pushSearch(initialMeal: meals[i].type)),
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: Icon(Icons.add_rounded,
                            color: scheme.onPrimary, size: 22),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _MacroBar extends StatelessWidget {
  const _MacroBar({
    required this.label,
    required this.color,
    required this.consumed,
    required this.goal,
  });

  final String label;
  final Color color;
  final int consumed;
  final int goal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.dengeColors;
    final progress = goal == 0 ? 0.0 : (consumed / goal).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(label,
                style: theme.textTheme.bodySmall
                    ?.copyWith(fontSize: 12, fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: theme.textTheme.bodyLarge?.color,
            ),
            children: [
              TextSpan(text: '$consumed'),
              TextSpan(
                text: ' / $goal g',
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: colors.trackBackground,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

/// One glass in the 10-glass water grid, in one of three visual states:
/// full (filled droplet), next (dashed outline — the next tap target), or
/// empty (faint outline).
class _WaterGlassButton extends StatefulWidget {
  const _WaterGlassButton({
    required this.full,
    required this.next,
    required this.onTap,
  });

  final bool full;
  final bool next;
  final VoidCallback onTap;

  @override
  State<_WaterGlassButton> createState() => _WaterGlassButtonState();
}

class _WaterGlassButtonState extends State<_WaterGlassButton> {
  void _handleTap() {
    HapticFeedback.lightImpact();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.dengeColors;
    final color = widget.full || widget.next ? colors.water : colors.divider;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _handleTap,
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.7, end: widget.full ? 1.0 : 0.85),
            duration: const Duration(milliseconds: 260),
            curve: Curves.elasticOut,
            builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: Icon(
                widget.full
                    ? Icons.local_drink_rounded
                    : (widget.next
                        ? Icons.add_circle_outline_rounded
                        : Icons.local_drink_outlined),
                key: ValueKey('${widget.full}-${widget.next}'),
                color: color,
                size: 26,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
