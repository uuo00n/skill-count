# Milestone Management Feature - 里程碑编辑功能执行计划

## 📋 执行目标

### 当前问题分析

里程碑功能现状：

**MilestoneList**：
- ✅ 显示4个固定里程碑
- ❌ 数据硬编码在代码中
- ❌ 没有状态管理机制
- ❌ 无法修改任何信息

**MilestoneCard**：
- ✅ 显示里程碑标题和日期
- ✅ 计算剩余天数
- ✅ 状态标签（已完成/即将到来）
- ❌ 没有编辑入口
- ❌ 没有删除功能
- ❌ 悬停无交互反馈

**MilestoneModel**：
- ✅ 基础模型（标题、目标时间）
- ❌ 缺少ID字段（无法唯一标识）
- ❌ 缺少描述字段
- ❌ 缺少完成状态字段
- ❌ 缺少优先级字段

### 重构目标

```text
目标：
- 实现里程碑CRUD操作
- 支持编辑里程碑标题和日期
- 支持删除里程碑
- 支持添加新里程碑
- 添加状态管理机制
- 保持现有UI风格一致性
```

------

## 🎨 设计方案选择

### 交互模式：悬停按钮方案

**与任务管理保持一致**：
```
里程碑卡片默认显示：
┌──────────────────────────┐
│ [UPCOMING] 里程碑标题    │
│ Mar 31, 2026           │
│                        │
│         180 days        │
└──────────────────────────┘

悬停时显示操作按钮：
┌──────────────────────────┐
│ [UPCOMING] 里程碑 [✏️][🗑️]│
│ Mar 31, 2026           │
│                        │
│         180 days        │
└──────────────────────────┘
```

### 顶部添加按钮
在MilestoneList的header旁边显示：

```
🚩 关键里程碑 [+]
```

点击"+"按钮弹出新建里程碑对话框。

------

## 🚀 Phase 1 — 数据模型和状态管理（第1周）

### Phase 1 总目标

```text
目标：
- 扩展MilestoneModel
- 创建里程碑状态管理
- 更新MilestoneList使用状态
- 数据持久化基础
```

------

## 🧩 Step 1 — 扩展MilestoneModel

### Claude Code Prompt

```text
修改文件：lib/features/milestones/milestone_model.dart

要求：
- 添加id字段（String，唯一标识）
- 添加description字段（String，可选）
- 添加isCompleted字段（bool，自动计算或手动标记）
- 添加priority字段（int，排序优先级）
- 添加createdAt字段（DateTime，创建时间）
- 修改为可变模型（支持编辑）
- 添加copyWith方法用于不可变更新

实现框架：
class Milestone {
  final String id;
  String title;
  DateTime targetTime;
  String? description;
  bool isCompleted;
  int priority;
  final DateTime createdAt;

  Milestone({
    required this.id,
    required this.title,
    required this.targetTime,
    this.description,
    this.isCompleted = false,
    this.priority = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // 计算是否已过期
  bool get isPast => DateTime.now().isAfter(targetTime);

  // 根据过期状态自动更新完成状态
  void updateCompletionStatus() {
    if (isPast && !isCompleted) {
      isCompleted = true;
    }
  }

  // 创建副本（用于不可变更新）
  Milestone copyWith({
    String? id,
    String? title,
    DateTime? targetTime,
    String? description,
    bool? isCompleted,
    int? priority,
    DateTime? createdAt,
  }) {
    return Milestone(
      id: id ?? this.id,
      title: title ?? this.title,
      targetTime: targetTime ?? this.targetTime,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // 工厂方法：创建示例里程碑
  static List<Milestone> getDefaultMilestones() {
    return [
      Milestone(
        id: 'reg_deadline',
        title: 'Registration Deadline',
        targetTime: DateTime.utc(2026, 3, 31, 16, 0, 0),
        priority: 1,
      ),
      Milestone(
        id: 'tech_desc',
        title: 'Technical Description',
        targetTime: DateTime.utc(2026, 6, 1, 0, 0, 0),
        priority: 2,
      ),
      Milestone(
        id: 'toolbox',
        title: 'Toolbox Check',
        targetTime: DateTime.utc(2026, 9, 2, 0, 0, 0),
        priority: 3,
      ),
      Milestone(
        id: 'infra_setup',
        title: 'Infrastructure Setup',
        targetTime: DateTime.utc(2026, 9, 15, 0, 0, 0),
        priority: 4,
      ),
    ];
  }
}
```

只输出修改后的完整文件代码。
```

------

## 🧩 Step 2 — 创建里程碑状态管理

### Claude Code Prompt

```text
创建文件：lib/features/milestones/milestone_state.dart

要求：
- StatefulWidget组件作为状态容器
- 管理里程碑列表状态
- 提供添加/编辑/删除方法
- 自动持久化到SharedPreferences
- 提供更新回调通知子组件

实现框架：
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'milestone_model.dart';

class MilestoneState extends StatefulWidget {
  final Widget child;
  final VoidCallback? onUpdate;

  const MilestoneState({
    super.key,
    required this.child,
    this.onUpdate,
  });

  @override
  State<MilestoneState> createState() => _MilestoneStateState();

  static _MilestoneStateState? of(BuildContext context) {
    return context.findAncestorStateOfType<_MilestoneStateState>();
  }
}

class _MilestoneStateState extends State<MilestoneState> {
  List<Milestone> _milestones = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMilestones();
  }

  // 从SharedPreferences加载
  Future<void> _loadMilestones() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final milestoneJson = prefs.getString('milestones');

      if (milestoneJson != null && milestoneJson.isNotEmpty) {
        // TODO: 解析JSON并恢复里程碑列表
        // 这里先使用默认值
        _milestones = Milestone.getDefaultMilestones();
      } else {
        _milestones = Milestone.getDefaultMilestones();
      }

      // 更新完成状态
      for (final milestone in _milestones) {
        milestone.updateCompletionStatus();
      }
    } catch (e) {
      _milestones = Milestone.getDefaultMilestones();
    }

    setState(() => _isLoading = false);
  }

  // 保存到SharedPreferences
  Future<void> _saveMilestones() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // TODO: 将里程碑列表序列化为JSON
      // prefs.setString('milestones', jsonEncode(milestonesJson));
    } catch (e) {
      print('Failed to save milestones: $e');
    }
  }

  // 获取里程碑列表
  List<Milestone> get milestones => _milestones;

  // 添加里程碑
  void addMilestone(Milestone milestone) {
    setState(() {
      _milestones.add(milestone);
      _sortMilestones();
    });
    _saveMilestones();
    widget.onUpdate?.call();
  }

  // 更新里程碑
  void updateMilestone(Milestone updatedMilestone) {
    setState(() {
      final index = _milestones.indexWhere((m) => m.id == updatedMilestone.id);
      if (index != -1) {
        _milestones[index] = updatedMilestone;
        _sortMilestones();
      }
    });
    _saveMilestones();
    widget.onUpdate?.call();
  }

  // 删除里程碑
  void deleteMilestone(String milestoneId) {
    setState(() {
      _milestones.removeWhere((m) => m.id == milestoneId);
    });
    _saveMilestones();
    widget.onUpdate?.call();
  }

  // 按优先级和时间排序
  void _sortMilestones() {
    _milestones.sort((a, b) {
      if (a.priority != b.priority) {
        return a.priority.compareTo(b.priority);
      }
      return a.targetTime.compareTo(b.targetTime);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
```

只输出该文件完整代码。
```

------

## 🧩 Step 3 — 修改MilestoneList使用状态管理

### Claude Code Prompt

```text
修改文件：lib/features/milestones/milestone_list.dart

要求：
- 使用MilestoneState获取里程碑列表
- 移除硬编码的里程碑数据
- 添加"添加里程碑"按钮
- 添加监听器处理更新
- 处理加载状态

修改要点：
1. 改为StatefulWidget以使用MilestoneState
2. 在build方法中通过MilestoneState.of获取状态
3. 添加头部添加按钮
4. 实现添加、编辑、删除回调
5. 显示加载状态

实现框架：
import 'package:flutter/material.dart';
import '../../core/constants/ws_colors.dart';
import '../../core/i18n/locale_provider.dart';
import 'milestone_model.dart';
import 'milestone_card.dart';
import 'milestone_state.dart';

class MilestoneList extends StatefulWidget {
  const MilestoneList({super.key});

  @override
  State<MilestoneList> createState() => _MilestoneListState();
}

class _MilestoneListState extends State<MilestoneList> {
  @override
  Widget build(BuildContext context) {
    final s = LocaleScope.of(context);
    final milestoneState = MilestoneState.of(context);

    if (milestoneState == null) {
      return const SizedBox.shrink();
    }

    final milestones = milestoneState.milestones;

    return MilestoneState(
      onUpdate: () => setState(() {}),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(
                Icons.flag_outlined,
                size: 16,
                color: WsColors.accentCyan,
              ),
              const SizedBox(width: 8),
              Text(
                s.keyMilestones,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: WsColors.textPrimary,
                ),
              ),
              const Spacer(),
              // 添加里程碑按钮
              _buildAddButton(s),
            ],
          ),
          const SizedBox(height: 16),
          // Milestone list
          Expanded(
            child: milestones.isEmpty
                ? _buildEmptyState(s)
                : ListView.separated(
                    itemCount: milestones.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      return MilestoneCard(
                        milestone: milestones[index],
                        onEdit: (milestone) => _showEditDialog(milestone),
                        onDelete: (milestoneId) => _showDeleteDialog(milestoneId),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(dynamic s) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _showAddDialog(s),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: WsColors.accentCyan.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: WsColors.accentCyan.withAlpha(60),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.add,
                size: 14,
                color: WsColors.accentCyan,
              ),
              const SizedBox(width: 4),
              Text(
                s.addMilestone,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: WsColors.accentCyan,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(dynamic s) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flag_outlined,
            size: 48,
            color: WsColors.textSecondary.withAlpha(60),
          ),
          const SizedBox(height: 12),
          Text(
            s.noMilestones,
            style: const TextStyle(
              fontSize: 14,
              color: WsColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            s.addFirstMilestone,
            style: const TextStyle(
              fontSize: 12,
              color: WsColors.accentCyan,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(dynamic s) {
    // TODO: 实现添加对话框
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.addMilestone),
        content: Text('添加里程碑功能将在Phase 2实现'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.close),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Milestone milestone) {
    // TODO: 实现编辑对话框
  }

  void _showDeleteDialog(String milestoneId) {
    // TODO: 实现删除确认对话框
  }
}
```

只输出修改后的完整文件代码。
```

------

## 🧩 Step 4 — 添加shared_preferences依赖

### Claude Code Prompt

```text
修改文件：pubspec.yaml

要求：
- 添加shared_preferences依赖
- 版本使用^2.2.2

添加内容：
dependencies:
  # ... 现有依赖 ...
  shared_preferences: ^2.2.2
```

只输出添加依赖后的dependencies部分。
```

------

## ✅ Phase 1 完成标准

```text
- MilestoneModel扩展完成
- MilestoneState状态管理创建
- MilestoneList使用状态管理
- 数据可加载和保存
- 添加按钮显示
- 空状态处理
```

------

## 🚀 Phase 2 — 编辑和删除功能（第2周）

### Phase 2 总目标

```text
目标：
- 创建里程碑编辑对话框
- 创建里程碑删除确认对话框
- 在MilestoneCard中添加编辑/删除按钮
- 实现完整的CRUD操作
```

------

## 🧩 Step 5 — 创建里程碑编辑对话框

### Claude Code Prompt

```text
创建文件：lib/features/milestones/milestone_edit_dialog.dart

要求：
- StatefulWidget组件
- 支持新建和编辑两种模式
- 提供标题输入框
- 提供日期时间选择器
- 提供描述输入框（可选）
- 提供优先级选择器
- 包含取消和保存按钮
- 使用WorldSkills主题
- 对话框最大宽度400px

实现框架：
import 'package:flutter/material.dart';
import '../../../core/constants/ws_colors.dart';
import '../../../core/i18n/locale_provider.dart';
import 'milestone_model.dart';

class MilestoneEditDialog extends StatefulWidget {
  final Milestone? milestone;        // null表示新建，非null表示编辑
  final Function(Milestone) onSave;  // 保存回调

  const MilestoneEditDialog({
    super.key,
    this.milestone,
    required this.onSave,
  });

  @override
  State<MilestoneEditDialog> createState() => _MilestoneEditDialogState();
}

class _MilestoneEditDialogState extends State<MilestoneEditDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late int _selectedPriority;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.milestone?.title ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.milestone?.description ?? '',
    );
    _selectedDate = widget.milestone?.targetTime ?? DateTime.now();
    _selectedPriority = widget.milestone?.priority ?? 0;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_titleController.text.trim().isEmpty) return;

    final milestone = Milestone(
      id: widget.milestone?.id ?? 'milestone_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      targetTime: _selectedDate,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      priority: _selectedPriority,
      isCompleted: widget.milestone?.isCompleted ?? false,
      createdAt: widget.milestone?.createdAt,
    );

    widget.onSave(milestone);
    Navigator.of(context).pop();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      // 选择时间
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );

      if (time != null) {
        setState(() {
          _selectedDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = LocaleScope.of(context);
    final isEditMode = widget.milestone != null;

    return AlertDialog(
      backgroundColor: WsColors.surface,
      title: Text(
        isEditMode ? s.editMilestone : s.addMilestone,
        style: const TextStyle(
          color: WsColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 里程碑标题
            Text(
              s.milestoneTitle,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: WsColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              autofocus: true,
              style: const TextStyle(
                color: WsColors.textPrimary,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: s.enterMilestoneTitle,
                hintStyle: const TextStyle(
                  color: WsColors.textSecondary,
                ),
                filled: true,
                fillColor: WsColors.bgDeep.withAlpha(80),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: WsColors.accentCyan,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 目标日期时间
            Text(
              s.targetDateTime,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: WsColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: WsColors.bgDeep.withAlpha(80),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: WsColors.textSecondary.withAlpha(40),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: WsColors.accentCyan,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _formatDateTime(_selectedDate),
                        style: const TextStyle(
                          fontSize: 14,
                          color: WsColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.arrow_drop_down,
                        color: WsColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 优先级
            Text(
              s.priority,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: WsColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (index) {
                final isSelected = _selectedPriority == index;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTap: () => setState(() => _selectedPriority = index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? WsColors.accentCyan.withAlpha(30)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isSelected
                                  ? WsColors.accentCyan
                                  : WsColors.textSecondary.withAlpha(40),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? WsColors.accentCyan
                                    : WsColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
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
          onPressed: _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: WsColors.accentCyan,
            foregroundColor: WsColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            s.save,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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

------

## 🧩 Step 6 — 创建里程碑删除确认对话框

### Claude Code Prompt

```text
创建文件：lib/features/milestones/milestone_delete_dialog.dart

要求：
- StatelessWidget组件
- 显示里程碑标题
- 显示警告图标
- 显示目标日期
- 提供取消和确认删除按钮
- 确认按钮使用红色强调危险操作
- 使用WorldSkills主题

实现框架：
import 'package:flutter/material.dart';
import '../../../core/constants/ws_colors.dart';
import '../../../core/i18n/locale_provider.dart';

class MilestoneDeleteDialog extends StatelessWidget {
  final String milestoneTitle;
  final DateTime targetTime;
  final VoidCallback onConfirm;

  const MilestoneDeleteDialog({
    super.key,
    required this.milestoneTitle,
    required this.targetTime,
    required this.onConfirm,
  });

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

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
            child: Icon(
              Icons.warning_rounded,
              size: 24,
              color: WsColors.errorRed,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            s.confirmDeleteMilestone,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: WsColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            milestoneTitle,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: WsColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            _formatDate(targetTime),
            style: const TextStyle(
              fontSize: 12,
              color: WsColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            s.deleteMilestoneWarning,
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
            s.confirmDelete,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }
}
```

只输出该文件完整代码。
```

------

## 🧩 Step 7 — 修改MilestoneCard添加编辑删除按钮

### Claude Code Prompt

```text
修改文件：lib/features/milestones/milestone_card.dart

要求：
- 改为接收onEdit和onDelete回调
- 添加MouseRegion监听悬停状态
- 悬停时显示编辑和删除按钮
- 保持现有显示逻辑
- 点击编辑/删除按钮时调用回调

修改要点：
1. 添加onEdit和onDelete回调参数
2. 添加hovered状态（使用StatefulWidget）
3. MouseRegion包装整个卡片
4. 悬停时显示操作按钮
5. 创建操作图标按钮组件

实现框架：
import 'package:flutter/material.dart';
import '../../core/constants/ws_colors.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/utils/time_utils.dart';
import 'milestone_model.dart';

class MilestoneCard extends StatefulWidget {
  final Milestone milestone;
  final Function(Milestone)? onEdit;
  final Function(String)? onDelete;

  const MilestoneCard({
    super.key,
    required this.milestone,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<MilestoneCard> createState() => _MilestoneCardState();
}

class _MilestoneCardState extends State<MilestoneCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final s = LocaleScope.of(context);
    final remaining = TimeUtils.timeLeft(widget.milestone.targetTime);
    final days = remaining.inDays;
    final isPast = remaining == Duration.zero;

    final statusLabel = isPast ? s.completed : s.upcoming;
    final statusColor = isPast ? WsColors.accentGreen : WsColors.accentYellow;

    // Format target date
    final target = widget.milestone.targetTime.toLocal();
    final dateStr =
        '${_monthName(target.month)} ${target.day.toString().padLeft(2, '0')}, ${target.year}';

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: WsColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: WsColors.border,
          ),
        ),
        child: Row(
          children: [
            // Left color bar
            Container(
              width: 3,
              height: 44,
              decoration: BoxDecoration(
                color: isPast ? WsColors.accentGreen : WsColors.accentRed,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            // Middle info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      statusLabel.toUpperCase(),
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.milestone.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: WsColors.textPrimary,
                          ),
                        ),
                      ),
                      // 悬停显示操作按钮
                      if (_isHovered && widget.onEdit != null) ...[
                        const SizedBox(width: 8),
                        _buildActionButton(
                          icon: Icons.edit_outlined,
                          color: WsColors.accentCyan,
                          onTap: () => widget.onEdit!(widget.milestone),
                        ),
                      ],
                      if (_isHovered && widget.onDelete != null) ...[
                        const SizedBox(width: 4),
                        _buildActionButton(
                          icon: Icons.delete_outline,
                          color: WsColors.errorRed,
                          onTap: () => widget.onDelete!(widget.milestone.id),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateStr,
                    style: const TextStyle(
                      fontSize: 11,
                      color: WsColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Right days count
            Text(
              isPast ? '--' : days.toString().padLeft(2, '0'),
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isPast
                    ? WsColors.textSecondary
                    : WsColors.textPrimary,
              ),
            ),
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
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 14,
            color: color,
          ),
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month - 1];
  }
}
```

只输出修改后的完整文件代码。
```

------

## 🧩 Step 8 — 完善MilestoneList的对话框调用

### Claude Code Prompt

```text
修改文件：lib/features/milestones/milestone_list.dart

要求：
- 实现完整的_addMilestone方法
- 实现_editMilestone方法
- 实现_deleteMilestone方法
- 使用MilestoneEditDialog和MilestoneDeleteDialog
- 通过MilestoneState更新数据

实现框架：
import 'package:flutter/material.dart';
import '../../core/constants/ws_colors.dart';
import '../../core/i18n/locale_provider.dart';
import 'milestone_model.dart';
import 'milestone_card.dart';
import 'milestone_state.dart';
import 'milestone_edit_dialog.dart';
import 'milestone_delete_dialog.dart';

// ... 在类中添加以下方法 ...

void _showAddDialog(dynamic s) {
  final milestoneState = MilestoneState.of(context);
  if (milestoneState == null) return;

  showDialog(
    context: context,
    builder: (ctx) => MilestoneEditDialog(
      onSave: (newMilestone) {
        milestoneState.addMilestone(newMilestone);
      },
    ),
  );
}

void _showEditDialog(Milestone milestone) {
  final milestoneState = MilestoneState.of(context);
  if (milestoneState == null) return;

  showDialog(
    context: context,
    builder: (ctx) => MilestoneEditDialog(
      milestone: milestone,
      onSave: (updatedMilestone) {
        milestoneState.updateMilestone(updatedMilestone);
      },
    ),
  );
}

void _showDeleteDialog(String milestoneId) {
  final milestoneState = MilestoneState.of(context);
  if (milestoneState == null) return;

  final milestone = milestoneState.milestones
      .firstWhere((m) => m.id == milestoneId);

  final s = LocaleScope.of(context);

  showDialog(
    context: context,
    builder: (ctx) => MilestoneDeleteDialog(
      milestoneTitle: milestone.title,
      targetTime: milestone.targetTime,
      onConfirm: () {
        milestoneState.deleteMilestone(milestoneId);
      },
    ),
  );
}
```

只输出修改后的MilestoneList类完整代码。
```

------

## ✅ Phase 2 完成标准

```text
- MilestoneEditDialog创建完成
- MilestoneDeleteDialog创建完成
- MilestoneCard悬停显示编辑删除按钮
- 完整的CRUD操作实现
- 状态管理正常工作
- 数据可持久化
```

------

## 🚀 Phase 3 — 扩展功能和完善（第3周）

### Phase 3 总目标

```text
目标：
- 添加描述显示
- 实现拖拽排序
- 添加里程碑详情视图
- 优化UI和交互
```

------

## 🧩 Step 9 — 添加描述显示

### Claude Code Prompt

```text
修改文件：lib/features/milestones/milestone_card.dart

要求：
- 在里程碑卡片中显示描述（如果有）
- 描述显示在标题下方
- 描述样式使用较小字号
- 保持卡片高度合理

修改要点：
1. 检查milestone.description是否存在
2. 如果存在，添加描述Text
3. 使用适当的样式和颜色
4. 添加间距

实现框架：
// 在build方法中的Column children中添加

// ... 标题Text ...
if (widget.milestone.description != null && widget.milestone.description!.isNotEmpty) ...[
  const SizedBox(height: 4),
  Text(
    widget.milestone.description!,
    style: const TextStyle(
      fontSize: 11,
      color: WsColors.textSecondary,
    ),
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
  ),
],
// ... 日期Text ...
```

只输出修改后的相关代码部分。
```

------

## 🧩 Step 10 — 实现里程碑拖拽排序

### Claude Code Prompt

```text
修改文件：lib/features/milestones/milestone_list.dart

要求：
- 使用ReorderableListView替换ListView
- 实现onReorder回调更新顺序
- 在MilestoneCard中添加拖拽手柄
- 通过MilestoneState更新优先级

修改要点：
1. 导入ReorderableListView相关组件
2. 替换ListView.builder为ReorderableListView.builder
3. 在MilestoneCard添加拖拽手柄
4. 实现排序逻辑

实现框架：
import 'package:flutter/material.dart';

// 修改列表部分
Expanded(
  child: milestones.isEmpty
      ? _buildEmptyState(s)
      : ReorderableListView.builder(
          itemCount: milestones.length,
          onReorder: (oldIndex, newIndex) {
            final milestoneState = MilestoneState.of(context);
            if (milestoneState == null) return;

            setState(() {
              final item = milestones.removeAt(oldIndex);
              milestones.insert(newIndex, item);

              // 更新优先级
              for (int i = 0; i < milestones.length; i++) {
                milestones[i] = milestones[i].copyWith(priority: i);
              }
            });

            milestoneState.updateMilestone(milestones[newIndex]);
          },
          buildDefaultDragHandles: false,
          itemBuilder: (context, index) {
            return ReorderableDelayedStartListener(
              key: ValueKey(milestones[index].id),
              child: Row(
                children: [
                  // 拖拽手柄
                  ReorderableDragStartListener(
                    index: index,
                    child: Container(
                      width: 20,
                      height: 20,
                      margin: const EdgeInsets.only(left: 10, right: 8),
                      child: Icon(
                        Icons.drag_indicator,
                        size: 16,
                        color: WsColors.textSecondary.withAlpha(100),
                      ),
                    ),
                  ),
                  Expanded(
                    child: MilestoneCard(
                      milestone: milestones[index],
                      onEdit: (milestone) => _showEditDialog(milestone),
                      onDelete: (milestoneId) => _showDeleteDialog(milestoneId),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
),
```

只输出修改后的相关代码部分。
```

------

## ✅ Phase 3 完成标准

```text
- 描述正确显示
- 拖拽排序功能正常
- 优先级正确更新
- UI保持美观
```

------

## 🚀 Phase 4 — 数据持久化完善（第4周）

### Phase 4 总目标

```text
目标：
- 实现完整的JSON序列化
- 完善数据保存和加载
- 添加导入导出功能
- 测试数据持久化
```

------

## 🧩 Step 11 — 实现JSON序列化

### Claude Code Prompt

```text
修改文件：lib/features/milestones/milestone_model.dart

要求：
- 添加toJson方法
- 添加fromJson工厂方法
- 正确序列化DateTime
- 正确序列化所有字段

实现框架：
class Milestone {
  // ... 现有字段和方法 ...

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'targetTime': targetTime.toIso8601String(),
      'description': description,
      'isCompleted': isCompleted,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Milestone.fromJson(Map<String, dynamic> json) {
    return Milestone(
      id: json['id'] as String,
      title: json['title'] as String,
      targetTime: DateTime.parse(json['targetTime'] as String),
      description: json['description'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      priority: json['priority'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  // 静态方法：从JSON列表创建Milestone列表
  static List<Milestone> listFromJson(List<dynamic> jsonList) {
    return jsonList
        .map((json) => Milestone.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // 静态方法：将Milestone列表转换为JSON列表
  static List<Map<String, dynamic>> listToJson(List<Milestone> milestones) {
    return milestones.map((m) => m.toJson()).toList();
  }
}
```

只输出添加序列化方法后的完整类代码。
```

------

## 🧩 Step 12 — 完善MilestoneState持久化

### Claude Code Prompt

```text
修改文件：lib/features/milestones/milestone_state.dart

要求：
- 实现_loadMilestones使用JSON序列化
- 实现_saveMilestones使用JSON序列化
- 添加导入转换库
- 处理解析异常

修改要点：
1. 添加dart:convert导入
2. 使用Milestone.listFromJson和listToJson
3. 处理JSON解析异常
4. 添加错误日志

实现框架：
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'milestone_model.dart';

// 修改_loadMilestones方法
Future<void> _loadMilestones() async {
  setState(() => _isLoading = true);

  try {
    final prefs = await SharedPreferences.getInstance();
    final milestoneJson = prefs.getString('milestones');

    if (milestoneJson != null && milestoneJson.isNotEmpty) {
      final List<dynamic> decoded = jsonDecode(milestoneJson);
      _milestones = Milestone.listFromJson(decoded);
    } else {
      _milestones = Milestone.getDefaultMilestones();
    }

    // 更新完成状态
    for (final milestone in _milestones) {
      milestone.updateCompletionStatus();
    }
  } catch (e) {
    print('Failed to load milestones: $e');
    _milestones = Milestone.getDefaultMilestones();
  }

  setState(() => _isLoading = false);
}

// 修改_saveMilestones方法
Future<void> _saveMilestones() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(Milestone.listToJson(_milestones));
    await prefs.setString('milestones', encoded);
  } catch (e) {
    print('Failed to save milestones: $e');
  }
}
```

只输出修改后的相关代码部分。
```

------

## ✅ Phase 4 完成标准

```text
- JSON序列化完成
- 数据持久化正常
- 应用重启数据保留
- 导入导出功能（可选）
```

------

## 🚀 Phase 5 — 优化和测试（第5周）

### Phase 5 总目标

```text
目标：
- 添加动画效果
- 性能优化
- 全面功能测试
- 文档完善
```

------

## 🧩 Step 13 — 添加动画效果

### Claude Code Prompt

```text
修改文件：lib/features/milestones/milestone_card.dart

要求：
- 使用AnimatedContainer包装卡片
- 悬停时添加背景色变化动画
- 状态切换时添加颜色渐变
- 添加/删除时使用动画

实现框架：
// 使用AnimatedContainer包装
return MouseRegion(
  onEnter: (_) => setState(() => _isHovered = true),
  onExit: (_) => setState(() => _isHovered = false),
  child: AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    curve: Curves.easeInOut,
    decoration: BoxDecoration(
      color: _isHovered
          ? WsColors.accentCyan.withAlpha(8)
          : WsColors.surface,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: _isHovered
            ? WsColors.accentCyan.withAlpha(60)
            : WsColors.border,
      ),
    ),
    padding: const EdgeInsets.all(14),
    child: Row(
      // ... 现有内容 ...
    ),
  ),
);
```

只输出修改后的相关代码部分。
```

------

## 🧩 Step 14 — 功能测试

### 测试清单

```text
添加里程碑测试：
✅ 标题输入验证
✅ 日期时间选择正常
✅ 优先级设置正确
✅ 保存后列表更新
✅ 取消添加无变化

编辑里程碑测试：
✅ 显示现有数据
✅ 修改后保存正确
✅ 取消编辑无变化
✅ 列表实时更新

删除里程碑测试：
✅ 显示确认对话框
✅ 确认后正确删除
✅ 取消删除无变化
✅ 索引正确更新

数据持久化测试：
✅ 保存成功
✅ 加载成功
✅ 应用重启数据保留
✅ JSON序列化正确

拖拽排序测试：
✅ 拖拽流畅
✅ 位置更新正确
✅ 优先级同步
✅ 数据持久化

UI交互测试：
✅ 悬停按钮显示
✅ 动画流畅
✅ 响应及时
✅ 样式一致
```

运行测试：
```bash
flutter test
flutter test integration_test/
```

------

## ✅ Phase 5 完成标准

```text
- 动画流畅无卡顿
- 性能优化完成（> 60fps）
- 所有功能测试通过
- 边界情况处理正确
- 数据持久化稳定
- 用户体验良好
```

------

## 📊 总体验收标准

### 功能完整性

```text
✅ 里程碑可添加
✅ 里程碑可编辑
✅ 里程碑可删除
✅ 里程碑可排序
✅ 描述可显示
✅ 优先级可设置
✅ 数据可持久化
```

### 用户体验

```text
✅ 操作直观易学（< 5分钟）
✅ 交互流畅（> 60fps）
✅ 视觉反馈及时
✅ 错误提示清晰
✅ 确认机制合理
```

### 性能指标

```text
✅ 里程碑加载 < 100ms
✅ 拖拽响应 < 16ms
✅ 动画流畅度 60fps
✅ 内存使用合理
✅ 持久化快速
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

------

## 🎯 风险与应对

### 潜在风险

1. **数据持久化失败**
   - 风险：SharedPreferences异常
   - 应对：异常捕获，使用默认数据

2. **JSON序列化错误**
   - 风险：DateTime格式不兼容
   - 应对：使用ISO8601标准格式

3. **状态同步问题**
   - 风险：UI更新不及时
   - 应对：使用setState和回调通知

4. **拖拽性能问题**
   - 风险：大量里程碑时卡顿
   - 应对：优化ReorderableListView参数

5. **用户误操作**
   - 风险：误删重要里程碑
   - 应对：添加确认对话框

------

## 📅 时间线总览

| 阶段 | 周次 | 主要任务 | 交付物 |
|------|------|----------|--------|
| Phase 1 | 第1周 | 数据模型和状态管理 | 扩展模型、状态管理 |
| Phase 2 | 第2周 | 编辑删除功能 | 编辑/删除对话框 |
| Phase 3 | 第3周 | 扩展功能 | 描述显示、排序 |
| Phase 4 | 第4周 | 数据持久化 | JSON序列化 |
| Phase 5 | 第5周 | 优化测试 | 生产就绪版本 |

**总工期：5周**

------

## 🎓 总结

这份执行计划通过分阶段、渐进式的方式，为MilestoneList添加完整的CRUD功能和数据持久化。采用与任务管理一致的悬停按钮交互模式，保持UI风格的统一性。

### 核心价值

1. **功能完整**：CRUD操作全覆盖，支持添加、编辑、删除、排序
2. **数据持久化**：使用SharedPreferences，应用重启数据保留
3. **用户体验**：直观操作，流畅动画，及时反馈
4. **状态管理**：统一的状态管理机制，易于扩展
5. **架构清晰**：组件解耦，易于维护和测试

### 关键成功因素

- 严格按照计划执行
- 每个阶段充分测试
- 持续性能优化
- 及时风险评估与应对
- 保持与任务管理功能的一致性

祝项目顺利！🚀
