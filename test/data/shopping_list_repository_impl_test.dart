import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_list/data/repositories/shopping_list_repository_impl.dart';
import 'package:shopping_list/domain/entities/shopping_item.dart';

import '../support/fakes.dart';

void main() {
  group('ShoppingListRepositoryImpl', () {
    test('load returns an empty list when nothing is stored', () async {
      final repository = ShoppingListRepositoryImpl(FakeShoppingStore());
      expect(await repository.load(), isEmpty);
    });

    test('save then load round-trips through the store', () async {
      final store = FakeShoppingStore();
      final repository = ShoppingListRepositoryImpl(store);

      await repository.save(const <ShoppingItem>[
        ShoppingItem(id: 'a', name: 'Milk'),
      ]);
      expect(store.savedListJson.single, contains('"Milk"'));

      final loaded = await repository.load();
      expect(loaded.single.name, 'Milk');
    });

    test('writes reach the store in the order they were scheduled', () async {
      final store = FakeShoppingStore();
      final repository = ShoppingListRepositoryImpl(store);

      // Fire without awaiting: the queue must still serialise them.
      final first = repository.save(
        const <ShoppingItem>[ShoppingItem(id: 'a', name: 'First')],
      );
      final second = repository.save(
        const <ShoppingItem>[ShoppingItem(id: 'b', name: 'Second')],
      );
      await Future.wait(<Future<void>>[first, second]);

      expect(store.savedListJson.length, 2);
      expect(store.savedListJson.first, contains('First'));
      expect(store.savedListJson.last, contains('Second'));
      expect(store.listJson, contains('Second'));
    });

    test('a failed write surfaces but does not stall the queue', () async {
      final store = FakeShoppingStore()..saveError = StateError('disk');
      final repository = ShoppingListRepositoryImpl(store);

      await expectLater(
        repository.save(
          const <ShoppingItem>[ShoppingItem(id: 'a', name: 'A')],
        ),
        throwsA(isA<StateError>()),
      );

      store.saveError = null;
      await repository.save(
        const <ShoppingItem>[ShoppingItem(id: 'b', name: 'B')],
      );
      expect(store.listJson, contains('B'));
    });

    test('pushUndo forwards the id to the store', () async {
      final store = FakeShoppingStore();
      final repository = ShoppingListRepositoryImpl(store);
      await repository.pushUndo('a');
      expect(store.undoIds, ['a']);
    });
  });
}
