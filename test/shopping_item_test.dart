import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_list/models/shopping_item.dart';

void main() {
  group('ShoppingItem json', () {
    test('round-trips a list', () {
      final items = [
        ShoppingItem(id: 'a', name: 'Milk'),
        ShoppingItem(id: 'b', name: 'Eggs', done: true),
      ];
      final restored =
          ShoppingItem.listFromJsonString(ShoppingItem.listToJsonString(items));
      expect(restored.length, 2);
      expect(restored[0].name, 'Milk');
      expect(restored[0].done, false);
      expect(restored[1].id, 'b');
      expect(restored[1].done, true);
    });

    test('handles null, empty and malformed input', () {
      expect(ShoppingItem.listFromJsonString(null), isEmpty);
      expect(ShoppingItem.listFromJsonString(''), isEmpty);
      expect(ShoppingItem.listFromJsonString('not json'), isEmpty);
      expect(ShoppingItem.listFromJsonString('{"items": 5}'), isEmpty);
    });

    test('drops entries without ids', () {
      final restored = ShoppingItem.listFromJsonString(
          '{"items":[{"name":"ghost"},{"id":"x","name":"Bread"}]}');
      expect(restored.length, 1);
      expect(restored.single.name, 'Bread');
    });
  });

  group('shareText', () {
    test('renders checked and unchecked boxes', () {
      final text = shareText([
        ShoppingItem(id: 'a', name: 'Milk'),
        ShoppingItem(id: 'b', name: 'Eggs', done: true),
      ]);
      expect(text, 'Shopping list\n\n☐ Milk\n☑ Eggs');
    });

    test('empty list is just the title', () {
      expect(shareText(const []), 'Shopping list\n');
    });
  });
}
