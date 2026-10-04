import '../entities/theme_settings.dart';

abstract interface class SettingsRepository {
  Future<ThemeSettings> load();

  Future<void> save(ThemeSettings settings);
}
