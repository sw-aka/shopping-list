import 'package:flutter/material.dart';

import '../../domain/entities/shopping_item.dart';

class ItemTile extends StatelessWidget {
  const ItemTile({
    super.key,
    required this.item,
    required this.index,
    required this.onToggle,
    required this.onDismissed,
  });

  final ShoppingItem item;
  final int index;
  final VoidCallback onToggle;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Dismissible(
      key: ValueKey<String>('dismiss-${item.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismissed(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: scheme.errorContainer,
        child: Icon(Icons.delete_outline, color: scheme.onErrorContainer),
      ),
      child: ListTile(
        onTap: onToggle,
        leading: Checkbox(
          value: item.done,
          onChanged: (_) => onToggle(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        title: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 150),
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                decoration: item.done
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                color: item.done ? scheme.outline : scheme.onSurface,
              ),
          child: Text(item.name),
        ),
        trailing: ReorderableDragStartListener(
          index: index,
          child: Icon(Icons.drag_handle, color: scheme.outlineVariant),
        ),
      ),
    );
  }
}
