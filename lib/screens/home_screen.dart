import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../models/app_state.dart';
import '../models/shopping_item.dart';
import '../services/store.dart';
import '../theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.state});

  final AppState state;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  AppState get state => widget.state;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkLaunchAction());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    if (lifecycleState == AppLifecycleState.resumed) {
      // The widget may have edited the list while we were backgrounded.
      state.load().then((_) => _checkLaunchAction());
    }
  }

  Future<void> _checkLaunchAction() async {
    final action = await Store().takeLaunchAction();
    if (action == 'add' && mounted) _showAddSheet();
  }

  Future<void> _showAddSheet() async {
    final controller = TextEditingController();
    final focusNode = FocusNode();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(hintText: 'Add an item…'),
                onSubmitted: (value) {
                  state.add(value);
                  // Keep the sheet open for the next item.
                  controller.clear();
                  focusNode.requestFocus();
                },
              ),
            ),
            const SizedBox(width: 12),
            IconButton.filled(
              icon: const Icon(Icons.add),
              tooltip: 'Add',
              onPressed: () {
                state.add(controller.text);
                controller.clear();
                focusNode.requestFocus();
              },
            ),
          ],
        ),
      ),
    );
    // Save any text left in the field when it closes.
    state.add(controller.text);
    controller.dispose();
    focusNode.dispose();
  }

  void _showThemeSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => ListenableBuilder(
        listenable: state,
        builder: (context, _) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Appearance',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                      value: ThemeMode.system,
                      label: Text('Auto'),
                      icon: Icon(Icons.brightness_auto)),
                  ButtonSegment(
                      value: ThemeMode.light,
                      label: Text('Light'),
                      icon: Icon(Icons.light_mode)),
                  ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text('Dark'),
                      icon: Icon(Icons.dark_mode)),
                ],
                selected: {state.themeMode},
                onSelectionChanged: (selection) =>
                    state.setThemeMode(selection.first),
              ),
              const SizedBox(height: 24),
              Text('Colour', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (var i = 0; i < appPalettes.length; i++)
                    _PaletteDot(
                      palette: appPalettes[i],
                      selected: i == state.paletteIndex,
                      onTap: () => state.setPalette(i),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _share() {
    SharePlus.instance.share(ShareParams(text: shareText(state.items)));
  }

  void _removeItem(ShoppingItem item) {
    state.remove(item.id);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('Removed ${item.name}'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: state.undoRemove,
        ),
      ));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final items = state.items;
        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Shopping'),
                if (items.isNotEmpty)
                  Text(
                    '${state.doneCount} of ${items.length} done',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline),
                  ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined),
                tooltip: 'Share list',
                onPressed: items.isEmpty ? null : _share,
              ),
              PopupMenuButton<String>(
                onSelected: (value) => switch (value) {
                  'theme' => _showThemeSheet(),
                  'clear_done' => state.clearDone(),
                  _ => null,
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'theme',
                    child: ListTile(
                      leading: Icon(Icons.palette_outlined),
                      title: Text('Appearance'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'clear_done',
                    enabled: state.doneCount > 0,
                    child: const ListTile(
                      leading: Icon(Icons.cleaning_services_outlined),
                      title: Text('Clear completed'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: items.isEmpty
              ? _EmptyState(onAdd: _showAddSheet)
              : ReorderableListView.builder(
                  buildDefaultDragHandles: false,
                  padding: const EdgeInsets.only(bottom: 96, top: 4),
                  itemCount: items.length,
                  onReorderItem: state.reorder,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _ItemTile(
                      key: ValueKey(item.id),
                      item: item,
                      index: index,
                      onToggle: () => state.toggle(item.id),
                      onDismissed: () => _removeItem(item),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _showAddSheet,
            icon: const Icon(Icons.add),
            label: const Text('Add item'),
          ),
        );
      },
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({
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
    final scheme = Theme.of(context).colorScheme;
    return Dismissible(
      key: ValueKey('dismiss-${item.id}'),
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
                decoration:
                    item.done ? TextDecoration.lineThrough : TextDecoration.none,
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_basket_outlined,
              size: 72, color: scheme.outlineVariant),
          const SizedBox(height: 16),
          Text('Nothing to buy yet',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: scheme.outline)),
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

class _PaletteDot extends StatelessWidget {
  const _PaletteDot({
    required this.palette,
    required this.selected,
    required this.onTap,
  });

  final AppPalette palette;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
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
