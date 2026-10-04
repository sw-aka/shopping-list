import 'package:flutter/material.dart';

import '../../domain/entities/theme_settings.dart';
import '../controllers/settings_controller.dart';
import '../theme/app_palette.dart';
import 'palette_dot.dart';

Future<void> showAppearanceSheet(
  BuildContext context,
  SettingsController controller,
) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => ListenableBuilder(
      listenable: controller,
      builder: (context, _) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Appearance',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            SegmentedButton<AppThemeMode>(
              segments: const [
                ButtonSegment(
                    value: AppThemeMode.system,
                    label: Text('Auto'),
                    icon: Icon(Icons.brightness_auto)),
                ButtonSegment(
                    value: AppThemeMode.light,
                    label: Text('Light'),
                    icon: Icon(Icons.light_mode)),
                ButtonSegment(
                    value: AppThemeMode.dark,
                    label: Text('Dark'),
                    icon: Icon(Icons.dark_mode)),
              ],
              selected: <AppThemeMode>{controller.themeMode},
              onSelectionChanged: (selection) =>
                  controller.setThemeMode(selection.first).ignore(),
            ),
            const SizedBox(height: 24),
            Text('Colour', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (int i = 0; i < appPalettes.length; i++)
                  PaletteDot(
                    palette: appPalettes[i],
                    selected: i == controller.paletteIndex,
                    onTap: () => controller.setPalette(i).ignore(),
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
