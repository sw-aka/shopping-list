import 'package:flutter/material.dart';

/// Palette seed colours for the Material 3 scheme.
class AppPalette {
  const AppPalette(this.name, this.seed);

  final String name;
  final Color seed;
}

const appPalettes = <AppPalette>[
  AppPalette('Mint', Color(0xFF2E7D5B)),
  AppPalette('Ocean', Color(0xFF1565C0)),
  AppPalette('Lavender', Color(0xFF7E57C2)),
  AppPalette('Sunset', Color(0xFFE65100)),
  AppPalette('Rose', Color(0xFFC2185B)),
  AppPalette('Slate', Color(0xFF546E7A)),
];

ThemeData buildTheme(AppPalette palette, Brightness brightness) {
  final scheme =
      ColorScheme.fromSeed(seedColor: palette.seed, brightness: brightness);
  return ThemeData(
    colorScheme: scheme,
    brightness: brightness,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      centerTitle: false,
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    ),
  );
}
