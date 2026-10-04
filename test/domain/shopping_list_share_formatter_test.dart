import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_list/domain/entities/shopping_item.dart';
import 'package:shopping_list/domain/services/shopping_list_share_formatter.dart';

void main() {
  const formatter = ShoppingListShareFormatter();

  group('ShoppingListShareFormatter', () {
    test('renders checked and unchecked boxes', () {
      final text = formatter.format(const <ShoppingItem>[
        ShoppingItem(id: 'a', name: 'Milk'),
        ShoppingItem(id: 'b', name: 'Eggs', done: true),
      ]);
      expect(text, 'Shopping list\n\n☐ Milk\n☑ Eggs');
    });

    test('empty list is just the title', () {
      expect(formatter.format(const <ShoppingItem>[]), 'Shopping list\n');
    });
  });
}
