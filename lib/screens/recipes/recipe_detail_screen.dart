import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/section_card.dart';

/// Recipe detail: hero header, tag/time/calorie chips, ingredients and
/// numbered steps — content comes entirely from the [recipe] passed in.
class RecipeDetailScreen extends StatelessWidget {
  const RecipeDetailScreen({super.key, required this.recipe});

  final Recipe recipe;

  static const _heroIcon = Icons.restaurant_menu_rounded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final topInset = MediaQuery.paddingOf(context).top;
    final heroTint = scheme.primary;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 280,
                  color: heroTint.withValues(alpha: 0.14),
                  alignment: Alignment.center,
                  child: Icon(_heroIcon, size: 120, color: heroTint),
                ),
                Positioned(
                  left: AppSpacing.xl,
                  right: AppSpacing.xl,
                  top: topInset + 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AppBackButton(),
                      _CircleIconButton(
                        icon: Icons.favorite_rounded,
                        color: context.dengeColors.streak,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(recipe.title, style: theme.textTheme.headlineLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    recipe.description,
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      _Chip(
                        icon: Icons.local_offer_rounded,
                        label: recipe.tag,
                        background: scheme.primaryContainer,
                        foreground: AppTheme.primaryText(theme.brightness),
                      ),
                      _Chip(
                        icon: Icons.schedule_rounded,
                        label: '${recipe.minutes} dk',
                        background: context.dengeColors.trackBackground,
                        foreground: scheme.onSurface,
                      ),
                      _Chip(
                        icon: Icons.local_fire_department_rounded,
                        label: '${recipe.calories} kcal',
                        background: context.dengeColors.trackBackground,
                        foreground: scheme.onSurface,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Text('Malzemeler', style: theme.textTheme.titleLarge?.copyWith(fontSize: 20)),
                  const SizedBox(height: AppSpacing.md),
                  SectionCard(
                    child: Column(
                      children: [
                        for (var i = 0; i < recipe.ingredients.length; i++)
                          Padding(
                            padding: EdgeInsets.only(
                                bottom:
                                    i == recipe.ingredients.length - 1 ? 0 : AppSpacing.md),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: scheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Text(
                                    recipe.ingredients[i],
                                    style: theme.textTheme.bodyLarge
                                        ?.copyWith(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Text('Hazırlanışı', style: theme.textTheme.titleLarge?.copyWith(fontSize: 20)),
                  const SizedBox(height: AppSpacing.lg),
                  for (var i = 0; i < recipe.steps.length; i++)
                    Padding(
                      padding: EdgeInsets.only(
                          bottom: i == recipe.steps.length - 1 ? 0 : AppSpacing.lg),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: scheme.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${i + 1}',
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
                              child: Text(
                                recipe.steps[i],
                                style: theme.textTheme.bodyLarge
                                    ?.copyWith(fontSize: 16, height: 1.5),
                              ),
                            ),
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
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton(
      {required this.icon, required this.color, required this.onTap});

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: scheme.surface,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.07),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 22, color: color),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foreground),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}
