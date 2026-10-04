import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_basket_outlined,
            size: 72,
            color: scheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Nothing to buy yet',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: scheme.outline),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Add your first item'),
          ),
        ],
      ),
    );
  }
}
