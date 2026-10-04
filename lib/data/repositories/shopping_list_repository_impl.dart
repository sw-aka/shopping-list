import '../../domain/entities/shopping_item.dart';
import '../../domain/repositories/shopping_list_repository.dart';
import '../datasources/shopping_store_data_source.dart';
import '../models/shopping_item_mapper.dart';

class ShoppingListRepositoryImpl implements ShoppingListRepository {
  ShoppingListRepositoryImpl(this._store);

  final ShoppingStoreDataSource _store;

  // Writes are chained so a burst of edits cannot reach the native store out
  // of order.
  Future<void> _writeQueue = Future<void>.value();

  @override
  Future<List<ShoppingItem>> load() async {
    final json = await _store.loadListJson();
    return ShoppingItemMapper.listFromJsonString(json);
  }

  @override
  Future<void> save(List<ShoppingItem> items) {
    final json = ShoppingItemMapper.listToJsonString(items);
    return _enqueue(() => _store.saveListJson(json));
  }

  @override
  Future<void> pushUndo(String id) => _enqueue(() => _store.pushUndo(id));

  @override
  Future<String?> consumeLaunchAction() => _store.takeLaunchAction();

  Future<void> _enqueue(Future<void> Function() action) {
    final Future<void> next = _writeQueue.then((_) => action());
    _writeQueue = next.catchError((Object _) {});
    return next;
  }
}
