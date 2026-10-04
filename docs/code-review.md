# Code review — shopping-list

A review of the Flutter app, carried out on a branch. Nothing here was applied
to `main`.

## Result

| Check | Before | After |
| --- | --- | --- |
| `flutter analyze` | No issues found | No issues found |
| `flutter test` | 11 passed | 27 passed |

Toolchain: Flutter 3.44.5 / Dart 3.12.2, the versions the CI workflow pins.

## Changes

1. **Layering and dependency injection.** `lib` is split into `domain`,
   `data` and `presentation`, with repository contracts and a single
   composition root (`lib/app/app_dependencies.dart`). No widget constructs its
   own dependencies.

2. **Out-of-order writes.** `saveList` was fired on every mutation without
   being awaited, and each write sends the whole list, so two quick edits could
   reach the native store in either order. Writes are now chained in
   `ShoppingListRepositoryImpl`.

3. **Initial load.** `main()` now awaits `AppDependencies.initialize()` before
   `runApp`, so the first frame never shows an empty list.

4. **Platform errors.** `MethodChannel` failures are caught in the controllers
   and surfaced through `lastError` instead of escaping into the widget tree.

5. **Encapsulation.** `themeMode` and `paletteIndex` are private fields with
   getters on `SettingsController`.

6. **Dead code.** `ListRemoteViewsFactory` only ever receives active items, so
   the `done` branch in `getViewAt` could not run. Removed, with its unused
   imports.

7. **CI.** The build check now also runs on pull requests.

## Checked, no change needed

- The Kotlin Gradle plugin is applied by the Flutter Gradle plugin when a
  module uses AGP but not KGP, so `settings.gradle.kts` is correct as it is.
- `android:exported="false"` on the widget receiver is correct: a non-exported
  receiver still receives the system's AppWidget broadcasts.
- `apply()` in `Prefs` is safe because the app and the widget share a process.
