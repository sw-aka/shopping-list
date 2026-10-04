import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_list/data/models/shopping_item_mapper.dart';
import 'package:shopping_list/domain/entities/shopping_item.dart';

void main() {
  group('ShoppingItemMapper', () {
    test('round-trips a list', () {
      const items = <ShoppingItem>[
        ShoppingItem(id: 'a', name: 'Milk'),
        ShoppingItem(id: 'b', name: 'Eggs', done: true),
      ];
      final restored = ShoppingItemMapper.listFromJsonString(
        ShoppingItemMapper.listToJsonString(items),
      );
      expect(restored.length, 2);
      expect(restored[0].name, 'Milk');
      expect(restored[0].done, false);
      expect(restored[1].id, 'b');
      expect(restored[1].done, true);
    });

    test('wraps the list in an items object for the native store', () {
      final json = ShoppingItemMapper.listToJsonString(
        const <ShoppingItem>[ShoppingItem(id: 'a', name: 'Milk')],
      );
      expect(json, contains('"items"'));
    });

    test('handles null, empty and malformed input', () {
      expect(ShoppingItemMapper.listFromJsonString(null), isEmpty);
      expect(ShoppingItemMapper.listFromJsonString(''), isEmpty);
      expect(ShoppingItemMapper.listFromJsonString('not json'), isEmpty);
      expect(ShoppingItemMapper.listFromJsonString('{"items": 5}'), isEmpty);
    });

    test('drops entries without ids', () {
      final restored = ShoppingItemMapper.listFromJsonString(
        '{"items":[{"name":"ghost"},{"id":"x","name":"Bread"}]}',
      );
      expect(restored.length, 1);
      expect(restored.single.name, 'Bread');
    });
  });
}
