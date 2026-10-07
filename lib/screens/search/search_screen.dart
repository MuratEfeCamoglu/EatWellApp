import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/app_state.dart';
import '../../data/custom_food.dart';
import '../../data/food_recognition.dart';
import '../../data/food_search.dart';
import '../../data/models.dart';
import '../../data/mock_data.dart';
import '../../router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/food_image.dart';

const _mealLabels = {
  MealType.breakfast: 'Kahvaltı',
  MealType.lunch: 'Öğle yemeği',
  MealType.dinner: 'Akşam yemeği',
  MealType.snack: 'Ara öğün',
};

const _mealAddLabels = {
  MealType.breakfast: 'Kahvaltıya ekle',
  MealType.lunch: 'Öğle yemeğine ekle',
  MealType.dinner: 'Akşam yemeğine ekle',
  MealType.snack: 'Ara öğüne ekle',
};

/// Picks a sensible default meal to add to based on the current time of
/// day, so the target isn't always hardcoded to lunch.
MealType defaultMealForNow() {
  final hour = DateTime.now().hour;
  if (hour < 11) return MealType.breakfast;
  if (hour < 16) return MealType.lunch;
  if (hour < 21) return MealType.dinner;
  return MealType.snack;
}

/// Ports project/Search.dc.html (default/browse state) and
/// project/SearchEmpty.dc.html (no-results state). Filters
/// [MockData.searchResults] and the user's own foods locally as the user
/// types (own foods listed first); tapping a result pushes
/// [AppRoutes.pushFoodDetail].
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.initialMeal});

  /// The meal this search should add into; defaults to whichever meal fits
  /// the current time of day when not provided (e.g. entering via the
  /// floating "+" button rather than a specific meal card).
  final MealType? initialMeal;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';
  late final MealType _meal = widget.initialMeal ?? defaultMealForNow();

  /// Selected category filter; null shows every category as sections.
  FoodCategory? _category;

  static const _popularChipsByMeal = {
    MealType.breakfast: ['Simit', 'Menemen', 'Peynir', 'Bal'],
    MealType.lunch: ['Mercimek çorbası', 'Pilav', 'Tavuk sote', 'Mantı'],
    MealType.dinner: ['Karnıyarık', 'Izgara köfte', 'Somon', 'Lahmacun'],
    MealType.snack: ['Yoğurt', 'Kuru kayısı', 'Kaşar peyniri', 'Çoban salata'],
  };

  List<String> get _popularChips => _popularChipsByMeal[_meal]!;

  // Cosmetic per-row background/foreground tint (design uses distinct food
  // illustrations per row; we cycle through theme-aware color pairs while
  // the icon itself now comes from the food, not the cycle).
  List<({Color bg, Color fg})> _rowTints(BuildContext context) {
    final colors = context.dengeColors;
    return [
      (bg: colors.streakContainer, fg: colors.streak),
      (bg: colors.waterContainer, fg: colors.water),
      (bg: colors.trackBackground, fg: colors.protein),
      (bg: colors.streakContainer, fg: colors.carbs),
    ];
  }

  /// Categories that have at least one catalog food for [_meal] (only
  /// foods that make sense for it — searching while adding to "Kahvaltı"
  /// shouldn't surface dinner-only dishes) or one own food, in display
  /// order.
  List<FoodCategory> _availableCategories(List<CustomFood> custom) {
    final present = {
      for (final f in MockData.searchResults)
        if (f.meals.contains(_meal)) f.category,
      for (final c in custom) c.category,
    };
    return FoodCategory.values.where(present.contains).toList();
  }

  /// The user's own foods (under a "Kendi yiyeceklerin" header) followed by
  /// catalog [foods] grouped under their category headers. Each entry is a
  /// section header ([_Section]), a [CustomFood] or a [FoodItem] row.
  List<Object> _grouped(List<CustomFood> custom, List<FoodItem> foods) {
    final entries = <Object>[
      if (custom.isNotEmpty) ...[
        _Section(Icons.person_rounded, 'Kendi yiyeceklerin', custom.length),
        ...custom,
      ],
    ];
    for (final category in FoodCategory.values) {
      final inCategory = foods.where((f) => f.category == category);
      if (inCategory.isEmpty) continue;
      entries
        ..add(_Section(category.icon, category.label, inCategory.length))
        ..addAll(inCategory);
    }
    return entries;
  }

  void _setQuery(String value) => setState(() => _query = value);

  void _pickChip(String chip) {
    _controller.text = chip;
    _controller.selection = TextSelection.collapsed(offset: chip.length);
    _setQuery(chip);
  }

  Future<void> _recognizeFromPhoto() async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: SizedBox(
            width: 56,
            height: 56,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              child: Padding(
                padding: EdgeInsets.all(14),
                child: CircularProgressIndicator(
                    strokeWidth: 3, valueColor: AlwaysStoppedAnimation(Colors.white)),
              ),
            ),
          ),
        ),
      ),
    );

    final result = await recognizeFoodPhoto(meal: _meal);

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // close loading dialog

    if (result.cancelled) return;

    if (result.error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(result.error!)));
      return;
    }

    if (result.candidates.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
            content: Text('Fotoğraftan ne olduğunu anlayamadık. Elle aramayı dene.')));
      return;
    }

    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => _PhotoMatchSheet(
        candidates: result.candidates,
        onPick: (food) {
          Navigator.of(context).pop();
          Navigator.of(this.context).push(AppRoutes.pushFoodDetail(food,
              initialMeal: _meal, source: FoodLogSource.photo));
        },
      ),
    );
  }

  Future<void> _quickAdd(FoodItem food, {CustomFood? custom}) async {
    final messenger = ScaffoldMessenger.of(context);
    final meal = _meal;
    try {
      await context.read<AppState>().addFoodToMeal(meal, food, 1,
          source: custom == null ? FoodLogSource.catalog : FoodLogSource.custom,
          sourceRef: custom?.id);
    } catch (_) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
            content: Text('Yiyecek kaydedilemedi, lütfen tekrar dene.')));
      return;
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
          content: Text('${food.name} ${_mealLabels[meal]} listesine eklendi')));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.dengeColors;
    final custom = context.watch<AppState>().customFoods;
    final results = searchFoods(
      catalog: MockData.searchResults,
      custom: custom,
      query: _query,
      meal: _meal,
      category: _category,
    );
    final entries = _grouped(results.custom, results.catalog);
    final categories = _availableCategories(custom);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header: back button + (decorative, non-interactive) meal title.
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Row(
                children: [
                  AppBackButton(),
                  Expanded(
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_mealAddLabels[_meal]!,
                              style: theme.textTheme.titleMedium),
                          const SizedBox(width: 4),
                          Icon(Icons.keyboard_arrow_down_rounded, color: theme.colorScheme.onSurface),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            // Search field + barcode + photo-recognition buttons.
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onChanged: _setQuery,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Yiyecek veya marka ara',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _query.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.close_rounded),
                                tooltip: 'Aramayı temizle',
                                onPressed: () {
                                  _controller.clear();
                                  _setQuery('');
                                },
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _SquareIconButton(
                    icon: Icons.qr_code_scanner_rounded,
                    filled: true,
                    tooltip: 'Barkod tara',
                    onTap: () => Navigator.of(context).push(AppRoutes.pushBarcode(initialMeal: _meal)),
                  ),
                  const SizedBox(width: 8),
                  _SquareIconButton(
                    icon: Icons.camera_alt_rounded,
                    filled: false,
                    tooltip: 'Fotoğrafla tanı',
                    onTap: _recognizeFromPhoto,
                  ),
                ],
              ),
            ),
            // Popular suggestion chips.
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: [
                  Text('Popüler',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _popularChips.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final chip = _popularChips[i];
                          return OutlinedButton(
                            onPressed: () => _pickChip(chip),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 40),
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              side: BorderSide(color: colors.divider),
                              textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                            ),
                            child: Text(chip),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Category filter chips.
            SizedBox(
              height: 56,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final category = i == 0 ? null : categories[i - 1];
                  return _CategoryChip(
                    label: category?.label ?? 'Tümü',
                    icon: category?.icon ?? Icons.apps_rounded,
                    selected: _category == category,
                    onTap: () => setState(() => _category = category),
                  );
                },
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: results.isEmpty
                  ? _SearchEmptyState(
                      query: _query,
                      onScanBarcode: () => Navigator.of(context).push(AppRoutes.pushBarcode(initialMeal: _meal)),
                      onAddOwn: () => Navigator.of(context).push(
                          AppRoutes.pushCustomFood(
                              initialName: _query.trim(), initialMeal: _meal)),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 96),
                      itemCount: entries.length,
                      itemBuilder: (context, i) {
                        final entry = entries[i];
                        if (entry is _Section) {
                          return _CategoryHeader(
                            icon: entry.icon,
                            label: entry.label,
                            count: entry.count,
                            first: i == 0,
                          );
                        }
                        final tint = _rowTints(context)[i % 4];
                        if (entry is CustomFood) {
                          final food = entry.asFoodItem;
                          return _FoodRow(
                            food: food,
                            bg: tint.bg,
                            fg: tint.fg,
                            onTap: () => Navigator.of(context).push(
                                AppRoutes.pushFoodDetail(food,
                                    initialMeal: _meal,
                                    source: FoodLogSource.custom,
                                    sourceRef: entry.id)),
                            // Long-press edits or deletes an own food.
                            onLongPress: () => Navigator.of(context)
                                .push(AppRoutes.pushCustomFood(existing: entry)),
                            onQuickAdd: () => _quickAdd(food, custom: entry),
                          );
                        }
                        final food = entry as FoodItem;
                        return _FoodRow(
                          food: food,
                          bg: tint.bg,
                          fg: tint.fg,
                          onTap: () => Navigator.of(context)
                              .push(AppRoutes.pushFoodDetail(food, initialMeal: _meal)),
                          onQuickAdd: () => _quickAdd(food),
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

class _SquareIconButton extends StatelessWidget {
  const _SquareIconButton({
    required this.icon,
    required this.filled,
    required this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final bool filled;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.dengeColors;
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: filled ? scheme.primary : scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: filled ? BorderSide.none : BorderSide(color: colors.divider),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: SizedBox(
            width: 56,
            height: 56,
            child: Icon(icon, color: filled ? scheme.onPrimary : scheme.onSurface),
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.dengeColors;
    final fg = selected ? scheme.onPrimary : scheme.onSurface;
    return Material(
      color: selected ? scheme.primary : scheme.surface,
      shape: StadiumBorder(
        side: selected ? BorderSide.none : BorderSide(color: colors.divider),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: fg),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: fg)),
            ],
          ),
        ),
      ),
    );
  }
}

/// A section header entry in the result list.
class _Section {
  const _Section(this.icon, this.label, this.count);
  final IconData icon;
  final String label;
  final int count;
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({
    required this.icon,
    required this.label,
    required this.count,
    required this.first,
  });

  final IconData icon;
  final String label;
  final int count;
  final bool first;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.dengeColors;
    return Padding(
      padding: EdgeInsets.only(top: first ? 4 : 20, bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: colors.trackBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('$count', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

class _FoodRow extends StatelessWidget {
  const _FoodRow({
    required this.food,
    required this.bg,
    required this.fg,
    required this.onTap,
    required this.onQuickAdd,
    this.onLongPress,
  });

  final FoodItem food;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;
  final VoidCallback onQuickAdd;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.dengeColors;
    return Column(
      children: [
        SizedBox(
          height: 72,
          child: Row(
            children: [
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    onLongPress: onLongPress,
                    child: Row(
                      children: [
                        FoodImage(food: food, size: 52, radius: 14, bg: bg, fg: fg),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(food.name,
                                  style: theme.textTheme.bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.w800, fontSize: 16)),
                              const SizedBox(height: 2),
                              Text.rich(
                                TextSpan(
                                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
                                  children: [
                                    TextSpan(text: '${food.servingLabel} · '),
                                    TextSpan(
                                      text: '${food.caloriesPer100g} kcal',
                                      style: TextStyle(
                                          color: theme.colorScheme.onSurface, fontWeight: FontWeight.w800),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Material(
                color: theme.colorScheme.primaryContainer,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onQuickAdd,
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(Icons.add_rounded, color: theme.colorScheme.onPrimaryContainer),
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: colors.divider),
      ],
    );
  }
}

class _SearchEmptyState extends StatelessWidget {
  const _SearchEmptyState({
    required this.query,
    required this.onScanBarcode,
    required this.onAddOwn,
  });

  final String query;
  final VoidCallback onScanBarcode;
  final VoidCallback onAddOwn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.dengeColors;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(32, 24, 32, 0),
            child: Column(
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(color: colors.streakContainer, shape: BoxShape.circle),
                  child: Icon(Icons.search_off_rounded, size: 64, color: colors.streak),
                ),
                const SizedBox(height: 16),
                Text('Sonuç bulunamadı',
                    style: theme.textTheme.titleLarge?.copyWith(fontSize: 24, color: theme.colorScheme.onSurface)),
                const SizedBox(height: 8),
                Text(
                  '"$query" için eşleşen bir yiyecek bulamadık. Yazımı kontrol et ya da daha genel bir kelime dene.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 16, height: 1.4),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            children: [
              ElevatedButton.icon(
                onPressed: onAddOwn,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Yiyeceği kendin ekle'),
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onScanBarcode,
                icon: const Icon(Icons.qr_code_scanner_rounded),
                label: const Text('Barkodu tara'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  side: BorderSide.none,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  foregroundColor: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Bottom sheet shown after on-device photo recognition — the model isn't
/// food-specific, so this always asks the user to confirm rather than
/// silently trusting the best guess.
class _PhotoMatchSheet extends StatelessWidget {
  const _PhotoMatchSheet({required this.candidates, required this.onPick});

  final List<FoodItem> candidates;
  final ValueChanged<FoodItem> onPick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.dengeColors;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bu mu?', style: theme.textTheme.titleLarge?.copyWith(fontSize: 22)),
            const SizedBox(height: 4),
            Text(
              'Fotoğraftan tahmin ettik, doğrusuna dokun.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            for (final food in candidates) ...[
              Material(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => onPick(food),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colors.divider),
                    ),
                    child: Row(
                      children: [
                        FoodImage(
                          food: food,
                          size: 44,
                          radius: 12,
                          bg: colors.trackBackground,
                          fg: theme.colorScheme.onSurface,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(food.name,
                                  style: theme.textTheme.bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.w800)),
                              Text('${food.servingLabel} · ${food.caloriesPer100g} kcal',
                                  style: theme.textTheme.bodyMedium),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurface),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hiçbiri, elle ara'),
            ),
          ],
        ),
      ),
    );
  }
}
