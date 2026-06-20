import 'dart:convert';

class ShoppingItem {
  ShoppingItem({required this.id, required this.name, this.done = false});

  final String id;
  final String name;
  final bool done;

  ShoppingItem copyWith({String? name, bool? done}) =>
      ShoppingItem(id: id, name: name ?? this.name, done: done ?? this.done);

  Map<String, Object?> toJson() => {'id': id, 'name': name, 'done': done};

  factory ShoppingItem.fromJson(Map<String, Object?> json) => ShoppingItem(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        done: json['done'] as bool? ?? false,
      );

  static List<ShoppingItem> listFromJsonString(String? source) {
    if (source == null || source.isEmpty) return const [];
    try {
      final decoded = jsonDecode(source);
      final items = (decoded is Map ? decoded['items'] : decoded) as List?;
      if (items == null) return const [];
      return items
          .whereType<Map>()
          .map((e) => ShoppingItem.fromJson(e.cast<String, Object?>()))
          .where((e) => e.id.isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  static String listToJsonString(List<ShoppingItem> items) =>
      jsonEncode({'items': [for (final i in items) i.toJson()]});
}

/// Formats the list for sharing with checked and unchecked boxes.
String shareText(List<ShoppingItem> items, {String title = 'Shopping list'}) {
  final buffer = StringBuffer(title)..write('\n');
  for (final item in items) {
    buffer.write('\n${item.done ? '☑' : '☐'} ${item.name}');
  }
  return buffer.toString();
}
