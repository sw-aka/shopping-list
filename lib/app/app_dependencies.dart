import '../data/datasources/method_channel_shopping_store.dart';
import '../data/datasources/shopping_store_data_source.dart';
import '../data/repositories/shopping_list_repository_impl.dart';
import '../data/repositories/settings_repository_impl.dart';
import '../domain/repositories/shopping_list_repository.dart';
import '../domain/repositories/settings_repository.dart';
import '../domain/services/shopping_list_share_formatter.dart';
import '../presentation/controllers/settings_controller.dart';
import '../presentation/controllers/shopping_list_controller.dart';

/// Builds the object graph once; nothing below this constructs its own
/// dependencies.
class AppDependencies {
  AppDependencies._({
    required this.shoppingList,
    required this.settings,
    required this.shareFormatter,
  });

  factory AppDependencies.create({ShoppingStoreDataSource? store}) {
    final ShoppingStoreDataSource dataSource =
        store ?? MethodChannelShoppingStore();
    final ShoppingListRepository listRepository =
        ShoppingListRepositoryImpl(dataSource);
    final SettingsRepository settingsRepository =
        SettingsRepositoryImpl(dataSource);
    return AppDependencies._(
      shoppingList: ShoppingListController(listRepository),
      settings: SettingsController(settingsRepository),
      shareFormatter: const ShoppingListShareFormatter(),
    );
  }

  final ShoppingListController shoppingList;
  final SettingsController settings;
  final ShoppingListShareFormatter shareFormatter;

  Future<void> initialize() => Future.wait<void>(<Future<void>>[
        shoppingList.load(),
        settings.load(),
      ]);
}
