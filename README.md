# SkillCount - WorldSkills Pomodoro Timer

[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20Web%20%7C%20Windows%20%7C%20macOS%20%7C%20Linux-lightgrey.svg)](https://flutter.dev/multi-platform)

A professional Pomodoro timer application themed around the WorldSkills Competition, designed to help participants and teams prepare effectively for international skill competitions. The application features a modern, clean UI optimized for landscape usage on desktop and tablet devices.

## Features

### Core Timer Functionality
- **Competition Countdown** - Real-time countdown to WorldSkills 2026 opening ceremony
- **Pomodoro Timer** - Module-based timer with customizable duration options (45, 60, 90, 120, 180 minutes)
- **Task Management** - Integrated task list with status tracking (current, done, upcoming)
- **Timer Controls** - Intuitive start, pause, and reset functionality

### WorldSkills Competition Features
- **Competition Timeline** - Visual timeline showing competition phases (Arrival, Familiarization, Competition C1, Competition C2, Closing)
- **Milestone Tracking** - Key competition milestones with countdown timers
- **Timezone Converter** - Multi-city timezone display for international participants

### User Experience
- **Landscape Optimization** - Professional landscape layout designed for desktop and tablet use
- **Multi-language Support** - Chinese and English language options
- **Modern UI Design** - WorldSkills 2026 color scheme with glass morphism effects
- **Custom Typography** - Inter and JetBrains Mono fonts for optimal readability
- **Responsive Layout** - Adapts to various screen sizes and orientations

### UI Components
- **Circular Progress Indicator** - Animated ring progress for timer visualization
- **Glass Panel System** - Backdrop blur effects for modern UI elements
- **Timer Display Cards** - Large, readable timer displays with digit styling
- **Task Cards** - Interactive task management with status indicators
- **Competition Timeline Widget** - Phase-based progress visualization

## Screenshots

### Main Timer View
- Competition countdown display with days, hours, minutes, seconds
- Module selection panel with duration options
- Task management interface with status tracking

### Pomodoro Timer
- Circular progress indicator with animated transitions
- Timer controls (start, pause, reset)
- Task list with completion status

### Competition Features
- Timeline view showing competition phases
- Milestone countdown cards
- Timezone converter for multiple cities

## Getting Started

### Prerequisites

- **Dart SDK** - 3.9.2 or higher
- **Flutter SDK** - Latest stable version
- **Development Environment**
  - Android Studio / VS Code with Flutter extension
  - iOS development requires Xcode (macOS only)
  - Web development requires Chrome or Edge browser

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/skillcount.git
   cd skillcount
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   # Run on connected device/emulator
   flutter run

   # Run on web
   flutter run -d chrome

   # Run on Windows
   flutter run -d windows

   # Run on macOS
   flutter run -d macos

   # Run on Linux
   flutter run -d linux
   ```

## Usage

### Competition Countdown

The main screen displays a real-time countdown to WorldSkills 2026 competition opening ceremony (September 22, 2026). The countdown shows:
- Days remaining
- Hours, minutes, seconds breakdown
- Current competition phase status

### Pomodoro Timer

1. **Select Module Duration**
   - Choose from preset durations: 45, 60, 90, 120, or 180 minutes
   - The timer is optimized for skill training modules typical in WorldSkills competitions

2. **Manage Tasks**
   - Add new tasks with estimated completion time
   - Track task status: Current, Done, or Upcoming
   - Toggle task completion by clicking on task cards

3. **Control Timer**
   - Press START to begin the timer
   - Press PAUSE to temporarily stop the timer
   - Press RESET to return to initial duration

4. **Monitor Progress**
   - View circular progress indicator showing elapsed time
   - See remaining time in HH:MM:SS format
   - Check completion status badge

### Competition Timeline

View the progression through competition phases:
- **Arrival Phase** (September 18-19)
- **Familiarization** (September 19-21)
- **Competition C1** (September 22-23)
- **Competition C2** (September 23-25)
- **Closing** (September 25-27)

### Milestone Tracking

Monitor key competition milestones:
- Registration deadline
- Technical description release
- Competition opening
- Competition closing

Each milestone displays remaining time (days and hours) and status indicators.

### Timezone Converter

Convert between time zones for international coordination:
- Base time: Shanghai (UTC+8)
- Support for multiple major cities
- Real-time display of current local times

## Project Structure

```
skillcount/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   ├── ws_colors.dart      # WorldSkills color palette
│   │   │   └── ws_times.dart       # Competition time constants
│   │   ├── i18n/
│   │   │   ├── locale_provider.dart  # Language management
│   │   │   ├── strings.dart        # String interface
│   │   │   ├── zh.dart            # Chinese translations
│   │   │   └── en.dart            # English translations
│   │   ├── theme/
│   │   │   └── app_theme.dart      # Material Design theme
│   │   └── utils/
│   │       └── time_utils.dart       # Time calculation utilities
│   ├── features/
│   │   ├── countdown/
│   │   │   └── countdown_page.dart     # Main countdown page
│   │   ├── milestones/
│   │   │   ├── milestone_model.dart      # Milestone data model
│   │   │   ├── milestone_card.dart      # Milestone card widget
│   │   │   └── milestone_list.dart     # Milestone list widget
│   │   ├── pomodoro/
│   │   │   ├── pomodoro_controller.dart # Timer state management
│   │   │   └── pomodoro_page.dart     # Pomodoro interface
│   │   ├── module_timer/
│   │   │   ├── module_model.dart       # Module data model
│   │   │   ├── module_timer_page.dart   # Module timer interface
│   │   │   └── module_list_panel.dart  # Module list panel
│   │   ├── timezone/
│   │   │   ├── timezone_model.dart     # Timezone data model
│   │   │   ├── timezone_converter.dart # Timezone conversion logic
│   │   │   └── timezone_page.dart     # Timezone interface
│   │   └── settings/
│   │       └── settings_page.dart      # Settings configuration
│   ├── layout/
│   │   └── landscape_scaffold.dart   # Landscape layout scaffold
│   ├── widgets/
│   │   ├── glass_panel.dart           # Glass morphism panel widget
│   │   ├── ws_timer_text.dart         # Timer text display widget
│   │   ├── grid_background.dart      # Background grid decoration
│   │   └── competition_timeline.dart  # Competition timeline widget
│   ├── app.dart
│   └── main.dart
├── test/
│   └── widget_test.dart
├── pubspec.yaml
└── README.md
```

## Technology Stack

### Core Technologies
- **Flutter 3.x** - Cross-platform UI framework
- **Dart 3.9.2+** - Programming language
- **Material Design 3** - Design system

### Key Dependencies
- `cupertino_icons: ^1.0.8` - iOS-style icons
- `flutter_svg: ^2.2.3` - SVG image support
- `percent_indicator: ^4.2.5` - Animated progress indicators
- `confetti: ^0.8.0` - Celebration effects

### Development Tools
- `flutter_lints: ^5.0.0` - Code quality lints
- `flutter_test` - Widget and integration testing

### Platform Support
- iOS (iPhone/iPad)
- Android (phones and tablets)
- Web (Chrome, Edge, Firefox, Safari)
- Windows 10+
- macOS 10.14+
- Linux (Ubuntu, Fedora, etc.)

## Color System

The application uses WorldSkills 2026 color scheme:

- **Accent Cyan (#4FB6C7)** - Prominent elements (timer digits, progress bars, active states)
- **Secondary Mint (#8FD3D1)** - Supporting elements (secondary buttons, inactive tracks, icons)
- **Background (#D9D9D9)** - Application background (light gray)
- **Surface (#FFFFFF)** - Cards and panels (pure white)

Color constants are defined in `lib/core/constants/ws_colors.dart` and follow accessibility guidelines for sufficient contrast ratios.

## Configuration

### Orientation
The application is optimized for landscape orientation. To configure:

```dart
// In main.dart
SystemChrome.setPreferredOrientations([
  DeviceOrientation.landscapeLeft,
  DeviceOrientation.landscapeRight,
]);
```

### Language
Default language is Chinese (zh). Available languages:
- Chinese (zh)
- English (en)

To change the default language, modify the locale parameter in `lib/app.dart`:

```dart
MaterialApp(
  locale: const Locale('zh'), // or 'en'
  // ...
)
```

### Competition Date
The competition opening time is configured in `lib/core/constants/ws_times.dart`:

```dart
static const DateTime competitionOpenTime =
    DateTime.utc(2026, 9, 22, 19, 0); // 2026-09-22 19:00 UTC
```

## Development

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run tests with coverage
flutter test --coverage
```

### Code Quality

```bash
# Run static analysis
flutter analyze

# Format code
flutter format lib/

# Format with custom line length
flutter format --line-length=80 lib/
```

### Building

```bash
# Build Android APK
flutter build apk

# Build iOS app
flutter build ios

# Build web version
flutter build web

# Build Windows app
flutter build windows

# Build Linux app
flutter build linux

# Build macOS app
flutter build macos
```

## Contributing

Contributions are welcome! Please follow these guidelines:

1. **Fork the repository** and create a feature branch
2. **Write clear, descriptive commits** following conventional commit format
3. **Add tests** for new features or bug fixes
4. **Ensure all tests pass** (`flutter test`)
5. **Run static analysis** (`flutter analyze`)
6. **Update documentation** as needed
7. **Submit a pull request** with a clear description of changes

### Code Style
- Follow Dart official style guide
- Use `const` constructors where possible
- Keep functions focused and single-purpose
- Add inline comments for complex logic
- Maintain existing naming conventions

### Issue Reporting
When reporting issues, please include:
- Device and OS version
- Flutter version (`flutter --version`)
- Steps to reproduce the issue
- Expected vs actual behavior
- Screenshots if applicable

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- **WorldSkills International** - Competition inspiration and branding
- **Flutter Team** - Excellent cross-platform framework
- **Material Design Team** - Design system guidelines

## Support

For questions, issues, or feature requests:
- Open an issue on GitHub
- Check existing documentation
- Review similar issues before creating new ones

## Roadmap

### Planned Features
- [ ] Persistent data storage for tasks and settings
- [ ] Custom timer duration input
- [ ] Statistics and analytics dashboard
- [ ] Export/import task lists
- [ ] Notification support for timer completion
- [ ] Multiple competition profiles
- [ ] Team collaboration features
- [ ] Widget support for Android/iOS

### Enhancements
- [ ] Performance optimization for animations
- [ ] Accessibility improvements (screen reader support)
- [ ] Additional language support
- [ ] Enhanced testing coverage

---

**Built with Flutter for WorldSkills Competition Participants**

Version: 1.0.0+1
Last Updated: February 2026