import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_list/app/app_dependencies.dart';
import 'package:shopping_list/app/shopping_list_app.dart';
import 'package:shopping_list/data/models/shopping_item_mapper.dart';
import 'package:shopping_list/domain/entities/shopping_item.dart';

import '../support/fakes.dart';

Future<void> _pumpApp(WidgetTester tester, FakeShoppingStore store) async {
  final dependencies = AppDependencies.create(store: store);
  await dependencies.initialize();
  await tester.pumpWidget(ShoppingListApp(dependencies: dependencies));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the empty state when the list is empty', (tester) async {
    await _pumpApp(tester, FakeShoppingStore());
    expect(find.text('Shopping'), findsOneWidget);
    expect(find.text('Nothing to buy yet'), findsOneWidget);
  });

  testWidgets('renders stored items and their progress', (tester) async {
    final store = FakeShoppingStore()
      ..listJson = ShoppingItemMapper.listToJsonString(const <ShoppingItem>[
        ShoppingItem(id: 'a', name: 'Milk'),
        ShoppingItem(id: 'b', name: 'Eggs', done: true),
      ]);
    await _pumpApp(tester, store);
    expect(find.text('Milk'), findsOneWidget);
    expect(find.text('Eggs'), findsOneWidget);
    expect(find.text('1 of 2 done'), findsOneWidget);
  });

  testWidgets('adding an item through the sheet updates the list',
      (tester) async {
    final store = FakeShoppingStore();
    await _pumpApp(tester, store);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Bread');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('Bread'), findsWidgets);
    expect(store.listJson, contains('Bread'));
  });
}
