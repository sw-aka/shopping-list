import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_list/models/app_state.dart';
import 'package:shopping_list/services/store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('shopping_list/store');
  final saved = <String, Object?>{};

  setUp(() {
    saved.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      switch (call.method) {
        case 'loadList':
          return saved['list'];
        case 'saveList':
          saved['list'] = (call.arguments as Map)['json'];
          return null;
        case 'loadTheme':
          return saved['theme'];
        case 'saveTheme':
          saved['theme'] = Map<Object?, Object?>.from(call.arguments as Map);
          return null;
        case 'pushUndo':
        case 'takeLaunchAction':
          return null;
      }
      return null;
    });
  });

  AppState newState() => AppState(Store());

  test('add, toggle, remove, undo', () async {
    final state = newState();
    state.add('Milk');
    state.add('  Eggs  ');
    state.add('   ');
    expect(state.items.map((i) => i.name), ['Milk', 'Eggs']);

    state.toggle(state.items.first.id);
    expect(state.doneCount, 1);
    expect(state.items.map((i) => i.name), ['Eggs', 'Milk']);
    expect(state.items.last.done, true);

    final removedId = state.items.last.id;
    state.remove(removedId);
    expect(state.items.length, 1);

    state.undoRemove();
    expect(state.items.length, 2);
    expect(state.items.last.name, 'Milk');
    expect(state.items.last.done, true);
  });

  test('ticking moves to bottom, unticking rejoins active section', () async {
    final state = newState();
    for (final name in ['A', 'B', 'C', 'D']) {
      state.add(name);
    }
    String idOf(String name) =>
        state.items.firstWhere((i) => i.name == name).id;

    state.toggle(idOf('B'));
    state.toggle(idOf('A'));
    expect(state.items.map((i) => i.name), ['C', 'D', 'B', 'A']);

    state.toggle(idOf('B'));
    expect(state.items.map((i) => i.name), ['C', 'D', 'B', 'A']);
    expect(state.items.map((i) => i.done), [false, false, false, true]);
  });

  test('reorder moves item down and up', () async {
    final state = newState();
    state.add('A');
    state.add('B');
    state.add('C');

    state.reorder(0, 2);
    expect(state.items.map((i) => i.name), ['B', 'C', 'A']);

    state.reorder(2, 0);
    expect(state.items.map((i) => i.name), ['A', 'B', 'C']);
  });

  test('clearDone keeps only unticked items', () async {
    final state = newState();
    state.add('A');
    state.add('B');
    state.toggle(state.items.first.id);
    state.clearDone();
    expect(state.items.map((i) => i.name), ['B']);
  });

  test('state persists and reloads through the store', () async {
    final state = newState();
    state.add('Milk');
    state.toggle(state.items.first.id);
    // Let pending writes reach the mock channel.
    await Future<void>.delayed(Duration.zero);

    final reloaded = newState();
    await reloaded.load();
    expect(reloaded.items.single.name, 'Milk');
    expect(reloaded.items.single.done, true);
  });

  test('theme settings persist accent colour for the widget', () async {
    final state = newState();
    await state.setPalette(2);
    final theme = saved['theme'] as Map?;
    expect(theme, isNotNull);
    expect(theme!['palette'], 2);
    expect(theme['accent'], isA<int>());
    expect(theme['mode'], 'system');
  });
}
