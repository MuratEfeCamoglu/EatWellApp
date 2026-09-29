import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/app_state.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';
import '../../router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

/// Tarifler (Recipes) tab: a filterable list of recipe cards built from
/// [MockData.recipes]. Tapping a card opens [RecipeDetailScreen].
class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  static const _all = 'Tümü';
  String _selected = _all;

  static const _tagIcons = <String, IconData>{
    'Yüksek protein': Icons.bolt_rounded,
    'Vegan': Icons.eco_rounded,
    'Kahvaltı': Icons.free_breakfast_rounded,
    'Öğle yemeği': Icons.wb_sunny_rounded,
    'Akşam yemeği': Icons.nightlight_rounded,
    'Ara öğün': Icons.cookie_rounded,
  };

  static const _tagColors = <String, Color>{
    'Yüksek protein': Color(0xFF6A5FE0),
    'Vegan': Color(0xFF1D7445),
    'Kahvaltı': Color(0xFFE39A17),
    'Öğle yemeği': Color(0xFFEF9446),
    'Akşam yemeği': Color(0xFF2B6CB0),
    'Ara öğün': Color(0xFFB5651D),
  };

  IconData _iconFor(Recipe r) => _tagIcons[r.tag] ?? Icons.restaurant_rounded;
  Color _colorFor(Recipe r) => _tagColors[r.tag] ?? const Color(0xFF1D7445);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final tags = <String>[
      _all,
      ...{for (final r in MockData.recipes) r.tag},
    ];
    final filtered = _selected == _all
        ? MockData.recipes
        : MockData.recipes.where((r) => r.tag == _selected).toList();

    final state = context.watch<AppState>();
    final remainingKcal =
        (state.user.calorieGoal - state.caloriesConsumedToday).clamp(0, 99999);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tarifler', style: theme.textTheme.headlineLarge),
                    _RoundIconButton(
                      icon: Icons.search_rounded,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  itemCount: tags.length,
                  separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (context, i) {
                    final tag = tags[i];
                    final selected = tag == _selected;
                    return _FilterChip(
                      label: tag,
                      icon: tag == _all ? null : _tagIcons[tag],
                      selected: selected,
                      onTap: () => setState(() => _selected = tag),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Sana özel',
                                  style: theme.textTheme.titleLarge
                                      ?.copyWith(fontSize: 20)),
                              Text(
                                'Tümünü gör',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primaryText(theme.brightness),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Kalan $remainingKcal kcal\'ine ve protein hedefine göre seçildi',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (filtered.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl, vertical: AppSpacing.xl),
                  child: Text('Bu kategoride tarif yok.',
                      style: theme.textTheme.bodyMedium),
                )
              else
                SizedBox(
                  height: 260,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: AppSpacing.lg),
                    itemBuilder: (context, i) {
                      final recipe = filtered[i];
                      return _LargeRecipeCard(
                        recipe: recipe,
                        icon: _iconFor(recipe),
                        tint: _colorFor(recipe),
                        onTap: () => Navigator.of(context)
                            .push(AppRoutes.pushRecipeDetail(recipe)),
                      );
                    },
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Text('Tüm tarifler',
                    style:
                        theme.textTheme.titleLarge?.copyWith(fontSize: 20)),
              ),
              const SizedBox(height: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppSpacing.lg,
                    crossAxisSpacing: AppSpacing.lg,
                    childAspectRatio: 0.78,
                  ),
                  itemBuilder: (context, i) {
                    final recipe = filtered[i];
                    return _SmallRecipeCard(
                      recipe: recipe,
                      icon: _iconFor(recipe),
                      tint: _colorFor(recipe),
                      onTap: () => Navigator.of(context)
                          .push(AppRoutes.pushRecipeDetail(recipe)),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final divider = context.dengeColors.divider;
    return Material(
      color: selected ? scheme.primary : scheme.surface,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: selected ? scheme.primary : divider, width: 1.5),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon,
                    size: 16,
                    color: selected ? scheme.onPrimary : scheme.onSurface),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: selected ? scheme.onPrimary : scheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecipeImage extends StatelessWidget {
  const _RecipeImage(
      {required this.icon, required this.tint, required this.height});

  final IconData icon;
  final Color tint;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.14),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: height * 0.42, color: tint),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w800,
        );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.local_fire_department_rounded,
            size: 14, color: style?.color),
        const SizedBox(width: 4),
        Text('${recipe.calories} kcal', style: style),
        const SizedBox(width: AppSpacing.md),
        Icon(Icons.schedule_rounded, size: 14, color: style?.color),
        const SizedBox(width: 4),
        Text('${recipe.minutes} dk', style: style),
      ],
    );
  }
}

class _LargeRecipeCard extends StatelessWidget {
  const _LargeRecipeCard({
    required this.recipe,
    required this.icon,
    required this.tint,
    required this.onTap,
  });

  final Recipe recipe;
  final IconData icon;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return SizedBox(
      width: 220,
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    _RecipeImage(icon: icon, tint: tint, height: 140),
                    Positioned(
                      left: 12,
                      top: 12,
                      child: Container(
                        height: 28,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          recipe.tag,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: tint,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(Icons.favorite_border_rounded,
                            size: 16, color: context.dengeColors.streak),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.title,
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _MetaRow(recipe: recipe),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SmallRecipeCard extends StatelessWidget {
  const _SmallRecipeCard({
    required this.recipe,
    required this.icon,
    required this.tint,
    required this.onTap,
  });

  final Recipe recipe;
  final IconData icon;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RecipeImage(icon: icon, tint: tint, height: 100),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        recipe.title,
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      _MetaRow(recipe: recipe),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
