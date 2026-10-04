import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/app_dependencies.dart';
import '../../app/app_scope.dart';
import '../../domain/entities/shopping_item.dart';
import '../controllers/settings_controller.dart';
import '../controllers/shopping_list_controller.dart';
import '../widgets/add_item_sheet.dart';
import '../widgets/appearance_sheet.dart';
import '../widgets/empty_state.dart';
import '../widgets/item_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  AppDependencies get _dependencies => AppScope.of(context);
  ShoppingListController get _list => _dependencies.shoppingList;
  SettingsController get _settings => _dependencies.settings;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleLaunchAction());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // The widget may have edited the list while we were backgrounded.
      _reload();
    }
  }

  Future<void> _reload() async {
    await _list.load();
    await _handleLaunchAction();
  }

  Future<void> _handleLaunchAction() async {
    if (!mounted) return;
    final String? action = await _list.consumeLaunchAction();
    if (action == 'add' && mounted) {
      await showAddItemSheet(context, _list);
    }
  }

  void _share() {
    SharePlus.instance.share(
      ShareParams(text: _dependencies.shareFormatter.format(_list.items)),
    );
  }

  void _removeItem(ShoppingItem item) {
    _list.remove(item.id).ignore();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Removed ${item.name}'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => _list.undoRemove().ignore(),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _list,
      builder: (context, _) {
        final List<ShoppingItem> items = _list.items;
        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Shopping'),
                if (items.isNotEmpty)
                  Text(
                    '${_list.doneCount} of ${items.length} done',
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
                  'theme' => showAppearanceSheet(context, _settings),
                  'clear_done' => _list.clearDone().ignore(),
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
                    enabled: _list.doneCount > 0,
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
              ? EmptyState(onAdd: () => showAddItemSheet(context, _list))
              : ReorderableListView.builder(
                  buildDefaultDragHandles: false,
                  padding: const EdgeInsets.only(bottom: 96, top: 4),
                  itemCount: items.length,
                  onReorderItem: (oldIndex, newIndex) =>
                      _list.reorder(oldIndex, newIndex).ignore(),
                  itemBuilder: (context, index) {
                    final ShoppingItem item = items[index];
                    return ItemTile(
                      key: ValueKey<String>(item.id),
                      item: item,
                      index: index,
                      onToggle: () => _list.toggle(item.id).ignore(),
                      onDismissed: () => _removeItem(item),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => showAddItemSheet(context, _list),
            icon: const Icon(Icons.add),
            label: const Text('Add item'),
          ),
        );
      },
    );
  }
}
