# Shopping List

A small offline shopping list app for Android, built with Flutter and Material 3.

## Features

- Add, tick, reorder, and remove items. Removed items can be restored with undo.
- Share the list as text with checked and unchecked boxes.
- Choose from six colour palettes and light, dark, or system mode.
- Use a resizable home-screen widget. Ticking an item hides it; the header can undo up to three recent ticks.
- The widget's plus button opens a small native add field over the home screen without opening the Flutter screen.
- The release APK requests no Android system permissions. The build workflow checks the release APK for system permission requests.

## Storage

The list and theme settings live in one Android SharedPreferences file. Flutter reads and writes it through a MethodChannel, and the home-screen widget uses the same file.

## Building

```sh
flutter pub get
flutter test
flutter build apk --release
```

The APK is signed with debug keys. To build it in GitHub Actions, run the Build release APK workflow. It publishes `shopping-list-build-<run number>.apk` on the Releases page under a `build-<run number>` tag.
