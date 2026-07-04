import 'package:flutter/services.dart';

/// Native storage shared with the home-screen widget.
class Store {
  static const _channel = MethodChannel('shopping_list/store');

  Future<String?> loadList() async =>
      await _channel.invokeMethod<String>('loadList');

  /// Saving also refreshes the home-screen widgets.
  Future<void> saveList(String json) =>
      _channel.invokeMethod('saveList', {'json': json});

  /// Keys are mode (system|light|dark) and palette (int).
  Future<Map<Object?, Object?>?> loadTheme() async =>
      await _channel.invokeMethod<Map<Object?, Object?>>('loadTheme');

  /// [accentArgb] lets the widget match the in-app palette.
  Future<void> saveTheme(
          {required String mode,
          required int palette,
          required int accentArgb}) =>
      _channel.invokeMethod('saveTheme',
          {'mode': mode, 'palette': palette, 'accent': accentArgb});

  /// Adds a tick to the widget's undo history.
  Future<void> pushUndo(String id) =>
      _channel.invokeMethod('pushUndo', {'id': id});

  /// Returns and clears a pending launch_action intent extra.
  Future<String?> takeLaunchAction() async =>
      await _channel.invokeMethod<String>('takeLaunchAction');
}
