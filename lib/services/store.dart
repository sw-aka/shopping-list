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

  /// Returns and clears a pending launch action, e.g. 'add' when the user
  /// tapped the + button on the widget.
  Future<String?> takeLaunchAction() async =>
      await _channel.invokeMethod<String>('takeLaunchAction');
}
