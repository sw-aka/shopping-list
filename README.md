# Shopping List

A small offline shopping list app for Android, built with Flutter and Material 3.

## Features

- Add, tick, reorder, and remove items. Removed items can be restored with undo.
- Share the list as text with checked and unchecked boxes.
- Choose from six colour palettes and light, dark, or system mode.
- Use a resizable home-screen widget to tick items off and move them up or down.
- The widget's plus button opens the app's add sheet.
- The release APK requests no Android system permissions. The build workflow checks the release APK for system permission requests.

## Storage

The list and theme settings live in one Android SharedPreferences file. Flutter reads and writes it through a MethodChannel, and the home-screen widget uses the same file.

## Building

```sh
flutter pub get
flutter test
flutter build apk --release
```

The APK is signed with debug keys. To build it in GitHub Actions, run the Build release APK workflow and download the APK from the run's artifacts.
