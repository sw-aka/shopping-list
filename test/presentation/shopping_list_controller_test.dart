import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_list/data/repositories/shopping_list_repository_impl.dart';
import 'package:shopping_list/presentation/controllers/shopping_list_controller.dart';

import '../support/fakes.dart';

void main() {
  group('ShoppingListController', () {
    test('add trims names and ignores blanks', () async {
      final controller = ShoppingListController(FakeShoppingListRepository());
      await controller.add('Milk');
      await controller.add('  Eggs  ');
      await controller.add('   ');
      expect(controller.items.map((i) => i.name), ['Milk', 'Eggs']);
    });

    test('ticking moves an item to the bottom and records undo', () async {
      final repository = FakeShoppingListRepository();
      final controller = ShoppingListController(repository);
      await controller.add('Milk');
      await controller.add('Eggs');

      await controller.toggle(controller.items.first.id);
      expect(controller.doneCount, 1);
      expect(controller.items.map((i) => i.name), ['Eggs', 'Milk']);
      expect(controller.items.last.done, true);
      expect(repository.undoIds, [controller.items.last.id]);
    });

    test('unticking rejoins the active section above done items', () async {
      final controller = ShoppingListController(FakeShoppingListRepository());
      for (final name in ['A', 'B', 'C', 'D']) {
        await controller.add(name);
      }
      String idOf(String name) =>
          controller.items.firstWhere((i) => i.name == name).id;

      await controller.toggle(idOf('B'));
      await controller.toggle(idOf('A'));
      expect(controller.items.map((i) => i.name), ['C', 'D', 'B', 'A']);

      await controller.toggle(idOf('B'));
      expect(controller.items.map((i) => i.name), ['C', 'D', 'B', 'A']);
      expect(controller.items.map((i) => i.done), [false, false, false, true]);
    });

    test('remove then undo restores the item and its position', () async {
      final controller = ShoppingListController(FakeShoppingListRepository());
      await controller.add('Milk');
      await controller.add('Eggs');
      await controller.toggle(controller.items.first.id);

      final removed = controller.items.last;
      await controller.remove(removed.id);
      expect(controller.items.length, 1);

      await controller.undoRemove();
      expect(controller.items.length, 2);
      expect(controller.items.last.name, 'Milk');
      expect(controller.items.last.done, true);
    });

    test('reorder moves an item down and back up', () async {
      final controller = ShoppingListController(FakeShoppingListRepository());
      await controller.add('A');
      await controller.add('B');
      await controller.add('C');

      await controller.reorder(0, 2);
      expect(controller.items.map((i) => i.name), ['B', 'C', 'A']);

      await controller.reorder(2, 0);
      expect(controller.items.map((i) => i.name), ['A', 'B', 'C']);
    });

    test('clearDone keeps only unticked items', () async {
      final controller = ShoppingListController(FakeShoppingListRepository());
      await controller.add('A');
      await controller.add('B');
      await controller.toggle(controller.items.first.id);
      await controller.clearDone();
      expect(controller.items.map((i) => i.name), ['B']);
    });

    test('consumes a pending launch action exactly once', () async {
      final repository = FakeShoppingListRepository()..launchAction = 'add';
      final controller = ShoppingListController(repository);
      expect(await controller.consumeLaunchAction(), 'add');
      expect(await controller.consumeLaunchAction(), isNull);
    });

    test('a load failure is captured instead of thrown', () async {
      final repository = FakeShoppingListRepository()
        ..loadError = StateError('boom');
      final controller = ShoppingListController(repository);
      await controller.load();
      expect(controller.items, isEmpty);
      expect(controller.lastError, isA<StateError>());
    });

    test('state persists and reloads through the repository', () async {
      final store = FakeShoppingStore();
      final controller = ShoppingListController(
        ShoppingListRepositoryImpl(store),
      );
      await controller.add('Milk');
      await controller.toggle(controller.items.first.id);

      final reloaded = ShoppingListController(ShoppingListRepositoryImpl(store));
      await reloaded.load();
      expect(reloaded.items.single.name, 'Milk');
      expect(reloaded.items.single.done, true);
    });
  });
}
