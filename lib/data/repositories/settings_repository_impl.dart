import '../../domain/entities/theme_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/shopping_store_data_source.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._store);

  final ShoppingStoreDataSource _store;

  @override
  Future<ThemeSettings> load() async {
    final Map<Object?, Object?>? raw = await _store.loadTheme();
    if (raw == null) return const ThemeSettings();
    return ThemeSettings(
      mode: _modeFromName(raw['mode'] as String?),
      paletteIndex: raw['palette'] as int? ?? 0,
      accentArgb: raw['accent'] as int? ?? ThemeSettings.defaultAccentArgb,
    );
  }

  @override
  Future<void> save(ThemeSettings settings) => _store.saveTheme(
        mode: _nameFromMode(settings.mode),
        palette: settings.paletteIndex,
        accentArgb: settings.accentArgb,
      );

  static AppThemeMode _modeFromName(String? name) => switch (name) {
        'light' => AppThemeMode.light,
        'dark' => AppThemeMode.dark,
        _ => AppThemeMode.system,
      };

  static String _nameFromMode(AppThemeMode mode) => switch (mode) {
        AppThemeMode.light => 'light',
        AppThemeMode.dark => 'dark',
        AppThemeMode.system => 'system',
      };
}
