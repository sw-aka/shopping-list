# Shopping List

A small offline shopping list app for Android, built with Flutter and Material 3.

## Features

- Add, tick, reorder, and remove items. Removed items can be restored with undo.
- Share the list as text with checked and unchecked boxes.
- Choose from six colour palettes and light, dark, or system mode.
- Use a resizable home-screen widget. Ticking an item hides it; the header can undo up to three recent ticks.
- The widget's plus button opens a small native add field over the home screen without opening the Flutter screen.
- The app requests no Android system permissions.

## Architecture

The Dart code is split into three layers, with dependencies pointing inwards:

- `lib/domain` — entities (`ShoppingItem`, `ThemeSettings`), repository
  contracts and the share-text formatter. No Flutter or platform imports.
- `lib/data` — the MethodChannel data source, JSON mapping and repository
  implementations. This is the only layer that knows about the native store.
- `lib/presentation` — `ChangeNotifier` controllers, screens, widgets and the
  Material theme.

The object graph is wired once in `lib/app/app_dependencies.dart` (composition
root) and shared through an `AppScope` inherited widget, so no widget builds
its own dependencies and every layer can be tested in isolation.

## Storage

The list and theme settings live in one Android SharedPreferences file. Flutter reads and writes it through a MethodChannel, and the home-screen widget uses the same file.

## Building

```sh
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

## Licence

GNU Affero General Public License v3.0. See [LICENSE](LICENSE).
