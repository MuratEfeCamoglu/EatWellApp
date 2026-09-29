import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Shared radii used throughout Denge's cards, fields and buttons.
class AppRadius {
  static const card = 16.0;
  static const field = 16.0;
  static const button = 16.0;
  static const pill = 24.0;
  static const iconBoxSmall = 12.0;
  static const iconBoxMedium = 14.0;
}

/// Shared spacing scale (matches the 8px grid used across the design).
class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

class AppTheme {
  AppTheme._();

  static const _lightPrimary = Color(0xFF1F7A48);
  static const _lightPrimaryText = Color(0xFF1D7445);
  static const _lightPrimaryContainer = Color(0xFFE4F3EA);
  static const _lightBackground = Color(0xFFF5F8F4);
  static const _lightSurface = Color(0xFFFFFFFF);
  static const _lightTextPrimary = Color(0xFF14201A);
  static const _lightTextSecondary = Color(0xFF55655B);
  static const _lightRing = Color(0xFF35A866);

  static const _darkPrimary = Color(0xFF4CC27F);
  static const _darkPrimaryText = Color(0xFF6FD49B);
  static const _darkPrimaryContainer = Color(0xFF173726);
  static const _darkBackground = Color(0xFF0D1410);
  static const _darkSurface = Color(0xFF161F1A);
  static const _darkTextPrimary = Color(0xFFECF3EE);
  static const _darkTextSecondary = Color(0xFFA3B3A9);
  static const _darkRing = Color(0xFF4CC27F);

  static Color ring(Brightness b) =>
      b == Brightness.dark ? _darkRing : _lightRing;

  static Color primaryText(Brightness b) =>
      b == Brightness.dark ? _darkPrimaryText : _lightPrimaryText;

  static const _fontFamily = 'Nunito';

  static TextTheme _textTheme(Color primary, Color secondary) {
    final base = Typography.material2021().black;
    return base
        .copyWith(
          displayLarge: base.displayLarge?.copyWith(
              fontWeight: FontWeight.w800, letterSpacing: -1, color: primary),
          headlineLarge: base.headlineLarge?.copyWith(
              fontWeight: FontWeight.w800, letterSpacing: -0.4, color: primary),
          headlineMedium: base.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800, color: primary),
          titleLarge: base.titleLarge
              ?.copyWith(fontWeight: FontWeight.w800, color: primary),
          titleMedium: base.titleMedium
              ?.copyWith(fontWeight: FontWeight.w800, color: primary),
          titleSmall: base.titleSmall
              ?.copyWith(fontWeight: FontWeight.w800, color: primary),
          bodyLarge: base.bodyLarge
              ?.copyWith(fontWeight: FontWeight.w600, color: primary),
          bodyMedium: base.bodyMedium
              ?.copyWith(fontWeight: FontWeight.w600, color: secondary),
          bodySmall: base.bodySmall
              ?.copyWith(fontWeight: FontWeight.w700, color: secondary),
          labelLarge: base.labelLarge
              ?.copyWith(fontWeight: FontWeight.w800, color: primary),
        )
        .apply(fontFamily: _fontFamily);
  }

  // Built themes are cached: constructing a ThemeData is costly, and a fresh
  // (non-identical) instance would force every Theme.of() dependent in the
  // app to rebuild.
  static final _lightCache = <bool, ThemeData>{};
  static final _darkCache = <bool, ThemeData>{};

  static ThemeData light({bool reduceMotion = false}) =>
      _lightCache.putIfAbsent(reduceMotion, () => _buildLight(reduceMotion));

  static ThemeData dark({bool reduceMotion = false}) =>
      _darkCache.putIfAbsent(reduceMotion, () => _buildDark(reduceMotion));

  static ThemeData _buildLight(bool reduceMotion) {
    const scheme = ColorScheme.light(
      brightness: Brightness.light,
      primary: _lightPrimary,
      onPrimary: Colors.white,
      primaryContainer: _lightPrimaryContainer,
      onPrimaryContainer: _lightPrimaryText,
      surface: _lightSurface,
      onSurface: _lightTextPrimary,
      surfaceContainerLowest: _lightBackground,
      error: Color(0xFFB3261E),
      onError: Colors.white,
      outline: Color(0xFFE1E9E3),
    );
    return _build(scheme, _lightBackground, _lightTextPrimary,
        _lightTextSecondary, DengeColors.light, reduceMotion);
  }

  static ThemeData _buildDark(bool reduceMotion) {
    const scheme = ColorScheme.dark(
      brightness: Brightness.dark,
      primary: _darkPrimary,
      onPrimary: Color(0xFF06170F),
      primaryContainer: _darkPrimaryContainer,
      onPrimaryContainer: _darkPrimaryText,
      surface: _darkSurface,
      onSurface: _darkTextPrimary,
      surfaceContainerLowest: _darkBackground,
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      outline: Color(0xFF27342C),
    );
    return _build(scheme, _darkBackground, _darkTextPrimary,
        _darkTextSecondary, DengeColors.dark, reduceMotion);
  }

  static ThemeData _build(ColorScheme scheme, Color background,
      Color textPrimary, Color textSecondary, DengeColors dengeColors,
      bool reduceMotion) {
    final textTheme = _textTheme(textPrimary, textSecondary);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      fontFamily: _fontFamily,
      textTheme: textTheme,
      extensions: [dengeColors],
      pageTransitionsTheme: reduceMotion
          ? const PageTransitionsTheme(builders: {
              TargetPlatform.android: _InstantPageTransitionsBuilder(),
              TargetPlatform.iOS: _InstantPageTransitionsBuilder(),
            })
          : null,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textPrimary,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.card)),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(color: dengeColors.divider, thickness: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
          borderSide: BorderSide(color: dengeColors.divider, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
          borderSide: BorderSide(color: dengeColors.divider, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        hintStyle: TextStyle(color: textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size.fromHeight(56),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.button)),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          minimumSize: const Size.fromHeight(56),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          side: BorderSide(color: dengeColors.divider, width: 1.5),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.button)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryText(scheme.brightness),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: scheme.surface,
        selectedItemColor: primaryText(scheme.brightness),
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? scheme.primary
                : Colors.white),
        trackColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? scheme.primary.withValues(alpha: 0.5)
                : dengeColors.divider),
      ),
    );
  }
}

/// Used for the "Azaltılmış hareket" (reduce motion) accessibility setting:
/// swaps a page in immediately instead of animating it in.
class _InstantPageTransitionsBuilder extends PageTransitionsBuilder {
  const _InstantPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}
