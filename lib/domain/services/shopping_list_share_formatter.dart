import '../entities/shopping_item.dart';

class ShoppingListShareFormatter {
  const ShoppingListShareFormatter();

  /// Formats the list for sharing with checked and unchecked boxes.
  String format(List<ShoppingItem> items, {String title = 'Shopping list'}) {
    final buffer = StringBuffer(title)..write('\n');
    for (final item in items) {
      buffer.write('\n${item.done ? '☑' : '☐'} ${item.name}');
    }
    return buffer.toString();
  }
}
