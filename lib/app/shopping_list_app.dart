import 'package:flutter/material.dart';

import '../presentation/screens/home_screen.dart';
import '../presentation/theme/app_theme.dart';
import 'app_dependencies.dart';
import 'app_scope.dart';

class ShoppingListApp extends StatelessWidget {
  const ShoppingListApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    final settings = dependencies.settings;
    return AppScope(
      dependencies: dependencies,
      child: ListenableBuilder(
        listenable: settings,
        builder: (context, _) => MaterialApp(
          title: 'Shopping List',
          debugShowCheckedModeBanner: false,
          themeMode: settings.materialThemeMode,
          theme: buildAppTheme(settings.palette, Brightness.light),
          darkTheme: buildAppTheme(settings.palette, Brightness.dark),
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
