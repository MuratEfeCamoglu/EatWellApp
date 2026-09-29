import 'package:flutter/material.dart';

import '../router.dart';
import '../theme/app_theme.dart';
import 'diary/diary_screen.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';
import 'progress/progress_screen.dart';
import 'recipes/recipes_screen.dart';

/// Hosts the 5 bottom-nav tabs (Home, Diary, Progress, Recipes, Profile)
/// plus the floating "add food" button that sits above the nav bar,
/// matching the persistent bottom nav in the design.
class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index = widget.initialIndex;

  static const _tabs = [
    HomeScreen(),
    DiaryScreen(),
    ProgressScreen(),
    RecipesScreen(),
    ProfileScreen(),
  ];

  static const _labels = ['Ana Sayfa', 'Günlük', 'İlerleme', 'Tarifler', 'Profil'];
  static const _icons = [
    Icons.home_rounded,
    Icons.menu_book_rounded,
    Icons.show_chart_rounded,
    Icons.restaurant_menu_rounded,
    Icons.person_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _index, children: _tabs),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: (_index == 0 || _index == 1)
          ? Padding(
              padding: const EdgeInsets.only(bottom: 64),
              child: FloatingActionButton(
                heroTag: 'addFood',
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22)),
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                onPressed: () => Navigator.of(context).pushNamed(AppRoutes.search),
                child: const Icon(Icons.add_rounded, size: 28),
              ),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: List.generate(
          _labels.length,
          (i) => BottomNavigationBarItem(
            icon: _NavIcon(icon: _icons[i], selected: i == _index),
            label: _labels[i],
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({required this.icon, required this.selected});

  final IconData icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 56,
      height: 32,
      decoration: BoxDecoration(
        color: selected ? scheme.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: 22,
        color: selected ? AppTheme.primaryText(scheme.brightness) : null,
      ),
    );
  }
}
