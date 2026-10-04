import 'package:shopping_list/data/datasources/shopping_store_data_source.dart';
import 'package:shopping_list/domain/entities/shopping_item.dart';
import 'package:shopping_list/domain/entities/theme_settings.dart';
import 'package:shopping_list/domain/repositories/shopping_list_repository.dart';
import 'package:shopping_list/domain/repositories/settings_repository.dart';

/// In-memory stand-in for the native store.
class FakeShoppingStore implements ShoppingStoreDataSource {
  String? listJson;
  Map<Object?, Object?>? theme;
  String? launchAction;
  Object? saveError;

  final List<String> savedListJson = <String>[];
  final List<String> undoIds = <String>[];
  final List<Map<Object?, Object?>> savedThemes = <Map<Object?, Object?>>[];

  @override
  Future<String?> loadListJson() async => listJson;

  @override
  Future<void> saveListJson(String json) async {
    if (saveError != null) throw saveError!;
    listJson = json;
    savedListJson.add(json);
  }

  @override
  Future<Map<Object?, Object?>?> loadTheme() async => theme;

  @override
  Future<void> saveTheme({
    required String mode,
    required int palette,
    required int accentArgb,
  }) async {
    final map = <Object?, Object?>{
      'mode': mode,
      'palette': palette,
      'accent': accentArgb,
    };
    theme = map;
    savedThemes.add(map);
  }

  @override
  Future<void> pushUndo(String id) async => undoIds.insert(0, id);

  @override
  Future<String?> takeLaunchAction() async {
    final String? action = launchAction;
    launchAction = null;
    return action;
  }
}

/// In-memory stand-in for the list repository.
class FakeShoppingListRepository implements ShoppingListRepository {
  FakeShoppingListRepository([List<ShoppingItem>? initial])
      : _items = <ShoppingItem>[...?initial];

  List<ShoppingItem> _items;
  Object? loadError;
  String? launchAction;

  final List<List<ShoppingItem>> saves = <List<ShoppingItem>>[];
  final List<String> undoIds = <String>[];

  @override
  Future<List<ShoppingItem>> load() async {
    if (loadError != null) throw loadError!;
    return List<ShoppingItem>.unmodifiable(_items);
  }

  @override
  Future<void> save(List<ShoppingItem> items) async {
    _items = <ShoppingItem>[...items];
    saves.add(List<ShoppingItem>.unmodifiable(items));
  }

  @override
  Future<void> pushUndo(String id) async => undoIds.insert(0, id);

  @override
  Future<String?> consumeLaunchAction() async {
    final String? action = launchAction;
    launchAction = null;
    return action;
  }
}

/// In-memory stand-in for the settings repository.
class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository([this._settings = const ThemeSettings()]);

  ThemeSettings _settings;
  Object? loadError;
  final List<ThemeSettings> saves = <ThemeSettings>[];

  @override
  Future<ThemeSettings> load() async {
    if (loadError != null) throw loadError!;
    return _settings;
  }

  @override
  Future<void> save(ThemeSettings settings) async {
    _settings = settings;
    saves.add(settings);
  }
}
