/// Native storage shared with the home-screen widget.
abstract interface class ShoppingStoreDataSource {
  Future<String?> loadListJson();

  Future<void> saveListJson(String json);

  Future<Map<Object?, Object?>?> loadTheme();

  Future<void> saveTheme({
    required String mode,
    required int palette,
    required int accentArgb,
  });

  Future<void> pushUndo(String id);

  Future<String?> takeLaunchAction();
}
