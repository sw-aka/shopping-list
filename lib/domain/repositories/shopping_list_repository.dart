import '../entities/shopping_item.dart';

abstract interface class ShoppingListRepository {
  Future<List<ShoppingItem>> load();

  Future<void> save(List<ShoppingItem> items);

  /// Adds a tick to the widget's undo history.
  Future<void> pushUndo(String id);

  /// Returns and clears a pending launch_action intent extra.
  Future<String?> consumeLaunchAction();
}
