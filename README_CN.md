# SkillCount - WorldSkills 训练计时与备赛助手

[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Version](https://img.shields.io/badge/Version-1.0.0%2B1-blue.svg)](pubspec.yaml)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20Web%20%7C%20Windows%20%7C%20macOS%20%7C%20Linux-lightgrey.svg)](https://flutter.dev/multi-platform)

面向 WorldSkills 竞赛备赛场景的计时与训练辅助应用，针对桌面与平板横屏进行布局优化。
提供竞赛倒计时、竞赛模块模拟计时、练习记录与复盘、时区协作、白噪音等能力。

## 功能概览

### 核心计时能力
- **竞赛倒计时** - 目标时间默认：北京时间 2026-09-22 00:00:00（内部以 UTC 存储）
- **统一计时面板** - 竞赛模块（A-E）与练习模块切换；支持倒计时与进度环
- **任务管理** - 任务状态（当前/完成/待办）、估时、编辑与排序
- **计时控制** - 开始/暂停/重置/继续

### 竞赛相关
- **竞赛时间线** - 可视化展示竞赛阶段（到达/熟悉场地/C1/C2/闭幕）
- **里程碑跟踪** - 关键节点卡片倒计时，数字带单位并支持多语言
- **时区转换** - 多城市世界时钟，便于国际协作

### 训练与复盘
- **练习历史** - 记录列表、统计图表分析
- **AI 复盘（可选）** - 对练习数据进行总结与建议（需配置 .env）

### 专注与环境
- **白噪音** - 内置音频播放，辅助专注
- **缓存清理** - 一键清理练习记录与 AI 分析历史

### 体验与平台
- **横屏优化** - 桌面与平板优先的专业布局
- **多语言** - 简体中文、繁体中文（台/港/澳）、英文、日语、德语、法语、韩语
- **现代 UI** - WorldSkills 2026 配色与玻璃拟态效果
- **字体优化** - Inter 与 JetBrains Mono
- **自适应布局** - 适配多分辨率
- **自动全屏** - 桌面与 Web 启动时自动全屏（受平台限制）

## 预览

- 建议在此放置应用截图或 GIF（例如：主计时页 / 模块计时 / 练习历史 / 设置页）。

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
│   │   ├── ai/
│   │   ├── theme/
│   │   └── utils/
│   ├── features/
│   │   ├── countdown/
│   │   ├── unified_timer/
│   │   ├── practice_history/
│   │   ├── timezone/
│   │   ├── white_noise/
│   │   └── settings/
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
- 中文（简体，zh）
- 中文（繁體，zh-TW / zh-HK / zh-MO）
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

## 竞赛时间配置

竞赛开幕倒计时目标时间在 [ws_times.dart](lib/core/constants/ws_times.dart) 中配置（以 UTC 存储，显示时转换为本地时区）：

```dart
static final DateTime competitionOpenTime =
    DateTime.utc(2026, 9, 21, 16, 0, 0); // 北京时间 2026-09-22 00:00:00
```

## 开发与测试
```bash
# 静态分析
flutter analyze

# 运行测试
flutter test
```

## 可选：配置 AI 复盘

AI 能力通过 `.env` 配置（示例仅供参考，请勿提交真实密钥）：

```bash
AI_ENGINE=volcengine

# Volcengine
VOLCENGINE_API_KEY=your_api_key
VOLCENGINE_ENDPOINT=https://ark.cn-beijing.volces.com/api/v3
VOLCENGINE_MODEL=ep-2024xxxx
VOLCENGINE_TIMEOUT=60

# Dify (可选)
DIFY_API_KEY=your_api_key
DIFY_BASE_URL=https://api.dify.ai/v1
DIFY_APP_ID=your_app_id
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
