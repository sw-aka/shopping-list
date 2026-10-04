import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

class PaletteDot extends StatelessWidget {
  const PaletteDot({
    super.key,
    required this.palette,
    required this.selected,
    required this.onTap,
  });

  final AppPalette palette;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: palette.name,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: palette.seed,
            shape: BoxShape.circle,
            border: selected
                ? Border.all(color: scheme.onSurface, width: 3)
                : Border.all(color: scheme.outlineVariant),
          ),
          child: selected
              ? const Icon(Icons.check, color: Colors.white)
              : null,
        ),
      ),
    );
  }
}
