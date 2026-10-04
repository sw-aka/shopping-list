import 'package:flutter/widgets.dart';

import 'app/app_dependencies.dart';
import 'app/shopping_list_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final AppDependencies dependencies = AppDependencies.create();
  await dependencies.initialize();
  runApp(ShoppingListApp(dependencies: dependencies));
}
