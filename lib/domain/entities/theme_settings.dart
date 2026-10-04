enum AppThemeMode { system, light, dark }

class ThemeSettings {
  const ThemeSettings({
    this.mode = AppThemeMode.system,
    this.paletteIndex = 0,
    this.accentArgb = defaultAccentArgb,
  });

  // Mint; kept in step with Prefs.DEFAULT_ACCENT on the native side.
  static const int defaultAccentArgb = 0xFF2E7D5B;

  final AppThemeMode mode;
  final int paletteIndex;
  final int accentArgb;

  ThemeSettings copyWith({
    AppThemeMode? mode,
    int? paletteIndex,
    int? accentArgb,
  }) =>
      ThemeSettings(
        mode: mode ?? this.mode,
        paletteIndex: paletteIndex ?? this.paletteIndex,
        accentArgb: accentArgb ?? this.accentArgb,
      );

  @override
  bool operator ==(Object other) =>
      other is ThemeSettings &&
      other.mode == mode &&
      other.paletteIndex == paletteIndex &&
      other.accentArgb == accentArgb;

  @override
  int get hashCode => Object.hash(mode, paletteIndex, accentArgb);
}
