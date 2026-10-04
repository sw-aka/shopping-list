import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_list/domain/entities/theme_settings.dart';
import 'package:shopping_list/presentation/controllers/settings_controller.dart';

import '../support/fakes.dart';

void main() {
  group('SettingsController', () {
    test('defaults to system mode and the first palette', () async {
      final controller = SettingsController(FakeSettingsRepository());
      await controller.load();
      expect(controller.themeMode, AppThemeMode.system);
      expect(controller.paletteIndex, 0);
      expect(controller.palette.name, 'Mint');
    });

    test('setPalette persists mode, palette and accent for the widget',
        () async {
      final repository = FakeSettingsRepository();
      final controller = SettingsController(repository);
      await controller.setPalette(2);

      final saved = repository.saves.single;
      expect(saved.paletteIndex, 2);
      expect(saved.mode, AppThemeMode.system);
      expect(saved.accentArgb, isA<int>());
      expect(saved.accentArgb, greaterThan(0));
    });

    test('setThemeMode persists the chosen mode', () async {
      final repository = FakeSettingsRepository();
      final controller = SettingsController(repository);
      await controller.setThemeMode(AppThemeMode.dark);
      expect(repository.saves.single.mode, AppThemeMode.dark);
      expect(controller.materialThemeMode.name, 'dark');
    });

    test('load reads persisted settings', () async {
      final repository = FakeSettingsRepository(
        const ThemeSettings(mode: AppThemeMode.light, paletteIndex: 3),
      );
      final controller = SettingsController(repository);
      await controller.load();
      expect(controller.themeMode, AppThemeMode.light);
      expect(controller.paletteIndex, 3);
    });
  });
}
