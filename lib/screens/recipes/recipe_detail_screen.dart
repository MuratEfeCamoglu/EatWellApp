import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/app_state.dart';
import '../../data/models.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/section_card.dart';
import '../search/search_screen.dart' show defaultMealForNow;
import 'recipes_screen.dart';

const _mealLabels = {
  MealType.breakfast: 'Kahvaltı',
  MealType.lunch: 'Öğle yemeği',
  MealType.dinner: 'Akşam yemeği',
  MealType.snack: 'Ara öğün',
};

/// Recipe detail: collapsing photo header, time/serving/difficulty stats,
/// per-serving macros, tick-off ingredients and steps, and an "add to
/// diary" action — content comes entirely from the [recipe] passed in.
class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({super.key, required this.recipe, this.heroTag});

  final Recipe recipe;

  /// Matches the tapped card's photo so it flies into the header.
  final String? heroTag;

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final _checkedIngredients = <int>{};
  final _doneSteps = <int>{};

  Recipe get recipe => widget.recipe;

  Future<void> _addToDiary() async {
    final meal = await showModalBottomSheet<MealType>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text('Hangi öğüne eklensin?',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            for (final type in MealType.values)
              ListTile(
                leading: Icon(type == defaultMealForNow()
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded),
                title: Text(_mealLabels[type]!),
                onTap: () => Navigator.of(context).pop(type),
              ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
    if (meal == null || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await context
          .read<AppState>()
          .addFoodToMeal(meal, recipe.asServing, 1, source: FoodLogSource.recipe);
    } catch (_) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
            content: Text('Tarif kaydedilemedi, lütfen tekrar dene.')));
      return;
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
          content: Text('1 porsiyon ${recipe.title} ${_mealLabels[meal]} listesine eklendi')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final colors = context.dengeColors;
    final favorite = context.watch<AppState>().isFavoriteRecipe(recipe);
    final photo = RecipePhoto(recipe: recipe);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            stretch: true,
            automaticallyImplyLeading: false,
            backgroundColor: scheme.surface,
            surfaceTintColor: Colors.transparent,
            titleSpacing: AppSpacing.lg,
            title: Row(
              children: [
                const AppBackButton(),
                const Spacer(),
                _CircleIconButton(
                  icon: favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: colors.streak,
                  tooltip: favorite ? 'Favorilerden çıkar' : 'Favorilere ekle',
                  onTap: () => context.read<AppState>().toggleFavoriteRecipe(recipe),
                ),
              ],
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: widget.heroTag == null
                  ? photo
                  : Hero(tag: widget.heroTag!, child: photo),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(recipeTagIcon(recipe), size: 16, color: recipeTagColor(recipe)),
                      const SizedBox(width: 6),
                      Text(
                        recipe.tag.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w900,
                          color: recipeTagColor(recipe),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(recipe.title, style: theme.textTheme.headlineLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    recipe.description,
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 15, height: 1.4),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      _StatTile(
                          icon: Icons.schedule_rounded, value: '${recipe.minutes}', unit: 'dk'),
                      const SizedBox(width: AppSpacing.sm),
                      _StatTile(
                          icon: Icons.people_alt_rounded,
                          value: '${recipe.servings}',
                          unit: 'porsiyon'),
                      const SizedBox(width: AppSpacing.sm),
                      _StatTile(
                          icon: Icons.signal_cellular_alt_rounded,
                          value: recipe.difficulty.label,
                          unit: 'zorluk'),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Besin değerleri', style: theme.textTheme.titleMedium),
                            const Spacer(),
                            Text('1 porsiyon', style: theme.textTheme.bodySmall),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${recipe.calories}',
                                style: theme.textTheme.headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.w900)),
                            const SizedBox(width: 4),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text('kcal', style: theme.textTheme.bodyMedium),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _MacroBar(recipe: recipe),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            _MacroLegend(label: 'Protein', grams: recipe.proteinG, color: colors.protein),
                            _MacroLegend(label: 'Karb.', grams: recipe.carbsG, color: colors.carbs),
                            _MacroLegend(label: 'Yağ', grams: recipe.fatG, color: colors.fat),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Row(
                    children: [
                      Text('Malzemeler',
                          style: theme.textTheme.titleLarge?.copyWith(fontSize: 20)),
                      const Spacer(),
                      Text('${_checkedIngredients.length}/${recipe.ingredients.length}',
                          style: theme.textTheme.bodySmall),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SectionCard(
                    child: Column(
                      children: [
                        for (var i = 0; i < recipe.ingredients.length; i++)
                          _CheckRow(
                            text: recipe.ingredients[i],
                            checked: _checkedIngredients.contains(i),
                            onTap: () => setState(() {
                              if (!_checkedIngredients.remove(i)) _checkedIngredients.add(i);
                            }),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Text('Hazırlanışı', style: theme.textTheme.titleLarge?.copyWith(fontSize: 20)),
                  const SizedBox(height: AppSpacing.xs),
                  Text('Tamamladığın adıma dokun', style: theme.textTheme.bodySmall),
                  const SizedBox(height: AppSpacing.lg),
                  for (var i = 0; i < recipe.steps.length; i++)
                    _StepRow(
                      index: i,
                      text: recipe.steps[i],
                      done: _doneSteps.contains(i),
                      last: i == recipe.steps.length - 1,
                      onTap: () => setState(() {
                        if (!_doneSteps.remove(i)) _doneSteps.add(i);
                      }),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _addToDiary,
            icon: const Icon(Icons.add_rounded),
            label: Text('Günlüğe ekle · ${recipe.calories} kcal'),
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.icon, required this.value, required this.unit});

  final IconData icon;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: context.dengeColors.trackBackground,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(height: 4),
            Text(value,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
            Text(unit, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

/// Stacked bar showing each macro's share of the serving's calories.
class _MacroBar extends StatelessWidget {
  const _MacroBar({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final colors = context.dengeColors;
    final p = recipe.proteinG * 4, c = recipe.carbsG * 4, f = recipe.fatG * 9;
    final total = p + c + f;
    if (total == 0) return const SizedBox.shrink();
    Widget part(double kcal, Color color) =>
        Expanded(flex: (kcal / total * 1000).round(), child: Container(color: color));
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 10,
        child: Row(children: [
          part(p, colors.protein),
          part(c, colors.carbs),
          part(f, colors.fat),
        ]),
      ),
    );
  }
}

class _MacroLegend extends StatelessWidget {
  const _MacroLegend({required this.label, required this.grams, required this.color});

  final String label;
  final double grams;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text.rich(
              TextSpan(children: [
                TextSpan(text: '$label '),
                TextSpan(
                  text: '${grams.round()} g',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ]),
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({required this.text, required this.checked, required this.onTap});

  final String text;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: checked ? scheme.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    color: checked ? scheme.primary : context.dengeColors.divider, width: 2),
              ),
              child: checked
                  ? Icon(Icons.check_rounded, size: 16, color: scheme.onPrimary)
                  : null,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                style: (theme.textTheme.bodyLarge ?? const TextStyle()).copyWith(
                  fontSize: 16,
                  decoration: checked ? TextDecoration.lineThrough : null,
                  color: checked ? theme.textTheme.bodySmall?.color : null,
                ),
                child: Text(text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.index,
    required this.text,
    required this.done,
    required this.last,
    required this.onTap,
  });

  final int index;
  final String text;
  final bool done;
  final bool last;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(bottom: last ? 0 : AppSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: done ? scheme.primary : scheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: done
                  ? Icon(Icons.check_rounded, size: 18, color: scheme.onPrimary)
                  : Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryText(theme.brightness),
                      ),
                    ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: done ? 0.5 : 1,
                  child: Text(
                    text,
                    style: theme.textTheme.bodyLarge?.copyWith(fontSize: 16, height: 1.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: scheme.surface,
        shape: const CircleBorder(),
        elevation: 2,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(icon, size: 22, color: color),
          ),
        ),
      ),
    );
  }
}
