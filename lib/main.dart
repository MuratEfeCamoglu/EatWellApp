import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/app_state.dart';
import 'router.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppState.instance.load();
  runApp(const DengeApp());
}

class DengeApp extends StatelessWidget {
  const DengeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: AppState.instance,
      // Rebuild the app root only when an app-wide display setting changes,
      // not on every AppState change (water, meals, favorites...) — those
      // only need to rebuild the screens that watch them.
      child: Selector<AppState, (ThemeMode, bool, TextScaleOption)>(
        selector: (_, s) => (s.themeMode, s.reduceMotion, s.textScale),
        builder: (context, settings, _) {
          final (themeMode, reduceMotion, textScale) = settings;
          return MaterialApp(
            title: 'Denge',
            debugShowCheckedModeBanner: false,
            themeMode: themeMode,
            theme: AppTheme.light(reduceMotion: reduceMotion),
            darkTheme: AppTheme.dark(reduceMotion: reduceMotion),
            initialRoute: AppRoutes.splash,
            routes: AppRoutes.routes,
            builder: (context, child) {
              final mediaQuery = MediaQuery.of(context);
              return MediaQuery(
                data: mediaQuery.copyWith(
                  textScaler: TextScaler.linear(textScale.scale),
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
