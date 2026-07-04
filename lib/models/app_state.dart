import 'package:flutter/material.dart';

import '../services/store.dart';
import '../theme.dart';
import 'shopping_item.dart';

/// List and theme state shared with the home-screen widget through [Store].
class AppState extends ChangeNotifier {
  AppState(this._store);

  final Store _store;

  List<ShoppingItem> _items = [];
  List<ShoppingItem> get items => List.unmodifiable(_items);

  ThemeMode themeMode = ThemeMode.system;
  int paletteIndex = 0;
  AppPalette get palette => appPalettes[paletteIndex % appPalettes.length];

  int _nextId = 0;

  /// Kept for the remove snackbar's undo action.
  (ShoppingItem, int)? _lastRemoved;

  Future<void> load() async {
    _items = ShoppingItem.listFromJsonString(await _store.loadList());
    final theme = await _store.loadTheme();
    if (theme != null) {
      themeMode = switch (theme['mode']) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
      paletteIndex = (theme['palette'] as int? ?? 0) % appPalettes.length;
    }
    notifyListeners();
  }

  Future<void> _persist() =>
      _store.saveList(ShoppingItem.listToJsonString(_items));

  String _newId() =>
      '${DateTime.now().microsecondsSinceEpoch}-${_nextId++}';

  void add(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    _items = [..._items, ShoppingItem(id: _newId(), name: trimmed)];
    _persist();
    notifyListeners();
  }

  /// Ticked items go to the bottom. Unticked items rejoin the active section.
  void toggle(String id) {
    final index = _items.indexWhere((i) => i.id == id);
    if (index < 0) return;
    final updated = _items[index].copyWith(done: !_items[index].done);
    final list = [..._items]..removeAt(index);
    if (updated.done) {
      list.add(updated);
      _store.pushUndo(id);
    } else {
      final firstDone = list.indexWhere((i) => i.done);
      list.insert(firstDone < 0 ? list.length : firstDone, updated);
    }
    _items = list;
    _persist();
    notifyListeners();
  }

  void rename(String id, String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    _items = [
      for (final i in _items) i.id == id ? i.copyWith(name: trimmed) : i
    ];
    _persist();
    notifyListeners();
  }

  void remove(String id) {
    final index = _items.indexWhere((i) => i.id == id);
    if (index < 0) return;
    _lastRemoved = (_items[index], index);
    _items = [..._items]..removeAt(index);
    _persist();
    notifyListeners();
  }

  void undoRemove() {
    final removed = _lastRemoved;
    if (removed == null) return;
    _lastRemoved = null;
    final index = removed.$2.clamp(0, _items.length);
    _items = [..._items]..insert(index, removed.$1);
    _persist();
    notifyListeners();
  }

  /// [newIndex] is the destination after removal (onReorderItem semantics).
  void reorder(int oldIndex, int newIndex) {
    final list = [..._items];
    list.insert(newIndex, list.removeAt(oldIndex));
    _items = list;
    _persist();
    notifyListeners();
  }

  void clearDone() {
    _items = [for (final i in _items) if (!i.done) i];
    _persist();
    notifyListeners();
  }

  int get doneCount => _items.where((i) => i.done).length;

  Future<void> setThemeMode(ThemeMode mode) {
    themeMode = mode;
    notifyListeners();
    return _persistTheme();
  }

  Future<void> setPalette(int index) {
    paletteIndex = index % appPalettes.length;
    notifyListeners();
    return _persistTheme();
  }

  Future<void> _persistTheme() {
    final accent =
        ColorScheme.fromSeed(seedColor: palette.seed).primary.toARGB32();
    return _store.saveTheme(
      mode: switch (themeMode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      },
      palette: paletteIndex,
      accentArgb: accent,
    );
  }
}
