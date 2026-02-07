# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Flutter** application - a Pomodoro timer themed around the WorldSkills Competition. It targets multiple platforms (iOS, Android, Windows, macOS, Linux, Web) using Flutter's cross-platform framework.

**Key Details:**
- Language: Dart
- SDK requirement: Dart SDK ^3.9.2
- Status: Starter template (basic counter app)
- Not published to pub.dev (private package)

## Development Commands

### Setup & Dependencies
```bash
flutter pub get                 # Install dependencies
flutter pub upgrade             # Upgrade dependencies to latest versions
```

### Running the App
```bash
flutter run                     # Run on connected device/emulator
flutter run -d chrome           # Run on web (if web is set up)
flutter run -d linux            # Run on Linux
flutter run -d windows          # Run on Windows
flutter run -d macos            # Run on macOS
```

### Testing
```bash
flutter test                    # Run all tests
flutter test test/widget_test.dart  # Run a specific test file
flutter test --verbose          # Run tests with detailed output
```

### Code Quality
```bash
flutter analyze                 # Run static analysis on the code
flutter format lib/             # Format Dart code (lib directory)
flutter format --line-length=80 lib/  # Format with custom line length
```

### Building
```bash
flutter build apk               # Build Android APK
flutter build ios               # Build iOS app
flutter build web               # Build web version
flutter build windows           # Build Windows app
flutter build linux             # Build Linux app
flutter build macos             # Build macOS app
```

### Hot Reload Development
- Press `r` in the console while `flutter run` is active to hot reload (preserves app state)
- Press `R` to perform a hot restart (resets app state)
- Hot reload is useful for quick iteration on UI and non-state changes

## Project Structure

- **lib/main.dart**: Entry point of the application. Currently contains:
  - `MyApp`: Root widget with Material Design theming
  - `MyHomePage`: Stateful widget serving as the home page
  - `_MyHomePageState`: State class managing the counter

- **test/widget_test.dart**: Widget tests for the application (uses Flutter's `flutter_test` package)

- **pubspec.yaml**: Project configuration, dependencies, and app metadata

- **analysis_options.yaml**: Linter rules for code analysis (uses `flutter_lints` package with recommended rules)

- **Platform-specific directories**: `android/`, `ios/`, `windows/`, `macos/`, `linux/`, `web/` contain platform-specific configurations and native code

## Architecture Notes

The project currently uses a basic Flutter architecture:
- **Material Design**: Theme colors use a seed-based color scheme (currently deep purple)
- **State Management**: Simple local state via `setState()` - suitable for small apps, but consider Provider, Riverpod, or BLoC for larger applications
- **Widget Hierarchy**: Single widget tree with stateless root and stateful home page

## Linting & Code Standards

- Uses `flutter_lints` package with standard Flutter recommendations
- Run `flutter analyze` to check for linting issues
- Common lints can be suppressed with `// ignore: lint_name` comments

## Testing

Tests are located in the `test/` directory and use Flutter's `flutter_test` package. The example test (`widget_test.dart`) demonstrates basic widget testing patterns:
- Use `WidgetTester` to simulate user interactions
- `tester.pump()` triggers a frame rebuild
- `find` helpers to locate widgets in the widget tree
- `expect()` for assertions
