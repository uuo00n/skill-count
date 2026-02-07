# 白噪音功能实现计划

## 📋 项目概述

在 SkillCount 应用中添加白噪音播放功能，支持从随机位置循环播放白噪音音频，帮助用户集中注意力。

## 🎯 核心需求

- **独立标签页**：在底部导航栏添加白噪音专属标签页
- **随机位置循环**：每次播放从音频随机位置开始并无缝循环播放
- **跨平台支持**：支持 iOS、Android、Web、桌面平台

## 🛠 技术选型

### 音频插件：just_audio ^0.10.5

**选择理由：**
- ✅ 精确的 seek 功能，支持随机位置播放
- ✅ 内置循环模式（LoopMode.one）无缝循环
- ✅ 跨平台支持（iOS/Android/Web/Desktop）
- ✅ Stream 架构与 Riverpod 完美集成
- ✅ 音量和播放速度控制
- ✅ 优秀文档和活跃维护

## 📂 文件结构

```
lib/
├── core/
│   ├── providers/
│   │   └── white_noise_provider.dart      # Riverpod Provider
│   └── i18n/
│       ├── strings.dart                   # 添加国际化接口
│       ├── zh.dart                        # 中文翻译
│       └── en.dart                        # 英文翻译
├── features/
│   └── white_noise/
│       ├── white_noise_service.dart        # 核心服务
│       ├── white_noise_page.dart          # UI 页面
│       └── widgets/
│           ├── play_button.dart           # 播放控制组件
│           └── volume_slider.dart          # 音量控制组件（可选）
├── layout/
│   └── landscape_scaffold.dart             # 添加导航栏标签
assets/
└── audio/
    └── white_noise.mp3                    # 白噪音音频文件
```

## 🚀 实施步骤

### 步骤 1：添加依赖

```yaml
# pubspec.yaml
dependencies:
  just_audio: ^0.10.5
```

### 步骤 2：准备音频资源

1. 创建 `assets/audio/` 目录
2. 添加白噪音音频文件（推荐时长：10-30分钟）
3. 更新 `pubspec.yaml`：

```yaml
flutter:
  assets:
    - assets/images/
    - assets/audio/
```

### 步骤 3：创建核心服务

**文件：`lib/features/white_noise/white_noise_service.dart`**

```dart
import 'dart:math';
import 'package:just_audio/just_audio.dart';

class WhiteNoiseService {
  final AudioPlayer _player = AudioPlayer();
  
  /// 初始化音频播放器设置
  Future<void> initialize() async {
    await _player.setLoopMode(LoopMode.one);
  }
  
  /// 核心功能：从随机位置循环播放白噪音
  Future<void> playRandomPosition(String assetPath) async {
    try {
      // 加载音频文件
      await _player.setAsset(assetPath);
      final duration = _player.duration ?? Duration.zero;
      
      // 生成随机位置（毫秒精度）
      if (duration > Duration.zero) {
        final randomPosition = Duration(
          milliseconds: Random().nextInt(duration.inMilliseconds)
        );
        await _player.seek(randomPosition);
      }
      
      // 开始播放
      await _player.play();
    } catch (e) {
      // 错误处理
      print('Error playing white noise: $e');
      rethrow;
    }
  }
  
  /// 暂停播放
  Future<void> pause() => _player.pause();
  
  /// 停止播放
  Future<void> stop() => _player.stop();
  
  /// 设置音量 (0.0 - 1.0)
  Future<void> setVolume(double volume) => _player.setVolume(volume.clamp(0.0, 1.0));
  
  /// 播放状态流
  Stream<bool> get playingStream => _player.playingStream;
  
  /// 当前播放状态
  bool get isPlaying => _player.playing;
  
  /// 释放资源
  void dispose() => _player.dispose();
}
```

### 步骤 4：创建 Riverpod Provider

**文件：`lib/core/providers/white_noise_provider.dart`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/white_noise/white_noise_service.dart';

/// 白噪音服务 Provider
final whiteNoiseServiceProvider = Provider<WhiteNoiseService>((ref) {
  final service = WhiteNoiseService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// 播放状态 Provider
final whiteNoisePlayingProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(whiteNoiseServiceProvider);
  return service.playingStream;
});

/// 音量控制 Provider
final whiteNoiseVolumeProvider = StateProvider<double>((ref) => 0.7);
```

### 步骤 5：创建白噪音页面

**文件：`lib/features/white_noise/white_noise_page.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/ws_colors.dart';
import '../../core/i18n/locale_provider.dart';
import '../widgets/grid_background.dart';
import 'widgets/play_button.dart';
import 'widgets/volume_slider.dart';

class WhiteNoisePage extends ConsumerWidget {
  const WhiteNoisePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = LocaleScope.of(context);
    final isPlaying = ref.watch(whiteNoisePlayingProvider);
    final volume = ref.watch(whiteNoiseVolumeProvider);
    
    return Scaffold(
      body: GridBackground(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 标题
                  Row(
                    children: [
                      Icon(
                        Icons.surround_sound_outlined,
                        size: 24,
                        color: WsColors.accentCyan,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        s.whiteNoise,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: WsColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  
                  // 波形图标
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: WsColors.accentCyan.withAlpha(20),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: WsColors.accentCyan.withAlpha(60),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.graphic_eq,
                      size: 48,
                      color: isPlaying.value == true
                          ? WsColors.accentCyan
                          : WsColors.textSecondary.withAlpha(120),
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // 播放控制按钮
                  PlayButton(
                    isPlaying: isPlaying.value == true,
                    onTap: () {
                      if (isPlaying.value == true) {
                        ref.read(whiteNoiseServiceProvider).pause();
                      } else {
                        ref.read(whiteNoiseServiceProvider).playRandomPosition(
                          'assets/audio/white_noise.mp3'
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 32),
                  
                  // 音量控制
                  VolumeSlider(
                    volume: volume,
                    onChanged: (newVolume) {
                      ref.read(whiteNoiseVolumeProvider.state).state = newVolume;
                      ref.read(whiteNoiseServiceProvider).setVolume(newVolume);
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // 状态显示
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: WsColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: WsColors.border),
                    ),
                    child: Text(
                      isPlaying.value == true
                          ? s.whiteNoisePlaying
                          : s.whiteNoiseStopped,
                      style: const TextStyle(
                        fontSize: 14,
                        color: WsColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

### 步骤 6：创建 UI 组件

**播放按钮组件：`lib/features/white_noise/widgets/play_button.dart`**

```dart
import 'package:flutter/material.dart';
import '../../../core/constants/ws_colors.dart';

class PlayButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onTap;

  const PlayButton({
    super.key,
    required this.isPlaying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(32),
        onTap: onTap,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: WsColors.accentCyan,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: WsColors.accentCyan.withAlpha(40),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            isPlaying ? Icons.pause : Icons.play_arrow,
            size: 32,
            color: WsColors.white,
          ),
        ),
      ),
    );
  }
}
```

### 步骤 7：集成到导航栏

**修改：`lib/layout/landscape_scaffold.dart`**

```dart
// 在 _LandscapeScaffoldState 类中
static const _pages = <Widget>[
  CountdownPage(),
  UnifiedTimerPage(),
  TimezonePage(),
  WhiteNoisePage(),  // 新增白噪音页面
  SettingsPage(),
];

// 在 _buildBottomNav 方法中添加白噪音标签
Widget _buildBottomNav(BuildContext context) {
  final s = LocaleScope.of(context);
  
  return Container(
    // ... 现有代码 ...
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildNavTab(0, Icons.dashboard_outlined, s.dashboard),
        const SizedBox(width: 8),
        ValueListenableBuilder<bool>(
          valueListenable: UnifiedTimerPage.isTimerRunning,
          builder: (context, isRunning, child) {
            return _buildNavTab(
              1,
              Icons.timer_outlined,
              s.unifiedTimer,
              showDot: isRunning,
            );
          },
        ),
        const SizedBox(width: 8),
        _buildNavTab(2, Icons.public_outlined, s.timezone),
        const SizedBox(width: 8),
        _buildNavTab(3, Icons.surround_sound_outlined, s.whiteNoise),  // 新增
        const SizedBox(width: 8),
        // Settings icon
        // ... 现有设置图标代码 ...
      ],
    ),
  );
}

// 修改 _buildNavTab 方法中的索引判断
Widget _buildNavTab(int index, IconData icon, String label, {bool showDot = false}) {
  // 确保 selectedIndex 计算正确
  final isSelected = _selectedIndex == index;
  // ... 其他代码保持不变
}
```

### 步骤 8：添加国际化支持

**修改：`lib/core/i18n/strings.dart`**

```dart
abstract class AppStrings {
  // ... 现有代码 ...
  
  // White Noise
  String get whiteNoise;
  String get playWhiteNoise;
  String get pauseWhiteNoise;
  String get whiteNoisePlaying;
  String get whiteNoiseStopped;
}
```

**修改：`lib/core/i18n/zh.dart`**

```dart
class ZhStrings implements AppStrings {
  // ... 现有代码 ...
  
  @override
  String get whiteNoise => '白噪音';
  @override
  String get playWhiteNoise => '播放白噪音';
  @override
  String get pauseWhiteNoise => '暂停白噪音';
  @override
  String get whiteNoisePlaying => '白噪音播放中';
  @override
  String get whiteNoiseStopped => '白噪音已停止';
}
```

**修改：`lib/core/i18n/en.dart`**

```dart
class EnStrings implements AppStrings {
  // ... 现有代码 ...
  
  @override
  String get whiteNoise => 'White Noise';
  @override
  String get playWhiteNoise => 'Play White Noise';
  @override
  String get pauseWhiteNoise => 'Pause White Noise';
  @override
  String get whiteNoisePlaying => 'White Noise Playing';
  @override
  String get whiteNoiseStopped => 'White Noise Stopped';
}
```

## 🎛 核心功能说明

### 随机位置循环播放机制

```dart
/// 核心算法流程：
/// 1. 加载音频文件 → _player.setAsset(assetPath)
/// 2. 获取音频总时长 → _player.duration
/// 3. 生成随机位置 → Random().nextInt(duration.inMilliseconds)
/// 4. 跳转到随机位置 → _player.seek(randomPosition)
/// 5. 设置循环模式 → LoopMode.one
/// 6. 开始播放 → _player.play()
```

**优势：**
- 避免重复听音频开头部分
- 创造更自然的白噪音体验
- 减少听觉疲劳
- 每次播放都有新鲜感

## 🎨 UI 设计

### 白噪音页面布局

```
┌─────────────────────────────────┐
│  🎵 白噪音                       │
│                                 │
│         [ 波形图标 ]             │
│                                 │
│     [ ▶️/⏸️ 播放按钮 ]           │
│                                 │
│     [ 音量滑块 ]                 │
│     ◯─────●─────○                │
│                                 │
│  ┌─────────────────────┐         │
│  │ 白噪音播放中         │         │
│  └─────────────────────┘         │
└─────────────────────────────────┘
```

### 设计要点

- **居中布局**：所有控件垂直居中排列
- **视觉层次**：标题 → 图标 → 主按钮 → 辅助控件
- **状态反馈**：播放状态通过图标颜色和文本显示
- **交互反馈**：按钮点击动画和阴影效果

## 🔄 状态管理

### Riverpod 状态流

```dart
// 播放状态监听
final isPlaying = ref.watch(whiteNoisePlayingProvider);

// 音量控制
final volume = ref.watch(whiteNoiseVolumeProvider);

// 服务调用
ref.read(whiteNoiseServiceProvider).playRandomPosition();
```

## 🧪 测试要点

### 功能测试

1. **基本播放控制**
   - [ ] 点击播放按钮开始播放
   - [ ] 点击暂停按钮停止播放
   - [ ] 播放状态正确显示

2. **随机位置功能**
   - [ ] 每次播放从不同位置开始
   - [ ] 循环播放无间断
   - [ ] 音频结束时自动循环

3. **音量控制**
   - [ ] 滑块调节音量
   - [ ] 音量变化实时生效

4. **导航集成**
   - [ ] 底部导航显示白噪音标签
   - [ ] 点击标签正确跳转
   - [ ] 图标和文字显示正确

### 边界测试

- [ ] 网络异常情况处理
- [ ] 音频文件加载失败处理
- [ ] 内存泄漏检查
- [ ] 应用切换后播放状态

## 📈 性能优化

### 音频资源管理

```dart
// 使用 Provider 自动释放资源
final whiteNoiseServiceProvider = Provider<WhiteNoiseService>((ref) {
  final service = WhiteNoiseService();
  ref.onDispose(() => service.dispose());  // 自动清理
  return service;
});
```

### 内存优化

- 音频文件使用 asset 资源，避免网络请求
- 及时释放 AudioPlayer 资源
- 使用 Stream 避免频繁状态更新

## 🚀 可选增强功能

### 短期增强

1. **播放时间限制**
   - 15/30/60 分钟自动停止
   - 倒计时显示

2. **淡入淡出效果**
   - 播放开始时音量渐强
   - 停止播放时音量渐弱

3. **多种白噪音类型**
   - 雨声、海浪、森林、风扇等
   - 切换不同音频源

### 长期扩展

1. **混合播放**
   - 同时播放多种白噪音
   - 各自音量独立控制

2. **播放历史**
   - 记录用户偏好
   - 智能推荐

3. **定时任务**
   - 与番茄钟集成
   - 自动播放/停止

## 📋 实施清单

### Phase 1: 基础功能 (核心实现)

- [ ] **环境准备**
  - [ ] 添加 just_audio 依赖
  - [ ] 准备白噪音音频文件
  - [ ] 配置 assets 路径

- [ ] **核心服务开发**
  - [ ] 创建 WhiteNoiseService 类
  - [ ] 实现随机位置播放逻辑
  - [ ] 实现循环播放功能
  - [ ] 添加错误处理机制

- [ ] **状态管理**
  - [ ] 创建 Riverpod Provider
  - [ ] 实现播放状态监听
  - [ ] 实现音量控制状态

- [ ] **基础 UI**
  - [ ] 创建 WhiteNoisePage
  - [ ] 实现播放/暂停按钮
  - [ ] 实现音量控制滑块
  - [ ] 添加播放状态显示

### Phase 2: 导航集成 (用户体验)

- [ ] **导航栏集成**
  - [ ] 在 LandscapeScaffold 添加白噪音页面
  - [ ] 更新底部导航栏标签
  - [ ] 调整导航索引逻辑

- [ ] **国际化支持**
  - [ ] 添加中英文翻译
  - [ ] 更新字符串接口
  - [ ] 测试语言切换

### Phase 3: 优化与测试 (质量保证)

- [ ] **功能测试**
  - [ ] 测试播放/暂停功能
  - [ ] 测试随机位置播放
  - [ ] 测试循环播放
  - [ ] 测试音量控制

- [ ] **边界测试**
  - [ ] 测试异常情况处理
  - [ ] 测试内存管理
  - [ ] 测试应用切换

- [ ] **性能优化**
  - [ ] 检查资源释放
  - [ ] 优化状态更新
  - [ ] 减少不必要的重建

### Phase 4: 文档与发布 (部署准备)

- [ ] **代码文档**
  - [ ] 添加关键函数注释
  - [ ] 更新 README 文档
  - [ ] 记录使用说明

- [ ] **最终检查**
  - [ ] 代码审查
  - [ ] 静态分析检查
  - [ ] 集成测试

## 🎯 预期效果

### 用户体验

1. **简洁专注**：独立的白噪音页面，避免干扰
2. **自然体验**：随机位置播放，避免听觉疲劳
3. **无缝循环**：持续的环境音，专注工作学习
4. **直观控制**：一键播放/暂停，简单易用

### 技术价值

1. **架构完善**：使用 Riverpod 状态管理，代码结构清晰
2. **性能优化**：合理的资源管理和内存释放
3. **扩展性强**：为后续功能扩展打下基础
4. **跨平台**：一套代码，多平台运行

## 📝 备注

- 音频文件建议使用高品质的白噪音，时长 10-30 分钟为佳
- 需要在真机上测试音频功能，模拟器可能有兼容性问题
- Web 平台可能需要额外的音频权限配置
- 考虑添加音频文件的压缩和缓存机制以优化加载速度

---

**创建时间：** 2025年2月7日  
**适用版本：** Flutter 3.9.2+  
**最后更新：** [实施过程中更新]