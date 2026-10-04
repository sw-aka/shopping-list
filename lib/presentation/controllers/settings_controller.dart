import 'package:flutter/material.dart';

import '../../domain/entities/theme_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../theme/app_palette.dart';

class SettingsController extends ChangeNotifier {
  SettingsController(this._repository);

  final SettingsRepository _repository;

  AppThemeMode _themeMode = AppThemeMode.system;
  AppThemeMode get themeMode => _themeMode;

  int _paletteIndex = 0;
  int get paletteIndex => _paletteIndex;

  AppPalette get palette => appPalettes[_paletteIndex % appPalettes.length];

  ThemeMode get materialThemeMode => switch (_themeMode) {
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
        AppThemeMode.system => ThemeMode.system,
      };

  Object? _lastError;
  Object? get lastError => _lastError;

  Future<void> load() async {
    try {
      final ThemeSettings settings = await _repository.load();
      _themeMode = settings.mode;
      _paletteIndex = settings.paletteIndex % appPalettes.length;
      _lastError = null;
    } catch (error) {
      _lastError = error;
    }
    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await _persist();
  }

  Future<void> setPalette(int index) async {
    _paletteIndex = index % appPalettes.length;
    notifyListeners();
    await _persist();
  }

  /// The tint the native widget uses, derived exactly as the in-app scheme does.
  int get accentArgb =>
      ColorScheme.fromSeed(seedColor: palette.seed).primary.toARGB32();

  Future<void> _persist() async {
    try {
      await _repository.save(ThemeSettings(
        mode: _themeMode,
        paletteIndex: _paletteIndex,
        accentArgb: accentArgb,
      ));
      _lastError = null;
    } catch (error) {
      _lastError = error;
    }
  }
}
