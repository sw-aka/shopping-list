import 'package:flutter/material.dart';

/// Palette seed colours for the Material 3 scheme.
class AppPalette {
  const AppPalette(this.name, this.seed);

  final String name;
  final Color seed;
}

const List<AppPalette> appPalettes = <AppPalette>[
  AppPalette('Mint', Color(0xFF2E7D5B)),
  AppPalette('Ocean', Color(0xFF1565C0)),
  AppPalette('Lavender', Color(0xFF7E57C2)),
  AppPalette('Sunset', Color(0xFFE65100)),
  AppPalette('Rose', Color(0xFFC2185B)),
  AppPalette('Slate', Color(0xFF546E7A)),
];
