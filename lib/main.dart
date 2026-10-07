import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/app_state.dart';
import 'data/db/app_database.dart';
import 'router.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppState.instance.load(db: AppDatabase());
  runApp(const DengeApp());
}

/// Lets [DengeApp] show app-level messages (e.g. a database error) without
/// a screen's own [BuildContext].
final _messengerKey = GlobalKey<ScaffoldMessengerState>();

class DengeApp extends StatefulWidget {
  const DengeApp({super.key});

  @override
  State<DengeApp> createState() => _DengeAppState();
}

class _DengeAppState extends State<DengeApp> {
  @override
  void initState() {
    super.initState();
    final error = AppState.instance.storageError;
    if (error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _messengerKey.currentState?.showSnackBar(
          SnackBar(content: Text(error), duration: const Duration(seconds: 8)),
        );
      });
    }
  }

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
            scaffoldMessengerKey: _messengerKey,
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
