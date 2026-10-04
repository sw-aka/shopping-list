import 'dart:convert';

import '../../domain/entities/shopping_item.dart';

/// The stored shape is `{"items": [...]}` so the widget can read it with org.json.
abstract final class ShoppingItemMapper {
  static List<ShoppingItem> listFromJsonString(String? source) {
    if (source == null || source.isEmpty) return const <ShoppingItem>[];
    try {
      final Object? decoded = jsonDecode(source);
      final Object? raw = decoded is Map ? decoded['items'] : decoded;
      if (raw is! List) return const <ShoppingItem>[];
      return raw
          .whereType<Map<Object?, Object?>>()
          .map(_fromMap)
          .where((item) => item.id.isNotEmpty)
          .toList(growable: false);
    } catch (_) {
      return const <ShoppingItem>[];
    }
  }

  static String listToJsonString(List<ShoppingItem> items) =>
      jsonEncode(<String, Object?>{
        'items': <Map<String, Object?>>[
          for (final item in items) _toMap(item),
        ],
      });

  static ShoppingItem _fromMap(Map<Object?, Object?> json) => ShoppingItem(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        done: json['done'] as bool? ?? false,
      );

  static Map<String, Object?> _toMap(ShoppingItem item) => <String, Object?>{
        'id': item.id,
        'name': item.name,
        'done': item.done,
      };
}
