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
      child: Consumer<AppState>(
        builder: (context, state, _) {
          return MaterialApp(
            title: 'Denge',
            debugShowCheckedModeBanner: false,
            themeMode: state.themeMode,
            theme: AppTheme.light(reduceMotion: state.reduceMotion),
            darkTheme: AppTheme.dark(reduceMotion: state.reduceMotion),
            initialRoute: AppRoutes.splash,
            routes: AppRoutes.routes,
            builder: (context, child) {
              final mediaQuery = MediaQuery.of(context);
              return MediaQuery(
                data: mediaQuery.copyWith(
                  textScaler: TextScaler.linear(state.textScale.scale),
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
