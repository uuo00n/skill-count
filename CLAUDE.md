# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SkillCount is a Flutter landscape-only Pomodoro timer themed around WorldSkills 2026 Shanghai. It features competition countdown, module-based training timers with task management, world timezone display, white noise playback, and milestone tracking.

- **Dart SDK**: ^3.9.2
- **Orientation**: Landscape only (locked in `main.dart`)
- **Design**: Material 3 light theme, WorldSkills 2026 color palette

## Development Commands

```bash
flutter pub get                          # Install dependencies
flutter run -d macos                     # Run on macOS (also: chrome, windows, linux)
flutter test                             # Run all tests
flutter test test/widget_test.dart       # Run specific test
flutter analyze                          # Static analysis
```

## Architecture

### Entry Point

`main.dart` → initializes IANA timezone data, locks landscape orientation, wraps app in `ProviderScope`.
`app.dart` → `LocaleScope` (InheritedNotifier for i18n) wraps `MaterialApp` → `LandscapeScaffold`.

### Navigation

`LandscapeScaffold` (ConsumerStatefulWidget) is the app shell with a 5-tab bottom nav using `FadeIndexedStack`:

| Index | Page | Feature |
|-------|------|---------|
| 0 | CountdownPage | WorldSkills opening ceremony countdown |
| 1 | UnifiedTimerPage | Module timer with task management |
| 2 | TimezonePage | Multi-city timezone display |
| 3 | WhiteNoisePage | White noise audio player |
| 4 | SettingsPage | Language toggle + app info |

Header displays "SkillCount" logo, a per-page subtitle, live Shanghai time (from `unifiedTimeProvider`), and language toggle.

### State Management (Hybrid)

- **Riverpod** for global reactive state:
  - `unifiedTimeProvider` — `StateNotifierProvider<UnifiedTimeService, DateTime>`, single UTC clock ticking every second. All time-dependent widgets watch this.
  - `whiteNoiseServiceProvider` / `whiteNoisePlayingProvider` / `whiteNoiseVolumeProvider` — audio service and state.
- **InheritedNotifier** for i18n: `LocaleScope.of(context)` returns `AppStrings`, `LocaleScope.providerOf(context)` returns `LocaleProvider` for switching.
- **Local setState** for page-level transient UI state (selection, hover, tab index).

### Timer Architecture

```
BaseTimerController (abstract interface)
  └─ CompetitionTimer (core/timer/) — countDown/countUp modes, Timer.periodic(1s), Stream<Duration>
      └─ UnifiedTimerController (features/unified_timer/controllers/) — wraps CompetitionTimer,
         adds module/task selection, tracks actual time spent per task
```

### i18n

Manual dual-language system (no intl package):
- `strings.dart` — abstract `AppStrings` with all string getters
- `zh.dart` / `en.dart` — concrete implementations
- Add new strings to all three files when adding features

### Feature Directory Pattern

```
features/
  └─ [feature_name]/
      ├── [feature]_page.dart        # Main page widget
      ├── [feature]_service.dart     # Business logic (if needed)
      ├── [feature]_model.dart       # Data classes
      ├── controllers/               # Controller layer (if needed)
      └── widgets/                   # Sub-widgets, dialogs
```

### Key Directories

- `core/constants/` — `WsColors` (brand palette), `WsTimes` (competition dates in UTC)
- `core/providers/` — Riverpod providers (time, white noise)
- `core/timer/` — `BaseTimerController` + `CompetitionTimer` abstraction
- `core/theme/` — Material 3 theme (`AppTheme.light`)
- `widgets/` — Shared widgets: `GridBackground`, `GlassPanel`, `WsTimerText`, `FadeIndexedStack`, `CompetitionTimeline`

## Testing Requirements

Tests must:
1. Call `tz_data.initializeTimeZones()` in `setUpAll()`
2. Set landscape viewport: `tester.view.physicalSize = const Size(1920, 1080)`
3. Wrap in `ProviderScope(child: App())`
4. Clean up with `addTearDown(tester.view.resetPhysicalSize)`

## Code Conventions

- **Colors**: Use `WsColors.*` constants, never hardcode hex values. Use `.withAlpha()` not deprecated `.withOpacity()`.
- **Fonts**: Inter for UI text, JetBrainsMono for numeric displays (`fontFamily: 'JetBrainsMono'`).
- **String interpolation**: Use `$var` not `${var}` for simple variables (lint rule).
- **Imports**: Relative imports within `lib/`. Watch path depth from nested directories (e.g., `controllers/` → `../../../core/`).
- **Timezone**: Always store/compute in UTC, convert to display timezone via `TimezoneConverter.convert(utcDateTime, 'Asia/Shanghai')`.
- **Assets**: Images in `assets/images/`, audio in `assets/audio/`. Both registered in `pubspec.yaml`.
