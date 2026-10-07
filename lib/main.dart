import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/app_state.dart';
import 'data/backend/supabase_auth_service.dart';
import 'data/backend/supabase_sync_backend.dart';
import 'data/db/app_database.dart';
import 'data/local_reminder_scheduler.dart';
import 'router.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Reminders are optional: if the notification plugin can't start, the
  // app keeps the no-op scheduler and works without them.
  try {
    final reminders = LocalReminderScheduler();
    await reminders.init();
    AppState.instance.reminders = reminders;
  } catch (e, st) {
    developer.log('Reminder setup failed', error: e, stackTrace: st);
  }
  // Accounts only exist when the Supabase settings were passed with
  // --dart-define-from-file=env/dev.json; otherwise the app is local-only.
  if (SupabaseConfig.isConfigured) {
    try {
      AppState.instance
        ..auth = await SupabaseAuthService.initialize()
        ..syncBackend = SupabaseSyncBackend.forInitializedClient();
    } catch (e, st) {
      developer.log('Supabase setup failed', error: e, stackTrace: st);
    }
  }
  await AppState.instance.load(db: AppDatabase());
  runApp(const DengeApp());
}

/// Lets [DengeApp] show app-level messages (e.g. a database error) and
/// screens (the password-reset link) without a screen's own [BuildContext].
final _messengerKey = GlobalKey<ScaffoldMessengerState>();
final _navigatorKey = GlobalKey<NavigatorState>();

class DengeApp extends StatefulWidget {
  const DengeApp({super.key});

  @override
  State<DengeApp> createState() => _DengeAppState();
}

class _DengeAppState extends State<DengeApp> {
  /// A password-reset link opened the app: ask for the new password.
  void _onAppStateChanged() {
    if (AppState.instance.takePendingPasswordRecovery()) {
      _navigatorKey.currentState?.push(AppRoutes.pushNewPassword());
    }
  }

  @override
  void dispose() {
    AppState.instance.removeListener(_onAppStateChanged);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    AppState.instance.addListener(_onAppStateChanged);
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
            navigatorKey: _navigatorKey,
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
