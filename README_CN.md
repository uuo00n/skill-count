# SkillCount - WorldSkills 番茄钟计时器

[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20Web%20%7C%20Windows%20%7C%20macOS%20%7C%20Linux-lightgrey.svg)](https://flutter.dev/multi-platform)

面向 WorldSkills 竞赛主题的专业番茄钟计时器，适配桌面与平板横屏使用，提供竞赛倒计时、模块计时、任务管理与时区协作等能力。

## 功能概览

### 核心计时能力
- **竞赛倒计时** - 距离 WorldSkills 2026 开幕的实时倒计时
- **番茄钟/模块计时** - 支持 45/60/90/120/180 分钟预设
- **任务管理** - 任务状态管理（当前/完成/待办）
- **计时控制** - 开始/暂停/重置

### 竞赛相关
- **竞赛时间线** - 可视化展示竞赛阶段
- **里程碑跟踪** - 关键节点倒计时与状态
- **时区转换** - 多城市时区对照

### 体验与平台
- **横屏优化** - 桌面与平板优先的专业布局
- **多语言** - 中文、英文、日语、德语、法语、韩语
- **现代 UI** - WorldSkills 2026 配色与玻璃拟态效果
- **字体优化** - Inter 与 JetBrains Mono
- **自适应布局** - 适配多分辨率
- **自动全屏** - 桌面与 Web 启动时自动全屏（受平台限制）

## 快速开始

### 环境要求
- **Dart SDK** - 3.9.2 或更高
- **Flutter SDK** - 最新稳定版

### 安装依赖
```bash
flutter pub get
```

### 运行应用
```bash
# 连接设备/模拟器
flutter run

# Web
flutter run -d chrome

# Windows
flutter run -d windows

# macOS
flutter run -d macos

# Linux
flutter run -d linux
```

## 项目结构
```
skillcount/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   ├── i18n/
│   │   ├── theme/
│   │   └── utils/
│   ├── features/
│   ├── layout/
│   ├── widgets/
│   ├── app.dart
│   └── main.dart
├── test/
├── pubspec.yaml
└── README.md
```

## 语言配置
默认语言为中文（zh），可用语言：
- 中文（zh）
- English（en）
- 日本語（ja）
- Deutsch（de）
- Français（fr）
- 한국어（ko）

修改默认语言：
```dart
MaterialApp(
  locale: const Locale('zh'),
)
```

## 开发与测试
```bash
# 静态分析
flutter analyze

# 运行测试
flutter test
```

## 构建
```bash
flutter build apk
flutter build ios
flutter build web
flutter build windows
flutter build macos
flutter build linux
```

## 版本
Version: 1.0.0+1
Last Updated: February 2026
