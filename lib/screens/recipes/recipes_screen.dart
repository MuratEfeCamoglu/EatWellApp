import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/app_state.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';
import '../../router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

/// Tag → icon/accent color, shared by the list and detail screens.
const recipeTagIcons = <String, IconData>{
  'Yüksek protein': Icons.bolt_rounded,
  'Vegan': Icons.eco_rounded,
  'Kahvaltı': Icons.free_breakfast_rounded,
  'Öğle yemeği': Icons.wb_sunny_rounded,
  'Akşam yemeği': Icons.nightlight_rounded,
  'Çorba': Icons.soup_kitchen_rounded,
  'Ara öğün': Icons.cookie_rounded,
  'Tatlı': Icons.cake_rounded,
};

const recipeTagColors = <String, Color>{
  'Yüksek protein': Color(0xFF6A5FE0),
  'Vegan': Color(0xFF1D7445),
  'Kahvaltı': Color(0xFFE39A17),
  'Öğle yemeği': Color(0xFFEF9446),
  'Akşam yemeği': Color(0xFF2B6CB0),
  'Çorba': Color(0xFFC0512F),
  'Ara öğün': Color(0xFFB5651D),
  'Tatlı': Color(0xFFD1467A),
};

Color recipeTagColor(Recipe r) => recipeTagColors[r.tag] ?? const Color(0xFF1D7445);
IconData recipeTagIcon(Recipe r) => recipeTagIcons[r.tag] ?? Icons.restaurant_rounded;

/// Tarifler (Recipes) tab: searchable, filterable recipe cards built from
/// [MockData.recipes], a "Sana özel" row picked against today's remaining
/// calories, and the user's favorites. Tapping a card opens the detail.
class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  static const _all = 'Tümü';
  static const _favorites = 'Favoriler';

  String _selected = _all;
  bool _searching = false;
  String _query = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _searching = !_searching;
      if (!_searching) {
        _query = '';
        _searchController.clear();
      }
    });
  }

  bool _matchesQuery(Recipe r) {
    if (_query.isEmpty) return true;
    final q = _query.toLowerCase();
    return r.title.toLowerCase().contains(q) ||
        r.ingredients.any((i) => i.toLowerCase().contains(q));
  }

  /// Recipes that fit in [remainingKcal], most protein per calorie first —
  /// falls back to the whole catalog when the day's budget is used up.
  List<Recipe> _forYou(int remainingKcal) {
    final fitting = MockData.recipes.where((r) => r.calories <= remainingKcal).toList();
    final pool = fitting.isEmpty ? [...MockData.recipes] : fitting;
    pool.sort((a, b) => (b.proteinG / b.calories).compareTo(a.proteinG / a.calories));
    return pool.take(6).toList();
  }

  void _open(Recipe recipe, String heroTag) {
    Navigator.of(context).push(AppRoutes.pushRecipeDetail(recipe, heroTag: heroTag));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.watch<AppState>();

    final tags = <String>[
      _all,
      _favorites,
      ...{for (final r in MockData.recipes) r.tag},
    ];
    final filtered = MockData.recipes.where((r) {
      final inTag = switch (_selected) {
        _all => true,
        _favorites => state.isFavoriteRecipe(r),
        _ => r.tag == _selected,
      };
      return inTag && _matchesQuery(r);
    }).toList();

    final remainingKcal =
        (state.user.calorieGoal - state.caloriesConsumedToday).clamp(0, 99999);
    final showForYou = _selected == _all && _query.isEmpty;
    final forYou = showForYou ? _forYou(remainingKcal) : const <Recipe>[];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl, AppSpacing.md, AppSpacing.xl, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('Tarifler', style: theme.textTheme.headlineLarge),
                    ),
                    _RoundIconButton(
                      icon: _searching ? Icons.close_rounded : Icons.search_rounded,
                      tooltip: _searching ? 'Aramayı kapat' : 'Tarif ara',
                      onTap: _toggleSearch,
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                child: _searching
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(
                            AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, 0),
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          onChanged: (v) => setState(() => _query = v.trim()),
                          decoration: const InputDecoration(
                            hintText: 'Tarif veya malzeme ara',
                            prefixIcon: Icon(Icons.search_rounded),
                          ),
                        ),
                      )
                    : const SizedBox(width: double.infinity),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 48 + AppSpacing.lg * 2,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
                  itemCount: tags.length,
                  separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (context, i) {
                    final tag = tags[i];
                    return _FilterChip(
                      label: tag,
                      icon: switch (tag) {
                        _all => null,
                        _favorites => Icons.favorite_rounded,
                        _ => recipeTagIcons[tag],
                      },
                      selected: tag == _selected,
                      onTap: () => setState(() => _selected = tag),
                    );
                  },
                ),
              ),
            ),
            if (showForYou) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sana özel',
                          style: theme.textTheme.titleLarge?.copyWith(fontSize: 20)),
                      const SizedBox(height: 2),
                      Text(
                        'Kalan $remainingKcal kcal\'ine sığan, proteini en yüksek tarifler',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 250,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.sm),
                    itemCount: forYou.length,
                    separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.lg),
                    itemBuilder: (context, i) {
                      final recipe = forYou[i];
                      final heroTag = 'foryou-${recipe.title}';
                      return _FeaturedRecipeCard(
                        recipe: recipe,
                        heroTag: heroTag,
                        onTap: () => _open(recipe, heroTag),
                      );
                    },
                  ),
                ),
              ),
            ],
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _query.isNotEmpty
                            ? 'Sonuçlar'
                            : (_selected == _all ? 'Tüm tarifler' : _selected),
                        style: theme.textTheme.titleLarge?.copyWith(fontSize: 20),
                      ),
                    ),
                    Text('${filtered.length} tarif', style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ),
            if (filtered.isEmpty)
              SliverToBoxAdapter(
                child: _EmptyState(favorites: _selected == _favorites && _query.isEmpty),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, 120),
                sliver: SliverGrid.builder(
                  itemCount: filtered.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppSpacing.lg,
                    crossAxisSpacing: AppSpacing.lg,
                    childAspectRatio: 0.74,
                  ),
                  itemBuilder: (context, i) {
                    final recipe = filtered[i];
                    final heroTag = 'grid-${recipe.title}';
                    return _GridRecipeCard(
                      recipe: recipe,
                      heroTag: heroTag,
                      onTap: () => _open(recipe, heroTag),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap, required this.tooltip});

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: Material(
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
    final scheme = Theme.of(context).colorScheme;
    final divider = context.dengeColors.divider;
    final fg = selected ? scheme.onPrimary : scheme.onSurface;
    return Material(
      color: selected ? scheme.primary : scheme.surface,
      shape: StadiumBorder(
        side: BorderSide(color: selected ? scheme.primary : divider, width: 1.5),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: fg),
                const SizedBox(width: 6),
              ],
              Text(label,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: fg)),
            ],
          ),
        ),
      ),
    );
  }
}

/// The recipe's photo, falling back to a tinted tag icon if missing.
class RecipePhoto extends StatelessWidget {
  const RecipePhoto({super.key, required this.recipe, this.cacheWidth});

  final Recipe recipe;
  final int? cacheWidth;

  @override
  Widget build(BuildContext context) {
    final tint = recipeTagColor(recipe);
    return Image.asset(
      recipe.imageAsset,
      fit: BoxFit.cover,
      cacheWidth: cacheWidth,
      errorBuilder: (context, _, __) => Container(
        color: tint.withValues(alpha: 0.14),
        alignment: Alignment.center,
        child: Icon(recipeTagIcon(recipe), size: 48, color: tint),
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final favorite = state.isFavoriteRecipe(recipe);
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => context.read<AppState>().toggleFavoriteRecipe(recipe),
        child: SizedBox(
          width: 36,
          height: 36,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
            child: Icon(
              favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              key: ValueKey(favorite),
              size: 18,
              color: context.dengeColors.streak,
            ),
          ),
        ),
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final tint = recipeTagColor(recipe);
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(13),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(recipeTagIcon(recipe), size: 13, color: tint),
          const SizedBox(width: 4),
          Text(recipe.tag,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: tint)),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.recipe, this.color});

  final Recipe recipe;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: color,
        );
    Widget item(IconData icon, String text) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: style?.color),
            const SizedBox(width: 3),
            Text(text, style: style),
          ],
        );
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: 2,
      children: [
        item(Icons.local_fire_department_rounded, '${recipe.calories} kcal'),
        item(Icons.schedule_rounded, '${recipe.minutes} dk'),
      ],
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(onTap: onTap, child: child),
      ),
    );
  }
}

/// Wide card with the photo filling the card and the title overlaid on a
/// dark gradient.
class _FeaturedRecipeCard extends StatelessWidget {
  const _FeaturedRecipeCard({
    required this.recipe,
    required this.heroTag,
    required this.onTap,
  });

  final Recipe recipe;
  final String heroTag;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return SizedBox(
      width: 260,
      child: _CardShell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: heroTag,
              child: RecipePhoto(recipe: recipe, cacheWidth: (260 * dpr).round()),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.35, 1],
                  colors: [Colors.transparent, Color(0xD9000000)],
                ),
              ),
            ),
            Positioned(left: 12, top: 12, child: _TagPill(recipe: recipe)),
            Positioned(right: 10, top: 10, child: _FavoriteButton(recipe: recipe)),
            Positioned(
              left: 16,
              right: 16,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _MetaRow(recipe: recipe, color: Colors.white),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        '${recipe.proteinG.round()} g protein',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridRecipeCard extends StatelessWidget {
  const _GridRecipeCard({
    required this.recipe,
    required this.heroTag,
    required this.onTap,
  });

  final Recipe recipe;
  final String heroTag;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return _CardShell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: heroTag,
                  child: RecipePhoto(recipe: recipe, cacheWidth: (200 * dpr).round()),
                ),
                Positioned(right: 6, top: 6, child: _FavoriteButton(recipe: recipe)),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.tag.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 0.6,
                          fontWeight: FontWeight.w900,
                          color: recipeTagColor(recipe),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        recipe.title,
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(fontSize: 15, fontWeight: FontWeight.w800, height: 1.2),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  _MetaRow(recipe: recipe),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.favorites});

  final bool favorites;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, 120),
      child: Column(
        children: [
          Icon(
            favorites ? Icons.favorite_border_rounded : Icons.search_off_rounded,
            size: 48,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            favorites
                ? 'Henüz favori tarifin yok.\nKartlardaki kalbe dokunarak ekleyebilirsin.'
                : 'Aramana uygun tarif bulunamadı.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
