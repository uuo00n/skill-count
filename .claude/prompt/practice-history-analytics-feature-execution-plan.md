# Practice History & Analytics Feature - 练习历史与进度分析功能执行计划

## 📋 执行目标

### 当前问题分析

**计时器模块现状**：
- ✅ 支持竞赛模块和练习模块
- ✅ 支持任务管理和计时
- ✅ 支持任务状态切换
- ❌ 计时完成后数据丢失
- ❌ 无法查看历史练习记录
- ❌ 无法对比练习时长
- ❌ 无法可视化进度趋势

**用户需求**：
1. 计时结束后或完成模块后保存记录到本地存储
2. 查看历史完成记录
3. 对比每次练习的时长
4. 可视化查看相同模块每次速度提升的进度曲线
5. 符合项目设计语言
6. 添加合理的执行动画
7. 保证app完整性

### 重构目标

```text
目标：
- 实现练习记录持久化存储
- 创建历史记录查看页面
- 实现模块级别的时长对比
- 提供可视化进度分析（组合图表）
- 新增独立Tab导航
- 保持现有UI风格一致性
```

## 🎨 设计方案选择

### 数据存储方案：SharedPreferences + JSON序列化

**优点**：
- 轻量级，无需额外数据库依赖
- 适合结构化数据的存储和读取
- 已在milestone功能中使用，保持技术栈一致

**数据模型层级**：
```
PracticeRecord (练习记录)
├─ 基本信息：id, moduleId, moduleName, completedAt
├─ 时长信息：totalDuration, estimatedDuration
├─ 任务详情：taskRecords[]
│  └─ TaskRecord: taskId, taskTitle, actualSpent, estimatedDuration, status
└─ 关键节点：keyEvents[]
   └─ KeyEvent: type, timestamp, data
```

### UI集成方案：新增独立Tab

**导航结构**：
```
当前5个Tab：
[Dashboard] [Timer] [Timezone] [WhiteNoise] [Settings]

新增后6个Tab：
[Dashboard] [Timer] [History] [Timezone] [WhiteNoise] [Settings]
```

**Tab索引映射**：
| Index | Page | Feature |
|-------|------|---------|
| 0 | CountdownPage | WorldSkills opening ceremony countdown |
| 1 | UnifiedTimerPage | Module timer with task management |
| 2 | PracticeHistoryPage | History records and analytics |
| 3 | TimezonePage | Multi-city timezone display |
| 4 | WhiteNoisePage | White noise audio player |
| 5 | SettingsPage | Language toggle + app info |

### 可视化方案：fl_chart组合图表

**图表类型**：
- **折线图**：展示同一模块多次练习的时长变化趋势
- **柱状图**：展示每次练习的具体时长数值
- **组合显示**：在同一图表中同时显示趋势和数值

**设计风格**：
- 使用WorldSkills配色（accentCyan、secondaryMint、accentGreen）
- 浅色背景（适合Material 3 light theme）
- 平滑曲线和圆角柱体
- 悬停显示详细数据

### 记录保存时机

**保存触发点**：
1. **单个任务完成**：保存任务完成记录
2. **模块完成**：保存完整的模块练习记录
3. **计时停止**：如果计时器运行过，保存部分进度记录

## 🚀 Phase 1 — 数据模型和持久化层（第1周）

### Phase 1 总目标

```text
目标：
- 创建练习记录数据模型
- 实现JSON序列化/反序列化
- 创建历史记录状态管理
- 添加shared_preferences依赖
- 实现数据持久化基础
```

---

## 🧩 Step 1 — 创建练习记录数据模型

### Claude Code Prompt

```text
创建文件：lib/features/practice_history/models/practice_record_model.dart

要求：
- 创建PracticeRecord模型（主记录）
- 创建TaskRecord模型（任务记录）
- 创建KeyEvent模型（关键事件）
- 支持JSON序列化/反序列化
- 提供计算属性（效率评分、速度提升等）
- 使用UTC时间存储

实现框架：
import 'dart:convert';

enum RecordType {
  moduleComplete,
  taskComplete,
  partial,
}

enum KeyEventType {
  timerStart,
  timerPause,
  timerResume,
  timerStop,
  taskComplete,
  moduleComplete,
}

class TaskRecord {
  final String taskId;
  final String taskTitle;
  final Duration actualSpent;
  final Duration? estimatedDuration;
  final String status;

  TaskRecord({
    required this.taskId,
    required this.taskTitle,
    required this.actualSpent,
    this.estimatedDuration,
    required this.status,
  });

  double get efficiency {
    if (estimatedDuration == null || estimatedDuration!.inSeconds == 0) return 1.0;
    final actualSeconds = actualSpent.inSeconds.toDouble();
    final estimatedSeconds = estimatedDuration!.inSeconds.toDouble();
    return (estimatedSeconds / actualSeconds).clamp(0.0, 2.0);
  }

  Map<String, dynamic> toJson() {
    return {
      'taskId': taskId,
      'taskTitle': taskTitle,
      'actualSpent': actualSpent.inSeconds,
      'estimatedDuration': estimatedDuration?.inSeconds,
      'status': status,
    };
  }

  factory TaskRecord.fromJson(Map<String, dynamic> json) {
    return TaskRecord(
      taskId: json['taskId'] as String,
      taskTitle: json['taskTitle'] as String,
      actualSpent: Duration(seconds: json['actualSpent'] as int),
      estimatedDuration: json['estimatedDuration'] != null
          ? Duration(seconds: json['estimatedDuration'] as int)
          : null,
      status: json['status'] as String,
    );
  }
}

class KeyEvent {
  final KeyEventType type;
  final DateTime timestamp;
  final Map<String, dynamic>? data;

  KeyEvent({
    required this.type,
    required this.timestamp,
    this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'data': data,
    };
  }

  factory KeyEvent.fromJson(Map<String, dynamic> json) {
    return KeyEvent(
      type: KeyEventType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => KeyEventType.timerStart,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      data: json['data'] as Map<String, dynamic>?,
    );
  }
}

class PracticeRecord {
  final String id;
  final String moduleId;
  final String moduleName;
  final RecordType recordType;
  final DateTime completedAt;
  final Duration totalDuration;
  final Duration estimatedDuration;
  final List<TaskRecord> taskRecords;
  final List<KeyEvent> keyEvents;

  PracticeRecord({
    required this.id,
    required this.moduleId,
    required this.moduleName,
    required this.recordType,
    required this.completedAt,
    required this.totalDuration,
    required this.estimatedDuration,
    required this.taskRecords,
    required this.keyEvents,
  });

  double get efficiency {
    if (estimatedDuration.inSeconds == 0) return 1.0;
    final actualSeconds = totalDuration.inSeconds.toDouble();
    final estimatedSeconds = estimatedDuration.inSeconds.toDouble();
    return (estimatedSeconds / actualSeconds).clamp(0.0, 2.0);
  }

  int get completedTasks {
    return taskRecords.where((t) => t.status == 'done').length;
  }

  int get totalTasks => taskRecords.length;

  Duration get averageTaskDuration {
    if (taskRecords.isEmpty) return Duration.zero;
    final totalSeconds = taskRecords.fold<int>(
      0,
      (sum, t) => sum + t.actualSpent.inSeconds,
    );
    return Duration(seconds: totalSeconds ~/ taskRecords.length);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'moduleId': moduleId,
      'moduleName': moduleName,
      'recordType': recordType.name,
      'completedAt': completedAt.toIso8601String(),
      'totalDuration': totalDuration.inSeconds,
      'estimatedDuration': estimatedDuration.inSeconds,
      'taskRecords': taskRecords.map((t) => t.toJson()).toList(),
      'keyEvents': keyEvents.map((e) => e.toJson()).toList(),
    };
  }

  factory PracticeRecord.fromJson(Map<String, dynamic> json) {
    return PracticeRecord(
      id: json['id'] as String,
      moduleId: json['moduleId'] as String,
      moduleName: json['moduleName'] as String,
      recordType: RecordType.values.firstWhere(
        (e) => e.name == json['recordType'],
        orElse: () => RecordType.moduleComplete,
      ),
      completedAt: DateTime.parse(json['completedAt'] as String),
      totalDuration: Duration(seconds: json['totalDuration'] as int),
      estimatedDuration: Duration(seconds: json['estimatedDuration'] as int),
      taskRecords: (json['taskRecords'] as List<dynamic>)
          .map((t) => TaskRecord.fromJson(t as Map<String, dynamic>))
          .toList(),
      keyEvents: (json['keyEvents'] as List<dynamic>?)
              ?.map((e) => KeyEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  static List<PracticeRecord> listFromJson(String jsonStr) {
    final List<dynamic> decoded = jsonDecode(jsonStr);
    return decoded
        .map((json) => PracticeRecord.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  static String listToJson(List<PracticeRecord> records) {
    return jsonEncode(records.map((r) => r.toJson()).toList());
  }
}
```

只输出该文件完整代码。
```

---

## 🧩 Step 2 — 创建历史记录状态管理

### Claude Code Prompt

```text
创建文件：lib/features/practice_history/providers/history_provider.dart

要求：
- 使用Riverpod创建状态管理
- 管理练习记录列表
- 提供添加/删除/清空方法
- 自动从SharedPreferences加载
- 自动保存到SharedPreferences
- 提供查询和统计方法
- 按模块分组记录
- 按时间排序记录

实现框架：
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/practice_record_model.dart';

class HistoryNotifier extends StateNotifier<List<PracticeRecord>> {
  HistoryNotifier() : super([]) {
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recordsJson = prefs.getString('practice_records');

      if (recordsJson != null && recordsJson.isNotEmpty) {
        final records = PracticeRecord.listFromJson(recordsJson);
        state = records;
      }
    } catch (e) {
      print('Failed to load practice records: $e');
    }
  }

  Future<void> _saveRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = PracticeRecord.listToJson(state);
      await prefs.setString('practice_records', encoded);
    } catch (e) {
      print('Failed to save practice records: $e');
    }
  }

  Future<void> addRecord(PracticeRecord record) async {
    state = [...state, record];
    state = _sortRecords(state);
    await _saveRecords();
  }

  Future<void> deleteRecord(String recordId) async {
    state = state.where((r) => r.id != recordId).toList();
    await _saveRecords();
  }

  Future<void> clearAll() async {
    state = [];
    await _saveRecords();
  }

  List<PracticeRecord> getRecordsByModule(String moduleId) {
    return state.where((r) => r.moduleId == moduleId).toList();
  }

  Map<String, List<PracticeRecord>> getRecordsGroupedByModule() {
    final Map<String, List<PracticeRecord>> grouped = {};
    for (final record in state) {
      grouped.putIfAbsent(record.moduleId, () => []);
      grouped[record.moduleId]!.add(record);
    }
    for (final key in grouped.keys) {
      grouped[key] = _sortRecords(grouped[key]!);
    }
    return grouped;
  }

  List<PracticeRecord> _sortRecords(List<PracticeRecord> records) {
    return records.toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
  }

  Map<String, Duration> getAverageDurationsByModule() {
    final Map<String, Duration> averages = {};
    final grouped = getRecordsGroupedByModule();

    for (final entry in grouped.entries) {
      if (entry.value.isEmpty) continue;

      final totalSeconds = entry.value.fold<int>(
        0,
        (sum, r) => sum + r.totalDuration.inSeconds,
      );
      final avgSeconds = totalSeconds ~/ entry.value.length;
      averages[entry.key] = Duration(seconds: avgSeconds);
    }

    return averages;
  }

  int get totalRecords => state.length;

  int getRecordsCountByModule(String moduleId) {
    return state.where((r) => r.moduleId == moduleId).length;
  }
}

final historyProvider =
    StateNotifierProvider<HistoryNotifier, List<PracticeRecord>>((ref) {
  return HistoryNotifier();
});
```

只输出该文件完整代码。
```

---

## 🧩 Step 3 — 添加fl_chart依赖

### Claude Code Prompt

```text
修改文件：pubspec.yaml

要求：
- 添加fl_chart依赖
- 版本使用^0.68.0（最新稳定版）
- 添加到dependencies部分

添加内容：
dependencies:
  # ... 现有依赖 ...
  fl_chart: ^0.68.0
```

只输出添加依赖后的dependencies部分。
```

---

## ✅ Phase 1 完成标准

```text
- PracticeRecord、TaskRecord、KeyEvent模型创建完成
- JSON序列化/反序列化实现完成
- HistoryNotifier状态管理创建完成
- 数据可从SharedPreferences加载
- 数据可保存到SharedPreferences
- fl_chart依赖添加成功
```

---

## 🚀 Phase 2 — 记录保存集成（第2周）

### Phase 2 总目标

```text
目标：
- 修改UnifiedTimerController保存记录
- 集成HistoryProvider到计时器页面
- 实现模块完成时自动保存
- 实现任务完成时自动保存
- 添加保存成功提示
```

---

## 🧩 Step 4 — 修改UnifiedTimerController集成记录保存

### Claude Code Prompt

```text
修改文件：lib/features/unified_timer/controllers/unified_timer_controller.dart

要求：
- 添加历史记录保存回调
- 在模块完成时创建PracticeRecord
- 在任务完成时更新TaskRecord
- 追踪关键事件（开始、暂停、恢复、停止）
- 传递回调到Controller

修改要点：
1. 添加onRecordComplete回调参数
2. 在构造函数中接收回调
3. 记录关键事件到列表
4. 模块完成时构建完整记录
5. 调用回调保存记录

实现框架：
import '../../../core/timer/competition_timer.dart';
import '../models/unified_timer_model.dart';
import 'package:flutter/foundation.dart';

class UnifiedTimerController {
  ModuleModel? currentModule;
  TaskItem? currentTask;
  Duration totalDuration;
  bool isPracticeMode = false;
  final void Function() onTick;
  final void Function(Map<String, dynamic>)? onRecordComplete;

  CompetitionTimer _timer;
  StreamSubscription<Duration>? _subscription;

  // 关键事件追踪
  final List<Map<String, dynamic>> _keyEvents = [];

  UnifiedTimerController({
    required this.totalDuration,
    required this.onTick,
    this.onRecordComplete,
  }) : _timer = CompetitionTimer(
          totalDuration: totalDuration,
          mode: TimerMode.countDown,
        ) {
    _listenTimer();
  }

  // ... 现有代理属性 ...

  // ... 现有模块操作 ...

  void start() {
    _timer.start();
    _addKeyEvent(KeyEventType.timerStart);
  }

  void pause() {
    _timer.pause();
    _addKeyEvent(KeyEventType.timerPause);
  }

  void reset() {
    _timer.reset();
    _keyEvents.clear();
    onTick();
  }

  // ... 现有任务操作 ...

  void completeTask() {
    if (currentTask != null) {
      currentTask!.status = TaskStatus.done;
      currentTask!.completedAt = DateTime.now();
      _addKeyEvent(KeyEventType.taskComplete, {
        'taskId': currentTask!.id,
        'taskTitle': currentTask!.title,
        'actualSpent': currentTask!.actualSpent.inSeconds,
      });

      // 保存任务完成记录
      if (currentModule != null && onRecordComplete != null) {
        final recordData = {
          'moduleId': currentModule!.id,
          'moduleName': currentModule!.name,
          'recordType': 'taskComplete',
          'taskId': currentTask!.id,
          'taskTitle': currentTask!.title,
          'actualSpent': currentTask!.actualSpent.inSeconds,
          'estimatedDuration': currentTask!.estimatedDuration?.inSeconds,
          'status': 'done',
          'completedAt': DateTime.now().toIso8601String(),
          'totalDuration': totalDuration.inSeconds,
          'estimatedModuleDuration': currentModule!.defaultDuration.inSeconds,
          'keyEvents': List<Map<String, dynamic>>.from(_keyEvents),
        };
        onRecordComplete!(recordData);
      }

      currentTask = null;
      onTick();
    }
  }

  void completeModule() {
    if (currentModule != null && onRecordComplete != null) {
      _addKeyEvent(KeyEventType.moduleComplete);

      final recordData = {
        'moduleId': currentModule!.id,
        'moduleName': currentModule!.name,
        'recordType': 'moduleComplete',
        'completedAt': DateTime.now().toIso8601String(),
        'totalDuration': totalDuration.inSeconds,
        'estimatedDuration': currentModule!.defaultDuration.inSeconds,
        'taskRecords': currentModule!.tasks.map((task) {
          return {
            'taskId': task.id,
            'taskTitle': task.title,
            'actualSpent': task.actualSpent.inSeconds,
            'estimatedDuration': task.estimatedDuration?.inSeconds,
            'status': task.status.name,
          };
        }).toList(),
        'keyEvents': List<Map<String, dynamic>>.from(_keyEvents),
      };
      onRecordComplete!(recordData);
    }
  }

  void _addKeyEvent(KeyEventType type, [Map<String, dynamic>? data]) {
    _keyEvents.add({
      'type': type.name,
      'timestamp': DateTime.now().toIso8601String(),
      if (data != null) ...data,
    });
  }

  // ... 现有生命周期方法 ...

  // ... 现有私有方法 ...
}
```

只输出修改后的完整文件代码。
```

---

## 🧩 Step 5 — 修改UnifiedTimerPage集成历史记录

### Claude Code Prompt

```text
修改文件：lib/features/unified_timer/widgets/unified_timer_page.dart

要求：
- 导入historyProvider
- 在控制器构造函数中传入onRecordComplete回调
- 接收记录数据并创建PracticeRecord
- 保存到历史记录
- 显示保存成功的提示

修改要点：
1. 导入必要的包
2. 在_initState中添加记录处理逻辑
3. 创建_handleRecordComplete方法
4. 使用ref.read访问historyProvider
5. 添加成功提示

实现框架：
// 在文件顶部添加导入
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../practice_history/providers/history_provider.dart';
import '../../practice_history/models/practice_record_model.dart';

// 在_UnifiedTimerPageState类中添加方法

void _handleRecordComplete(Map<String, dynamic> recordData) {
  final recordId = 'record_${DateTime.now().millisecondsSinceEpoch}';
  final recordType = RecordType.values.firstWhere(
    (e) => e.name == recordData['recordType'],
    orElse: () => RecordType.partial,
  );

  final List<TaskRecord> taskRecords = [];
  if (recordData['taskRecords'] != null) {
    for (final taskData in recordData['taskRecords']) {
      taskRecords.add(TaskRecord(
        taskId: taskData['taskId'] as String,
        taskTitle: taskData['taskTitle'] as String,
        actualSpent: Duration(seconds: taskData['actualSpent'] as int),
        estimatedDuration: taskData['estimatedDuration'] != null
            ? Duration(seconds: taskData['estimatedDuration'] as int)
            : null,
        status: taskData['status'] as String,
      ));
    }
  }

  final List<KeyEvent> keyEvents = [];
  if (recordData['keyEvents'] != null) {
    for (final eventData in recordData['keyEvents']) {
      keyEvents.add(KeyEvent(
        type: KeyEventType.values.firstWhere(
          (e) => e.name == eventData['type'],
          orElse: () => KeyEventType.timerStart,
        ),
        timestamp: DateTime.parse(eventData['timestamp'] as String),
        data: eventData['data'] as Map<String, dynamic>?,
      ));
    }
  }

  final record = PracticeRecord(
    id: recordId,
    moduleId: recordData['moduleId'] as String,
    moduleName: recordData['moduleName'] as String,
    recordType: recordType,
    completedAt: DateTime.parse(recordData['completedAt'] as String),
    totalDuration: Duration(seconds: recordData['totalDuration'] as int),
    estimatedDuration: Duration(seconds: recordData['estimatedDuration'] as int),
    taskRecords: taskRecords,
    keyEvents: keyEvents,
  );

  // 保存到历史记录
  ref.read(historyProvider.notifier).addRecord(record);

  // 显示保存成功提示
  if (mounted) {
    final s = LocaleScope.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(s.recordSaved),
        backgroundColor: WsColors.accentGreen,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// 修改_controller初始化，传入onRecordComplete回调
_controller = UnifiedTimerController(
  totalDuration: _competitionModules[_selectedModuleIndex].defaultDuration,
  onTick: () {
    setState(() {});
    UnifiedTimerPage.isTimerRunning.value = _controller.isRunning;
    if (_controller.remaining.inSeconds == 0 &&
        !_hasCompleted &&
        _controller.totalDuration.inSeconds > 0) {
      _hasCompleted = true;
      _confettiController.play();
    }
  },
  onRecordComplete: _handleRecordComplete,
);
```

只输出修改后的相关代码部分和完整的导入语句。
```

---

## 🧩 Step 6 — 添加国际化字符串

### Claude Code Prompt

```text
修改文件：lib/core/i18n/strings.dart

要求：
- 添加历史记录相关的字符串
- 添加所有语言的实现

添加内容：
// History & Analytics
String get practiceHistory;
String get history;
String get recordSaved;
String get noHistoryRecords;
String get addFirstRecord;
String get historyAnalytics;
String get performanceTrend;
String get moduleComparison;
String get totalTime;
String get averageTime;
String get bestTime;
String get efficiency;
String get speedImprovement;
String get practiceCount;
String get deleteRecord;
String get confirmDeleteRecord;
String get deleteRecordWarning;
String get viewDetails;
String get filterByModule;
String get allModules;
```

只输出添加后的完整strings.dart文件。
```

---

## ✅ Phase 2 完成标准

```text
- UnifiedTimerController集成记录保存
- UnifiedTimerPage集成历史记录
- 模块完成时自动保存记录
- 任务完成时自动保存记录
- 保存成功提示显示
- 国际化字符串添加完成
```

---

## 🚀 Phase 3 — 历史记录页面（第3周）

### Phase 3 总目标

```text
目标：
- 创建PracticeHistoryPage页面
- 实现历史记录列表显示
- 实现模块筛选功能
- 实现记录删除功能
- 实现详情查看对话框
- 保持UI风格一致
```

---

## 🧩 Step 7 — 创建历史记录卡片组件

### Claude Code Prompt

```text
创建文件：lib/features/practice_history/widgets/history_card.dart

要求：
- 显示记录基本信息（模块名、完成时间、时长）
- 显示效率评分
- 显示任务完成情况
- 使用MouseRegion实现悬停效果
- 悬停显示查看详情和删除按钮
- 使用WorldSkills主题配色
- 使用JetBrainsMono显示数字

实现框架：
import 'package:flutter/material.dart';
import '../../../core/constants/ws_colors.dart';
import '../../../core/i18n/locale_provider.dart';
import '../models/practice_record_model.dart';

class HistoryCard extends StatefulWidget {
  final PracticeRecord record;
  final VoidCallback onViewDetails;
  final VoidCallback onDelete;

  const HistoryCard({
    super.key,
    required this.record,
    required this.onViewDetails,
    required this.onDelete,
  });

  @override
  State<HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<HistoryCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final s = LocaleScope.of(context);
    final efficiency = widget.record.efficiency;

    // 确定效率颜色
    Color efficiencyColor;
    String efficiencyLabel;
    if (efficiency >= 1.2) {
      efficiencyColor = WsColors.accentGreen;
      efficiencyLabel = '${(efficiency * 100).toInt()}%';
    } else if (efficiency >= 0.9) {
      efficiencyColor = WsColors.accentCyan;
      efficiencyLabel = '${(efficiency * 100).toInt()}%';
    } else {
      efficiencyColor = WsColors.accentYellow;
      efficiencyLabel = '${(efficiency * 100).toInt()}%';
    }

    // 格式化时长
    final hours = widget.record.totalDuration.inHours;
    final minutes = widget.record.totalDuration.inMinutes % 60;
    final durationStr = hours > 0
        ? '${hours}h ${minutes}m'
        : '${minutes}m';

    // 格式化日期
    final date = widget.record.completedAt.toLocal();
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isHovered
              ? WsColors.accentCyan.withAlpha(8)
              : WsColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isHovered
                ? WsColors.accentCyan.withAlpha(60)
                : WsColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 左侧颜色条
            Container(
              width: 3,
              height: 60,
              decoration: BoxDecoration(
                color: efficiencyColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 16),
            // 中间信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 模块名和效率
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.record.moduleName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: WsColors.textPrimary,
                          ),
                        ),
                      ),
                      // 效率标签
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: efficiencyColor.withAlpha(25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          efficiencyLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: efficiencyColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // 完成时间和时长
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: WsColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        dateStr,
                        style: const TextStyle(
                          fontSize: 12,
                          color: WsColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.timer,
                        size: 14,
                        color: WsColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        durationStr,
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'JetBrainsMono',
                          fontWeight: FontWeight.w600,
                          color: WsColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.check_circle_outline,
                        size: 14,
                        color: WsColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${widget.record.completedTasks}/${widget.record.totalTasks}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: WsColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 悬停显示操作按钮
            if (_isHovered) ...[
              const SizedBox(width: 12),
              _buildActionButton(
                icon: Icons.visibility_outlined,
                color: WsColors.accentCyan,
                onTap: widget.onViewDetails,
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.delete_outline,
                color: WsColors.errorRed,
                onTap: widget.onDelete,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: color,
          ),
        ),
      ),
    );
  }
}
```

只输出该文件完整代码。
```

---

## 🧩 Step 8 — 创建历史记录详情对话框

### Claude Code Prompt

```text
创建文件：lib/features/practice_history/widgets/history_detail_dialog.dart

要求：
- 显示记录完整信息
- 显示所有任务详情
- 显示关键事件时间线
- 使用Tab切换视图（详情/任务/事件）
- 最大宽度600px
- 使用WorldSkills主题

实现框架：
import 'package:flutter/material.dart';
import '../../../core/constants/ws_colors.dart';
import '../../../core/i18n/locale_provider.dart';
import '../models/practice_record_model.dart';

class HistoryDetailDialog extends StatefulWidget {
  final PracticeRecord record;

  const HistoryDetailDialog({
    super.key,
    required this.record,
  });

  @override
  State<HistoryDetailDialog> createState() => _HistoryDetailDialogState();
}

class _HistoryDetailDialogState extends State<HistoryDetailDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = LocaleScope.of(context);

    return Dialog(
      backgroundColor: WsColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 600,
        height: 500,
        child: Column(
          children: [
            // Header
            _buildHeader(s),
            // Tab Bar
            _buildTabBar(s),
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(s),
                  _buildTasksTab(s),
                  _buildEventsTab(s),
                ],
              ),
            ),
            // Footer
            _buildFooter(s),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(dynamic s) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: WsColors.bgDeep.withAlpha(120),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: WsColors.accentCyan.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.history,
              color: WsColors.accentCyan,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.record.moduleName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: WsColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDateTime(widget.record.completedAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: WsColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // 效率评分
          _buildEfficiencyBadge(),
        ],
      ),
    );
  }

  Widget _buildEfficiencyBadge() {
    final efficiency = widget.record.efficiency;
    Color color;
    if (efficiency >= 1.2) {
      color = WsColors.accentGreen;
    } else if (efficiency >= 0.9) {
      color = WsColors.accentCyan;
    } else {
      color = WsColors.accentYellow;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Column(
        children: [
          Text(
            s.efficiency.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${(efficiency * 100).toInt()}%',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'JetBrainsMono',
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(dynamic s) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: WsColors.border),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: WsColors.accentCyan,
        unselectedLabelColor: WsColors.textSecondary,
        indicatorColor: WsColors.accentCyan,
        indicatorWeight: 2,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        tabs: [
          Tab(text: s.historyAnalytics),
          Tab(text: '${s.moduleTasks} (${widget.record.taskRecords.length})'),
          Tab(text: 'Events (${widget.record.keyEvents.length})'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(dynamic s) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 总时长
          _buildStatCard(
            icon: Icons.timer,
            label: s.totalTime,
            value: _formatDuration(widget.record.totalDuration),
            valueStyle: const TextStyle(
              fontSize: 24,
              fontFamily: 'JetBrainsMono',
              fontWeight: FontWeight.bold,
              color: WsColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          // 估算时长 vs 实际时长
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.schedule,
                  label: 'Estimated',
                  value: _formatDuration(widget.record.estimatedDuration),
                  valueStyle: const TextStyle(
                    fontSize: 18,
                    fontFamily: 'JetBrainsMono',
                    fontWeight: FontWeight.w600,
                    color: WsColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.access_time,
                  label: 'Actual',
                  value: _formatDuration(widget.record.totalDuration),
                  valueStyle: const TextStyle(
                    fontSize: 18,
                    fontFamily: 'JetBrainsMono',
                    fontWeight: FontWeight.w600,
                    color: WsColors.accentCyan,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 任务完成情况
          _buildStatCard(
            icon: Icons.check_circle_outline,
            label: s.progress.toUpperCase(),
            value: '${widget.record.completedTasks}/${widget.record.totalTasks}',
            valueStyle: const TextStyle(
              fontSize: 20,
              fontFamily: 'JetBrainsMono',
              fontWeight: FontWeight.bold,
              color: WsColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          // 平均任务时长
          _buildStatCard(
            icon: Icons.trending_up,
            label: 'Avg Task Time',
            value: _formatDuration(widget.record.averageTaskDuration),
            valueStyle: const TextStyle(
              fontSize: 18,
              fontFamily: 'JetBrainsMono',
              fontWeight: FontWeight.w600,
              color: WsColors.accentGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksTab(dynamic s) {
    if (widget.record.taskRecords.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 48,
              color: WsColors.textSecondary.withAlpha(60),
            ),
            const SizedBox(height: 12),
            Text(
              'No task records',
              style: TextStyle(
                fontSize: 14,
                color: WsColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: widget.record.taskRecords.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final task = widget.record.taskRecords[index];
        return _buildTaskItem(task);
      },
    );
  }

  Widget _buildTaskItem(TaskRecord task) {
    final efficiency = task.efficiency;
    Color efficiencyColor;
    if (efficiency >= 1.2) {
      efficiencyColor = WsColors.accentGreen;
    } else if (efficiency >= 0.9) {
      efficiencyColor = WsColors.accentCyan;
    } else {
      efficiencyColor = WsColors.accentYellow;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: WsColors.bgDeep.withAlpha(120),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 40,
            decoration: BoxDecoration(
              color: efficiencyColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.taskTitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: WsColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.timer,
                      size: 12,
                      color: WsColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDuration(task.actualSpent),
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'JetBrainsMono',
                        color: WsColors.textPrimary,
                      ),
                    ),
                    if (task.estimatedDuration != null) ...[
                      const SizedBox(width: 12),
                      Icon(
                        Icons.schedule,
                        size: 12,
                        color: WsColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDuration(task.estimatedDuration!),
                        style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'JetBrainsMono',
                          color: WsColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: efficiencyColor.withAlpha(25),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${(efficiency * 100).toInt()}%',
              style: TextStyle(
                fontSize: 11,
                fontFamily: 'JetBrainsMono',
                fontWeight: FontWeight.w700,
                color: efficiencyColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsTab(dynamic s) {
    if (widget.record.keyEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_note,
              size: 48,
              color: WsColors.textSecondary.withAlpha(60),
            ),
            const SizedBox(height: 12),
            Text(
              'No key events recorded',
              style: TextStyle(
                fontSize: 14,
                color: WsColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: widget.record.keyEvents.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final event = widget.record.keyEvents[index];
        return _buildEventItem(event);
      },
    );
  }

  Widget _buildEventItem(KeyEvent event) {
    IconData icon;
    Color color;
    String label;

    switch (event.type) {
      case KeyEventType.timerStart:
        icon = Icons.play_arrow;
        color = WsColors.accentGreen;
        label = 'Timer Started';
        break;
      case KeyEventType.timerPause:
        icon = Icons.pause;
        color = WsColors.accentYellow;
        label = 'Timer Paused';
        break;
      case KeyEventType.timerResume:
        icon = Icons.play_arrow;
        color = WsColors.accentCyan;
        label = 'Timer Resumed';
        break;
      case KeyEventType.timerStop:
        icon = Icons.stop;
        color = WsColors.errorRed;
        label = 'Timer Stopped';
        break;
      case KeyEventType.taskComplete:
        icon = Icons.check_circle;
        color = WsColors.accentGreen;
        label = 'Task Completed';
        break;
      case KeyEventType.moduleComplete:
        icon = Icons.verified;
        color = WsColors.accentGreen;
        label = 'Module Completed';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: WsColors.bgDeep.withAlpha(120),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: 16,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: WsColors.textPrimary,
                  ),
                ),
                Text(
                  _formatDateTime(event.timestamp),
                  style: const TextStyle(
                    fontSize: 10,
                    color: WsColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required TextStyle valueStyle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WsColors.bgDeep.withAlpha(120),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: WsColors.border),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: WsColors.accentCyan,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: WsColors.textSecondary,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: valueStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(dynamic s) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: WsColors.border),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              s.close.toUpperCase(),
              style: const TextStyle(
                color: WsColors.textSecondary,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}
```

只输出该文件完整代码。
```

---

## 🧩 Step 9 — 创建历史记录删除对话框

### Claude Code Prompt

```text
创建文件：lib/features/practice_history/widgets/history_delete_dialog.dart

要求：
- 显示要删除的记录信息
- 显示警告图标
- 提供取消和确认删除按钮
- 确认按钮使用红色强调危险操作
- 使用WorldSkills主题

实现框架：
import 'package:flutter/material.dart';
import '../../../core/constants/ws_colors.dart';
import '../../../core/i18n/locale_provider.dart';
import '../models/practice_record_model.dart';

class HistoryDeleteDialog extends StatelessWidget {
  final PracticeRecord record;
  final VoidCallback onConfirm;

  const HistoryDeleteDialog({
    super.key,
    required this.record,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final s = LocaleScope.of(context);

    return AlertDialog(
      backgroundColor: WsColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: WsColors.errorRed.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_rounded,
              size: 24,
              color: WsColors.errorRed,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            s.confirmDeleteRecord,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: WsColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            record.moduleName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: WsColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            _formatDateTime(record.completedAt),
            style: const TextStyle(
              fontSize: 12,
              color: WsColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            s.deleteRecordWarning,
            style: const TextStyle(
              fontSize: 13,
              color: WsColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            s.cancel,
            style: const TextStyle(
              color: WsColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: WsColors.errorRed,
            foregroundColor: WsColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            s.deleteRecord,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
```

只输出该文件完整代码。
```

---

## 🧩 Step 10 — 创建PracticeHistoryPage主页面

### Claude Code Prompt

```text
创建文件：lib/features/practice_history/practice_history_page.dart

要求：
- ConsumerStatefulWidget组件
- 显示历史记录列表
- 实现模块筛选功能
- 实现记录删除功能
- 显示空状态
- 使用WorldSkills主题
- 使用GlassPanel包装内容

实现框架：
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/ws_colors.dart';
import '../../core/i18n/locale_provider.dart';
import '../../widgets/glass_panel.dart';
import '../practice_history/providers/history_provider.dart';
import '../practice_history/widgets/history_card.dart';
import '../practice_history/widgets/history_detail_dialog.dart';
import '../practice_history/widgets/history_delete_dialog.dart';

class PracticeHistoryPage extends ConsumerStatefulWidget {
  const PracticeHistoryPage({super.key});

  @override
  ConsumerState<PracticeHistoryPage> createState() =>
      _PracticeHistoryPageState();
}

class _PracticeHistoryPageState extends ConsumerState<PracticeHistoryPage> {
  String _selectedModuleId = 'all';

  @override
  Widget build(BuildContext context) {
    final s = LocaleScope.of(context);
    final records = ref.watch(historyProvider);

    // 筛选记录
    final filteredRecords = _selectedModuleId == 'all'
        ? records
        : records.where((r) => r.moduleId == _selectedModuleId).toList();

    // 获取所有模块ID
    final moduleIds = {'all', ...records.map((r) => r.moduleId)};

    return GlassPanel(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(s, records.length),
          const SizedBox(height: 24),
          // Filter Bar
          _buildFilterBar(s, moduleIds),
          const SizedBox(height: 20),
          // Records List
          Expanded(
            child: filteredRecords.isEmpty
                ? _buildEmptyState(s)
                : _buildRecordsList(s, filteredRecords),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(dynamic s, int totalRecords) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: WsColors.accentCyan.withAlpha(25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.history,
            color: WsColors.accentCyan,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.practiceHistory.toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: WsColors.textPrimary,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${s.practiceCount}: $totalRecords',
                style: const TextStyle(
                  fontSize: 12,
                  color: WsColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        // 总统计
        _buildStatBadge(s, records),
      ],
    );
  }

  Widget _buildStatBadge(dynamic s, List<dynamic> records) {
    if (records.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalTime = records.fold<Duration>(
      Duration.zero,
      (sum, r) => sum + (r as dynamic).totalDuration,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: WsColors.accentGreen.withAlpha(15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: WsColors.accentGreen.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            s.totalTime.toUpperCase(),
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: WsColors.accentGreen,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _formatDuration(totalTime),
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'JetBrainsMono',
              fontWeight: FontWeight.bold,
              color: WsColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(dynamic s, Set<String> moduleIds) {
    return Row(
      children: [
        Icon(
          Icons.filter_list,
          size: 16,
          color: WsColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Text(
          s.filterByModule,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: WsColors.textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: moduleIds.map((moduleId) {
              final isSelected = _selectedModuleId == moduleId;
              final label = moduleId == 'all' ? s.allModules : moduleId;

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () => setState(() => _selectedModuleId = moduleId),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? WsColors.accentCyan.withAlpha(20)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSelected
                            ? WsColors.accentCyan.withAlpha(60)
                            : WsColors.textSecondary.withAlpha(40),
                      ),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? WsColors.accentCyan
                            : WsColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordsList(dynamic s, List<dynamic> records) {
    return ListView.separated(
      itemCount: records.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final record = records[index];
        return HistoryCard(
          record: record,
          onViewDetails: () => _showDetailDialog(record),
          onDelete: () => _showDeleteDialog(record),
        );
      },
    );
  }

  Widget _buildEmptyState(dynamic s) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: WsColors.textSecondary.withAlpha(60),
          ),
          const SizedBox(height: 16),
          Text(
            s.noHistoryRecords,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: WsColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            s.addFirstRecord,
            style: const TextStyle(
              fontSize: 13,
              color: WsColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailDialog(PracticeRecord record) {
    showDialog(
      context: context,
      builder: (ctx) => HistoryDetailDialog(record: record),
    );
  }

  void _showDeleteDialog(PracticeRecord record) {
    showDialog(
      context: context,
      builder: (ctx) => HistoryDeleteDialog(
        record: record,
        onConfirm: () {
          ref.read(historyProvider.notifier).deleteRecord(record.id);
        },
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}
```

只输出该文件完整代码。
```

---

## ✅ Phase 3 完成标准

```text
- HistoryCard组件创建完成
- HistoryDetailDialog创建完成
- HistoryDeleteDialog创建完成
- PracticeHistoryPage创建完成
- 记录列表显示正常
- 模块筛选功能正常
- 删除记录功能正常
- 详情查看功能正常
- 空状态显示正常
```

---

## 🚀 Phase 4 — 导航集成（第4周）

### Phase 4 总目标

```text
目标：
- 在底部导航栏添加历史记录Tab
- 更新LandscapeScaffold的pages数组
- 更新索引映射
- 更新header subtitle
- 添加Tab图标
```

---

## 🧩 Step 11 — 修改LandscapeScaffold集成历史记录页面

### Claude Code Prompt

```text
修改文件：lib/layout/landscape_scaffold.dart

要求：
- 导入PracticeHistoryPage
- 在pages数组中添加HistoryPage（索引2）
- 更新selectedIndex处理逻辑
- 更新header subtitle映射
- 添加历史记录Tab

修改要点：
1. 添加导入语句
2. 修改_pages常量，添加HistoryPage
3. 更新_buildBottomNav中的Tab数量和索引
4. 更新subtitle的switch case
5. 添加历史记录Tab的图标和标签

实现框架：
import '../features/practice_history/practice_history_page.dart';

// 修改_pages常量
static const _pages = <Widget>[
  CountdownPage(),
  UnifiedTimerPage(),
  PracticeHistoryPage(),
  TimezonePage(),
  WhiteNoisePage(),
  SettingsPage(),
];

// 修改subtitle的switch case
String subtitle;
switch (_selectedIndex) {
  case 0:
    subtitle = s.compTimerDashboard;
  case 1:
    subtitle = s.competitionSimulation;
  case 2:
    subtitle = s.practiceHistory.toUpperCase();
  case 3:
    subtitle = s.worldTimezones.toUpperCase();
  case 4:
    subtitle = s.whiteNoise.toUpperCase();
  case 5:
    subtitle = s.settings.toUpperCase();
  default:
    subtitle = s.competitionSimulation;
}

// 修改_buildBottomNav，添加历史记录Tab
return Container(
  height: 52,
  decoration: BoxDecoration(
    color: WsColors.surface,
    border: const Border(
      top: BorderSide(color: WsColors.border, width: 1),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withAlpha(8),
        blurRadius: 4,
        offset: const Offset(0, -2),
      ),
    ],
  ),
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
      _buildNavTab(2, Icons.history, s.practiceHistory),
      const SizedBox(width: 8),
      _buildNavTab(3, Icons.public_outlined, s.timezone),
      const SizedBox(width: 8),
      _buildNavTab(4, Icons.surround_sound_outlined, s.whiteNoise),
      const SizedBox(width: 8),
      // Settings icon
      Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => setState(() => _selectedIndex = 5),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _selectedIndex == 5
                  ? WsColors.accentCyan.withAlpha(20)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: _selectedIndex == 5
                  ? Border.all(color: WsColors.accentCyan.withAlpha(60))
                  : null,
            ),
            child: Icon(
              Icons.settings_outlined,
              size: 20,
              color: _selectedIndex == 5
                  ? WsColors.accentCyan
                  : WsColors.textSecondary,
            ),
          ),
        ),
      ),
    ],
  ),
);
```

只输出修改后的完整文件代码。
```

---

## ✅ Phase 4 完成标准

```text
- LandscapeScaffold导入PracticeHistoryPage
- pages数组更新完成
- 底部导航Tab添加完成
- subtitle映射更新完成
- Tab切换正常
```

---

## 🚀 Phase 5 — 可视化分析（第5周）

### Phase 5 总目标

```text
目标：
- 创建组合图表组件（折线图+柱状图）
- 显示模块练习时长趋势
- 显示速度提升曲线
- 显示对比数据
- 添加交互效果（悬停显示详情）
- 使用WorldSkills配色
```

---

## 🧩 Step 12 — 创建进度分析图表组件

### Claude Code Prompt

```text
创建文件：lib/features/practice_history/widgets/progress_chart.dart

要求：
- 使用fl_chart创建组合图表
- 折线图显示时长趋势
- 柱状图显示每次练习时长
- 同一模块多次练习对比
- 悬停显示详细数据
- 使用WorldSkills配色
- 支持平滑曲线
- 支持动画效果

实现框架：
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/ws_colors.dart';
import '../models/practice_record_model.dart';

class ProgressChart extends StatelessWidget {
  final List<PracticeRecord> records;
  final String moduleName;

  const ProgressChart({
    super.key,
    required this.records,
    required this.moduleName,
  });

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return _buildEmptyState();
    }

    // 按时间排序
    final sortedRecords = List<PracticeRecord>.from(records)
      ..sort((a, b) => a.completedAt.compareTo(b.completedAt));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: WsColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WsColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(sortedRecords),
          const SizedBox(height: 20),
          // Chart
          _buildChart(sortedRecords),
          const SizedBox(height: 20),
          // Legend
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildHeader(List<PracticeRecord> sortedRecords) {
    final firstTime = sortedRecords.first.totalDuration;
    final lastTime = sortedRecords.last.totalDuration;

    String trend;
    Color trendColor;
    IconData trendIcon;

    if (lastTime.inSeconds < firstTime.inSeconds) {
      trend = 'Improving';
      trendColor = WsColors.accentGreen;
      trendIcon = Icons.trending_down;
    } else if (lastTime.inSeconds > firstTime.inSeconds) {
      trend = 'Needs Practice';
      trendColor = WsColors.errorRed;
      trendIcon = Icons.trending_up;
    } else {
      trend = 'Stable';
      trendColor = WsColors.accentYellow;
      trendIcon = Icons.trending_flat;
    }

    return Row(
      children: [
        Icon(
          Icons.show_chart,
          size: 20,
          color: WsColors.accentCyan,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                moduleName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: WsColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${sortedRecords.length} sessions',
                style: const TextStyle(
                  fontSize: 11,
                  color: WsColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: trendColor.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: trendColor.withAlpha(60)),
          ),
          child: Row(
            children: [
              Icon(
                trendIcon,
                size: 14,
                color: trendColor,
              ),
              const SizedBox(width: 6),
              Text(
                trend,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: trendColor,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChart(List<PracticeRecord> sortedRecords) {
    // 准备数据点
    final spots = sortedRecords.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final duration = entry.value.totalDuration.inMinutes.toDouble();
      return FlSpot(index, duration);
    }).toList();

    // 准备柱状图数据
    final barData = sortedRecords.asMap().entries.map((entry) {
      final index = entry.key;
      final duration = entry.value.totalDuration.inMinutes.toDouble();
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: duration,
            color: WsColors.secondaryMint.withAlpha(180),
            width: 12,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();

    return SizedBox(
      height: 250,
      child: Stack(
        children: [
          // 折线图
          LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 30,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: WsColors.border.withAlpha(80),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= sortedRecords.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '#${value.toInt() + 1}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: WsColors.textSecondary,
                          ),
                        ),
                      );
                    },
                    reservedSize: 30,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 30,
                    getTitlesWidget: (value, meta) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          '${value.toInt()}m',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: WsColors.textSecondary,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: false,
              ),
              minX: 0,
              maxX: (sortedRecords.length - 1).toDouble(),
              minY: 0,
              maxY: _calculateMaxY(sortedRecords),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: WsColors.accentCyan,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 5,
                        color: WsColors.surface,
                        strokeWidth: 2,
                        strokeColor: WsColors.accentCyan,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: WsColors.accentCyan.withAlpha(15),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (touchedSpot) =>
                      WsColors.darkBlue.withAlpha(230),
                  tooltipRoundedRadius: 8,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final index = spot.x.toInt();
                      if (index >= sortedRecords.length) {
                        return null;
                      }
                      final record = sortedRecords[index];
                      return LineTooltipItem(
                        '${record.totalDuration.inMinutes}m\n${_formatDate(record.completedAt)}',
                        const TextStyle(
                          color: WsColors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList();
                  },
                ),
                touchCallback: (FlTouchEvent event, lineTouchResponse) {},
                handleBuiltInTouches: true,
              ),
            ),
          ),
          // 柱状图（叠加在折线图下方）
          BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: _calculateMaxY(sortedRecords),
              minY: 0,
              groupsSpace: 12,
              barGroups: barData,
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                show: false,
              ),
              borderData: FlBorderData(show: false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(
          color: WsColors.accentCyan,
          label: 'Trend',
        ),
        const SizedBox(width: 24),
        _buildLegendItem(
          color: WsColors.secondaryMint.withAlpha(180),
          label: 'Duration',
        ),
      ],
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: WsColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: WsColors.bgDeep.withAlpha(120),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: 48,
              color: WsColors.textSecondary.withAlpha(60),
            ),
            const SizedBox(height: 12),
            Text(
              'No data to display',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: WsColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateMaxY(List<PracticeRecord> records) {
    final maxMinutes = records
        .map((r) => r.totalDuration.inMinutes.toDouble())
        .reduce((a, b) => a > b ? a : b);
    return ((maxMinutes / 30).ceil() * 30).toDouble();
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
}
```

只输出该文件完整代码。
```

---

## 🧩 Step 13 — 修改PracticeHistoryPage集成图表

### Claude Code Prompt

```text
修改文件：lib/features/practice_history/practice_history_page.dart

要求：
- 在历史记录页面上方添加图表区域
- 显示选定模块的进度分析
- 使用Tab切换视图（列表/图表）
- 图表区域使用ProgressChart组件
- 保持UI风格一致

修改要点：
1. 添加TabController
2. 添加视图切换按钮
3. 在列表视图上方显示图表
4. 使用ProgressChart组件

实现框架：
// 在_UnifiedTimerPageState类中添加
late TabController _tabController;

@override
void initState() {
  super.initState();
  _tabController = TabController(length: 2, vsync: this);
}

@override
void dispose() {
  _tabController.dispose();
  super.dispose();
}

// 修改build方法中的布局
Widget build(BuildContext context) {
  final s = LocaleScope.of(context);
  final records = ref.watch(historyProvider);

  final filteredRecords = _selectedModuleId == 'all'
      ? records
      : records.where((r) => r.moduleId == _selectedModuleId).toList();

  final moduleIds = {'all', ...records.map((r) => r.moduleId)};

  return GlassPanel(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        _buildHeader(s, records.length),
        const SizedBox(height: 16),
        // Tab Bar
        _buildTabBar(s),
        const SizedBox(height: 20),
        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Analytics Tab
              _buildAnalyticsTab(s, filteredRecords),
              // Records Tab
              _buildRecordsTab(s, filteredRecords, moduleIds),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildTabBar(dynamic s) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: WsColors.bgDeep.withAlpha(120),
      borderRadius: BorderRadius.circular(8),
    ),
    child: TabBar(
      controller: _tabController,
      labelColor: WsColors.accentCyan,
      unselectedLabelColor: WsColors.textSecondary,
      indicatorColor: WsColors.accentCyan,
      indicatorWeight: 2,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      tabs: [
        Tab(text: s.historyAnalytics),
        Tab(text: s.history),
      ],
    ),
  );
}

Widget _buildAnalyticsTab(dynamic s, List<dynamic> filteredRecords) {
  if (_selectedModuleId == 'all') {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pie_chart,
            size: 48,
            color: WsColors.textSecondary.withAlpha(60),
          ),
          const SizedBox(height: 12),
          Text(
            'Select a module to view analytics',
            style: TextStyle(
              fontSize: 14,
              color: WsColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  final moduleName = filteredRecords.isNotEmpty
      ? filteredRecords.first.moduleName
      : _selectedModuleId;

  return ProgressChart(
    records: filteredRecords.cast<PracticeRecord>(),
    moduleName: moduleName,
  );
}

Widget _buildRecordsTab(dynamic s, List<dynamic> filteredRecords, Set<String> moduleIds) {
  return Column(
    children: [
      // Filter Bar
      _buildFilterBar(s, moduleIds),
      const SizedBox(height: 20),
      // Records List
      Expanded(
        child: filteredRecords.isEmpty
            ? _buildEmptyState(s)
            : _buildRecordsList(s, filteredRecords),
      ),
    ],
  );
}
```

只输出修改后的相关代码部分。
```

---

## ✅ Phase 5 完成标准

```text
- ProgressChart组件创建完成
- 图表显示正常
- 折线图显示趋势
- 柱状图显示数值
- 悬停显示详情
- 动画效果流畅
- Tab切换正常
```

---

## 🚀 Phase 6 — 完善和优化（第6周）

### Phase 6 总目标

```text
目标：
- 添加所有语言的国际化字符串
- 实现动画效果
- 性能优化
- 全面功能测试
- 文档完善
```

---

## 🧩 Step 14 — 完善所有语言的国际化字符串

### Claude Code Prompt

```text
修改以下文件，添加历史记录相关的字符串：
- lib/core/i18n/zh.dart
- lib/core/i18n/en.dart
- lib/core/i18n/ja.dart
- lib/core/i18n/de.dart
- lib/core/i18n/fr.dart
- lib/core/i18n/ko.dart

要求：
- 为每个语言实现历史记录相关的字符串
- 保持风格一致
- 翻译准确

添加内容：
// History & Analytics
@override
String get practiceHistory => '练习历史'; // 各语言翻译
@override
String get history => '历史';
@override
String get recordSaved => '记录已保存';
@override
String get noHistoryRecords => '暂无历史记录';
@override
String get addFirstRecord => '开始练习以创建第一条记录';
@override
String get historyAnalytics => '进度分析';
@override
String get performanceTrend => '性能趋势';
@override
String get moduleComparison => '模块对比';
@override
String get totalTime => '总时长';
@override
String get averageTime => '平均时长';
@override
String get bestTime => '最佳时长';
@override
String get efficiency => '效率';
@override
String get speedImprovement => '速度提升';
@override
String get practiceCount => '练习次数';
@override
String get deleteRecord => '删除记录';
@override
String get confirmDeleteRecord => '确认删除';
@override
String get deleteRecordWarning => '此操作无法撤销';
@override
String get viewDetails => '查看详情';
@override
String get filterByModule => '按模块筛选';
@override
String get allModules => '全部模块';
@override
String get moduleCompleted => '模块完成';
```

只为每个语言文件输出添加后的完整代码。
```

---

## 🧩 Step 15 — 添加动画效果

### Claude Code Prompt

```text
修改文件：lib/features/practice_history/widgets/history_card.dart

要求：
- 添加卡片进入动画
- 添加悬停效果动画
- 添加删除动画
- 使用AnimatedOpacity和AnimatedContainer

修改要点：
1. 使用AnimatedContainer包装
2. 添加悬停时的背景色动画
3. 添加淡入效果
4. 优化动画曲线

实现框架：
// 修改build方法中的AnimatedContainer
return AnimatedOpacity(
  opacity: _isHovered ? 0.95 : 1.0,
  duration: const Duration(milliseconds: 200),
  child: AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    curve: Curves.easeInOut,
    transform: Matrix4.identity()
      ..scale(_isHovered ? 1.01 : 1.0),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _isHovered
          ? WsColors.accentCyan.withAlpha(8)
          : WsColors.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: _isHovered
            ? WsColors.accentCyan.withAlpha(60)
            : WsColors.border,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(8),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      // ... 现有内容 ...
    ),
  ),
);
```

只输出修改后的相关代码部分。
```

---

## 🧩 Step 16 — 功能测试

### 测试清单

```text
记录保存测试：
✅ 模块完成时自动保存
✅ 任务完成时自动保存
✅ 计时停止时保存
✅ 记录数据完整
✅ 记录顺序正确

历史记录页面测试：
✅ 记录列表显示正常
✅ 模块筛选功能正常
✅ 空状态显示正常
✅ 详情查看正常
✅ 删除记录正常
✅ 统计数据正确

图表功能测试：
✅ 折线图显示正确
✅ 柱状图显示正确
✅ 悬停显示详情
✅ 动画流畅
✅ 数据更新及时
✅ 多模块切换正常

导航集成测试：
✅ Tab切换正常
✅ Header更新正确
✅ 图标显示正常
✅ 索引映射正确

国际化测试：
✅ 中文字符串显示
✅ 英文字符串显示
✅ 其他语言显示

性能测试：
✅ 列表滚动流畅
✅ 图表渲染流畅
✅ 动画流畅（> 60fps）
✅ 内存使用合理
```

运行测试：
```bash
flutter test
flutter analyze
```

---

## ✅ Phase 6 完成标准

```text
- 所有语言国际化字符串添加完成
- 动画效果流畅
- 性能优化完成（> 60fps）
- 所有功能测试通过
- 边界情况处理正确
- 用户体验良好
```

---

## 📊 总体验收标准

### 功能完整性

```text
✅ 练习记录自动保存
✅ 历史记录查看功能
✅ 记录删除功能
✅ 记录详情查看
✅ 模块筛选功能
✅ 进度分析图表
✅ 数据持久化
✅ 导航集成完成
```

### 用户体验

```text
✅ 操作直观易学（< 5分钟）
✅ 交互流畅（> 60fps）
✅ 视觉反馈及时
✅ 动画自然流畅
✅ 图表清晰易读
✅ 错误提示清晰
```

### 性能指标

```text
✅ 记录保存 < 100ms
✅ 列表加载 < 200ms
✅ 图表渲染 < 300ms
✅ 动画流畅度 60fps
✅ 内存使用合理
```

### 代码质量

```text
✅ flutter analyze无警告
✅ 代码格式规范
✅ 注释完整清晰
✅ 组件可复用
✅ 架构清晰合理
```

### 测试覆盖

```text
✅ 功能测试通过
✅ 边界情况测试通过
✅ 性能测试达标
✅ 持久化测试稳定
```

---

## 🎯 风险与应对

### 潜在风险

1. **数据持久化失败**
   - 风险：SharedPreferences异常
   - 应对：异常捕获，使用空列表

2. **JSON序列化错误**
   - 风险：DateTime格式不兼容
   - 应对：使用ISO8601标准格式

3. **状态同步问题**
   - 风险：UI更新不及时
   - 应对：使用Riverpod自动通知

4. **图表性能问题**
   - 风险：大量数据时卡顿
   - 应对：限制显示数量，使用虚拟化

5. **动画卡顿**
   - 风险：复杂动画导致性能下降
   - 应对：优化动画参数，使用缓动函数

---

## 📅 时间线总览

| 阶段 | 周次 | 主要任务 | 交付物 |
|------|------|----------|--------|
| Phase 1 | 第1周 | 数据模型和持久化层 | 模型、状态管理、依赖 |
| Phase 2 | 第2周 | 记录保存集成 | 控制器修改、保存逻辑 |
| Phase 3 | 第3周 | 历史记录页面 | UI组件、列表、对话框 |
| Phase 4 | 第4周 | 导航集成 | Tab添加、导航更新 |
| Phase 5 | 第5周 | 可视化分析 | 图表组件、分析功能 |
| Phase 6 | 第6周 | 完善和优化 | 国际化、动画、测试 |

**总工期：6周**

---

## 🎓 总结

这份执行计划通过分阶段、渐进式的方式，为SkillCount添加完整的练习历史记录和进度分析功能。采用组合图表（折线图+柱状图）展示进度趋势，新增独立Tab在底部导航栏，使用详细级别的记录保存，确保功能完整性和用户体验。

### 核心价值

1. **功能完整**：记录保存、查看、删除、分析全覆盖
2. **数据持久化**：使用SharedPreferences，应用重启数据保留
3. **可视化分析**：组合图表展示趋势和数值
4. **用户体验**：直观操作，流畅动画，及时反馈
5. **架构清晰**：组件解耦，易于维护和测试
6. **设计一致**：保持WorldSkills主题和Material 3风格

### 关键成功因素

- 严格按照计划执行
- 每个阶段充分测试
- 持续性能优化
- 及时风险评估与应对
- 保持与现有功能的一致性

### 技术亮点

- **详细级别记录**：模块+任务+关键事件三级记录
- **组合图表**：fl_chart实现折线图+柱状图
- **状态管理**：Riverpod提供响应式状态
- **持久化**：SharedPreferences + JSON序列化
- **国际化**：支持6种语言
- **动画效果**：流畅的过渡和悬停效果

祝项目顺利！🚀
