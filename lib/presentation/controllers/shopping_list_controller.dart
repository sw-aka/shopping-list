import 'package:flutter/foundation.dart';

import '../../domain/entities/shopping_item.dart';
import '../../domain/repositories/shopping_list_repository.dart';

/// List state shared with the home-screen widget.
class ShoppingListController extends ChangeNotifier {
  ShoppingListController(this._repository);

  final ShoppingListRepository _repository;

  List<ShoppingItem> _items = const <ShoppingItem>[];
  List<ShoppingItem> get items => List<ShoppingItem>.unmodifiable(_items);

  int get doneCount => _items.where((item) => item.done).length;

  Object? _lastError;
  Object? get lastError => _lastError;

  int _nextId = 0;

  /// Kept for the remove snackbar's undo action.
  (ShoppingItem, int)? _lastRemoved;

  Future<void> load() async {
    try {
      _items = await _repository.load();
      _lastError = null;
    } catch (error) {
      _lastError = error;
    }
    notifyListeners();
  }

  Future<void> add(String name) async {
    final String trimmed = name.trim();
    if (trimmed.isEmpty) return;
    _items = <ShoppingItem>[
      ..._items,
      ShoppingItem(id: _newId(), name: trimmed),
    ];
    notifyListeners();
    await _persist();
  }

  /// Ticked items go to the bottom. Unticked items rejoin the active section.
  Future<void> toggle(String id) async {
    final int index = _items.indexWhere((item) => item.id == id);
    if (index < 0) return;

    final ShoppingItem updated =
        _items[index].copyWith(done: !_items[index].done);
    final List<ShoppingItem> list = <ShoppingItem>[..._items]..removeAt(index);
    if (updated.done) {
      list.add(updated);
      _repository.pushUndo(id).ignore();
    } else {
      final int firstDone = list.indexWhere((item) => item.done);
      list.insert(firstDone < 0 ? list.length : firstDone, updated);
    }
    _items = list;
    notifyListeners();
    await _persist();
  }

  Future<void> rename(String id, String name) async {
    final String trimmed = name.trim();
    if (trimmed.isEmpty) return;
    _items = <ShoppingItem>[
      for (final item in _items)
        item.id == id ? item.copyWith(name: trimmed) : item,
    ];
    notifyListeners();
    await _persist();
  }

  Future<void> remove(String id) async {
    final int index = _items.indexWhere((item) => item.id == id);
    if (index < 0) return;
    _lastRemoved = (_items[index], index);
    _items = <ShoppingItem>[..._items]..removeAt(index);
    notifyListeners();
    await _persist();
  }

  Future<void> undoRemove() async {
    final (ShoppingItem, int)? removed = _lastRemoved;
    if (removed == null) return;
    _lastRemoved = null;
    final int index = removed.$2.clamp(0, _items.length);
    _items = <ShoppingItem>[..._items]..insert(index, removed.$1);
    notifyListeners();
    await _persist();
  }

  /// [newIndex] is the destination after removal (onReorderItem semantics).
  Future<void> reorder(int oldIndex, int newIndex) async {
    final List<ShoppingItem> list = <ShoppingItem>[..._items];
    list.insert(newIndex, list.removeAt(oldIndex));
    _items = list;
    notifyListeners();
    await _persist();
  }

  Future<void> clearDone() async {
    _items = <ShoppingItem>[
      for (final item in _items)
        if (!item.done) item,
    ];
    notifyListeners();
    await _persist();
  }

  Future<String?> consumeLaunchAction() => _repository.consumeLaunchAction();

  String _newId() => '${DateTime.now().microsecondsSinceEpoch}-${_nextId++}';

  Future<void> _persist() async {
    try {
      await _repository.save(List<ShoppingItem>.unmodifiable(_items));
      _lastError = null;
    } catch (error) {
      _lastError = error;
    }
  }
}
