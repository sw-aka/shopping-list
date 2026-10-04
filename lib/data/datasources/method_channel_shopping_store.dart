import 'package:flutter/services.dart';

import 'shopping_store_data_source.dart';

class MethodChannelShoppingStore implements ShoppingStoreDataSource {
  MethodChannelShoppingStore({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel(channelName);

  static const String channelName = 'shopping_list/store';

  final MethodChannel _channel;

  @override
  Future<String?> loadListJson() => _channel.invokeMethod<String>('loadList');

  /// Saving also refreshes the home-screen widgets.
  @override
  Future<void> saveListJson(String json) =>
      _channel.invokeMethod<void>('saveList', <String, Object?>{'json': json});

  /// Keys are mode (system|light|dark) and palette (int).
  @override
  Future<Map<Object?, Object?>?> loadTheme() =>
      _channel.invokeMethod<Map<Object?, Object?>>('loadTheme');

  /// [accentArgb] lets the widget match the in-app palette.
  @override
  Future<void> saveTheme({
    required String mode,
    required int palette,
    required int accentArgb,
  }) =>
      _channel.invokeMethod<void>('saveTheme', <String, Object?>{
        'mode': mode,
        'palette': palette,
        'accent': accentArgb,
      });

  /// Adds a tick to the widget's undo history.
  @override
  Future<void> pushUndo(String id) =>
      _channel.invokeMethod<void>('pushUndo', <String, Object?>{'id': id});

  /// Returns and clears a pending launch_action intent extra.
  @override
  Future<String?> takeLaunchAction() =>
      _channel.invokeMethod<String>('takeLaunchAction');
}
