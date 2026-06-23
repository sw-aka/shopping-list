import 'package:flutter/material.dart';

import 'models/app_state.dart';
import 'screens/home_screen.dart';
import 'services/store.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final state = AppState(Store());
  state.load();
  runApp(ShoppingListApp(state: state));
}

class ShoppingListApp extends StatelessWidget {
  const ShoppingListApp({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) => MaterialApp(
        title: 'Shopping List',
        debugShowCheckedModeBanner: false,
        themeMode: state.themeMode,
        theme: buildTheme(state.palette, Brightness.light),
        darkTheme: buildTheme(state.palette, Brightness.dark),
        home: HomeScreen(state: state),
      ),
    );
  }
}
