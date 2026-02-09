# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SkillCount is a Flutter landscape-only training timer themed around WorldSkills 2026 Shanghai. It features competition countdown, module-based training timers with task management, practice history with AI-powered analysis, world timezone display, white noise playback, and settings.

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

`main.dart` → initializes IANA timezone data, loads `.env` (via flutter_dotenv), locks landscape orientation, wraps app in `ProviderScope`.
`app.dart` → `LocaleScope` (InheritedNotifier for i18n) wraps `MaterialApp` → `LandscapeScaffold`.

### Navigation

`LandscapeScaffold` (ConsumerStatefulWidget) is the app shell with a 6-tab bottom nav using `FadeIndexedStack`:

| Index | Page | Feature |
|-------|------|---------|
| 0 | CountdownPage | WorldSkills opening ceremony countdown |
| 1 | UnifiedTimerPage | Module timer with task management |
| 2 | PracticeHistoryPage | Practice records, analytics charts, AI analysis (3 sub-tabs) |
| 3 | TimezonePage | Multi-city timezone display (grid background hidden) |
| 4 | WhiteNoisePage | White noise audio player |
| 5 | SettingsPage | Language toggle, timezone selector, countdown target, app info |

Header displays "SkillCount" logo, a per-page subtitle, live clock in user-selected timezone (from `appTimezoneProvider`), and language badge.

### State Management (Hybrid)

- **Riverpod** for global reactive state:
  - `unifiedTimeProvider` — `StateNotifierProvider<UnifiedTimeService, DateTime>`, single UTC clock ticking every second.
  - `appTimezoneProvider` — `StateProvider<String>`, user-selected IANA timezone for header clock display.
  - `practiceRecordsProvider` / `practiceStatisticsProvider` — practice history data.
  - `aiAnalysisProvider` — `StateNotifierProvider<AIAnalysisNotifier, AIAnalysisState>`, manages AI analysis lifecycle (idle/loading/success/error).
  - `aiChatProvider` — `StateNotifierProvider<AIChatNotifier, AIChatState>`, streaming AI chat.
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

### AI Analysis Architecture

```
AIService (abstract interface — core/ai/ai_service_interface.dart)
  ├─ VolcengineAIService — Volcengine/ByteDance API (Function Calling + Streaming)
  └─ DifyAIService — Dify LLM platform (reserved for future)
```

- **Configuration**: `.env` file with `VOLCENGINE_API_KEY`, `VOLCENGINE_MODEL`, `AI_ENGINE` selector
- **Prompts**: `core/ai/prompts/training_analysis_prompt.dart` — formats PracticeRecord data for AI analysis
- **Models**: `core/ai/ai_models.dart` — AIAnalysisResult, TrainingRecommendation, ChatMessage, etc.
- **Providers**: `core/ai/ai_providers.dart` — AIAnalysisNotifier (StateNotifier) + AIChatNotifier (streaming)
- **UI**: `features/practice_history/widgets/ai_analysis_panel.dart` — 3rd tab in PracticeHistoryPage

### i18n

Manual multi-language system (no intl package) with 8 languages:
- `strings.dart` — abstract `AppStrings` with all string getters
- `zh.dart` / `en.dart` / `zh_tw.dart` / `ja.dart` / `ko.dart` / `de.dart` / `fr.dart` — concrete implementations
- Add new strings to `strings.dart` (abstract getter) **and all 7 language files** when adding features

### Feature Directory Pattern

```
features/
  └─ [feature_name]/
      ├── [feature]_page.dart        # Main page widget
      ├── [feature]_service.dart     # Business logic (if needed)
      ├── models/                    # Data classes
      ├── controllers/               # Controller layer (if needed)
      └── widgets/                   # Sub-widgets, dialogs
```

### Key Directories

- `core/ai/` — AI service abstraction, Volcengine/Dify implementations, prompts, providers
- `core/constants/` — `WsColors` (brand palette), `WsTimes` (competition dates in UTC)
- `core/providers/` — Riverpod providers (time, white noise, practice history)
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
- **Imports**: Relative imports within `lib/`. Watch path depth from nested directories (e.g., `core/ai/prompts/` → `../../../features/...` for 3 levels up to `lib/`).
- **Timezone**: Always store/compute in UTC, convert to display timezone via `TimezoneConverter.convert(utcDateTime, timezoneId)`. User-selected timezone is in `appTimezoneProvider`.
- **Assets**: Images in `assets/images/`, audio in `assets/audio/`. Both registered in `pubspec.yaml`.
- **Environment**: AI API keys and config in `.env` (loaded via flutter_dotenv). `.env` is in `.gitignore`.
- **JSON serialization**: Manual `toJson()`/`fromJson()` factory constructors (no code generation).
