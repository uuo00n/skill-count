# Task Management Feature - 完善任务编辑功能执行计划

## 📋 执行目标

### 当前问题分析

UnifiedTimerPage任务管理功能现状：

✅ **已有功能**：
- 任务添加（通过 `_showAddTaskDialog`）
- 任务状态切换（通过 `_toggleTask`）
- 任务列表显示
- 基础任务进度计算

❌ **缺失功能**：
- 竞赛模块任务编辑
- 练习模块任务编辑不完整
- 任务删除功能
- 任务拖拽排序
- 任务预估时间设置
- 任务详情查看

### 重构目标

```text
目标：
- 实现完整的任务CRUD操作
- 支持任务编辑和删除
- 提供任务排序功能
- 增强任务管理用户体验
- 保持现有UI风格一致性
```

------

## 🎨 设计方案选择

### 交互模式：悬停按钮方案（推荐）

**优势**：
- 直观易懂，符合桌面应用习惯
- 操作快捷，无需额外步骤
- 横屏操作体验优秀
- 适合鼠标和触控

**实现方式**：
```
任务卡片默认显示：
┌──────────────────────────┐
│ [CURRENT] 任务标题      │
│ ↕ 30 MIN              │
└──────────────────────────┘

悬停时显示操作按钮：
┌──────────────────────────┐
│ [CURRENT] 任务标题 [✏️][🗑️]│
│ ↕ 30 MIN              │
└──────────────────────────┘
```

------

## 🚀 Phase 1 — 基础编辑功能（第1周）

### Phase 1 总目标

```text
目标：
- 创建任务编辑对话框
- 实现任务编辑功能
- 实现任务删除功能
- 集成到UnifiedTimerPage
```

------

## 🧩 Step 1 — 创建任务编辑对话框组件

### Claude Code Prompt

```text
创建文件：lib/features/unified_timer/widgets/task_edit_dialog.dart

要求：
- StatefulWidget组件
- 支持新建和编辑两种模式
- 提供任务标题输入框
- 提供预估时间选择器（15/30/45/60/90/120分钟）
- 支持自定义时间输入
- 包含取消和保存按钮
- 使用WorldSkills主题颜色
- 对话框最大宽度400px

实现框架：
import 'package:flutter/material.dart';
import '../../../core/constants/ws_colors.dart';
import '../../../core/i18n/locale_provider.dart';
import '../models/unified_timer_model.dart';

class TaskEditDialog extends StatefulWidget {
  final TaskItem? task;              // null表示新建，非null表示编辑
  final Function(TaskItem) onSave;    // 保存回调

  const TaskEditDialog({
    super.key,
    this.task,
    required this.onSave,
  });

  @override
  State<TaskEditDialog> createState() => _TaskEditDialogState();
}

class _TaskEditDialogState extends State<TaskEditDialog> {
  late TextEditingController _titleController;
  late int _selectedMinutes;

  static const _durationOptions = [15, 30, 45, 60, 90, 120];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.task?.title ?? '',
    );
    _selectedMinutes = widget.task?.estimatedDuration?.inMinutes ?? 30;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_titleController.text.trim().isEmpty) return;

    final task = TaskItem(
      id: widget.task?.id ?? 'custom_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      status: widget.task?.status ?? TaskStatus.upcoming,
      estimatedDuration: Duration(minutes: _selectedMinutes),
      actualSpent: widget.task?.actualSpent ?? Duration.zero,
      completedAt: widget.task?.completedAt,
    );

    widget.onSave(task);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final s = LocaleScope.of(context);
    final isEditMode = widget.task != null;

    return AlertDialog(
      backgroundColor: WsColors.surface,
      title: Text(
        isEditMode ? s.editTask : s.addTask,
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
            // 任务标题
            Text(
              s.taskTitle,
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
                hintText: s.enterTaskTitle,
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
            const SizedBox(height: 20),
            // 预估时间
            Text(
              s.estimatedDuration,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: WsColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                // 快速选择
                ..._durationOptions.map((minutes) {
                  final isSelected = _selectedMinutes == minutes;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(6),
                          onTap: () => setState(() => _selectedMinutes = minutes),
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
                                '${minutes}m',
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
              ],
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
}
```

只输出该文件完整代码。
```

------

## 🧩 Step 2 — 创建任务删除确认对话框

### Claude Code Prompt

```text
创建文件：lib/features/unified_timer/widgets/task_delete_dialog.dart

要求：
- StatelessWidget组件
- 显示任务标题
- 显示警告图标
- 提供取消和确认删除按钮
- 确认按钮使用红色强调危险操作
- 使用WorldSkills主题

实现框架：
import 'package:flutter/material.dart';
import '../../../core/constants/ws_colors.dart';
import '../../../core/i18n/locale_provider.dart';

class TaskDeleteDialog extends StatelessWidget {
  final String taskTitle;
  final VoidCallback onConfirm;

  const TaskDeleteDialog({
    super.key,
    required this.taskTitle,
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
            child: Icon(
              Icons.warning_rounded,
              size: 24,
              color: WsColors.errorRed,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            s.confirmDeleteTask,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: WsColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${s.deleteTaskWarning}: "$taskTitle"',
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

## 🧩 Step 3 — 扩展WsColors常量

### Claude Code Prompt

```text
修改文件：lib/core/constants/ws_colors.dart

要求：
- 添加errorRed颜色常量用于删除操作
- 颜色值：#FF5252
- 保持现有颜色常量不变

添加内容：
static const Color errorRed = Color(0xFFFF5252);
```

只输出添加errorRed的完整WsColors类代码。
```

------

## 🧩 Step 4 — 扩展国际化字符串

### Claude Code Prompt

```text
修改文件：lib/core/i18n/zh.dart

要求：
- 添加任务编辑相关的中文字符串
- 包含：编辑任务、删除任务、任务标题、预估时间、保存、取消、确认删除等

添加字符串（在AppStrings接口中）：
String get editTask;
String get taskTitle;
String get enterTaskTitle;
String get estimatedDuration;
String get save;
String get confirmDeleteTask;
String get deleteTaskWarning;
String get confirmDelete;

实现（在类中）：
@override
String get editTask => '编辑任务';
@override
String get taskTitle => '任务标题';
@override
String get enterTaskTitle => '请输入任务标题';
@override
String get estimatedDuration => '预估时间';
@override
String get save => '保存';
@override
String get confirmDeleteTask => '确认删除任务';
@override
String get deleteTaskWarning => '此操作无法撤销，确定要删除';
@override
String get confirmDelete => '确认删除';
```

只输出修改后的zh.dart文件代码。
```

------

## 🧩 Step 5 — 修改UnifiedTimerPage集成编辑功能

### Claude Code Prompt

```text
修改文件：lib/features/unified_timer/widgets/unified_timer_page.dart

要求：
- 在_buildTaskItem中添加悬停显示操作按钮
- 实现_editTask方法调用TaskEditDialog
- 实现_deleteTask方法调用TaskDeleteDialog
- 修改_addTask方法使用TaskEditDialog
- 更新任务列表时保持状态同步

修改要点：
1. 在_buildTaskItem的Column外层包裹MouseRegion监听悬停状态
2. 添加_hoveredTaskIndex状态跟踪悬停的任务
3. 悬停时显示编辑和删除按钮
4. 点击编辑按钮调用_editTask
5. 点击删除按钮调用_deleteTask
6. _showAddTaskDialog改为使用TaskEditDialog

实现框架：
// 在state类中添加
int? _hoveredTaskIndex;

// 修改_buildTaskItem方法
Widget _buildTaskItem(dynamic s, TaskItem task, int index) {
  // ... 现有代码 ...

  return MouseRegion(
    onEnter: (_) => setState(() => _hoveredTaskIndex = index),
    onExit: (_) => setState(() => _hoveredTaskIndex = null),
    child: GestureDetector(
      onTap: () => _toggleTask(index),
      child: Container(
        // ... 现有装饰 ...
        child: Row(
          children: [
            Expanded(
              child: Column(
                // ... 现有任务内容 ...
              ),
            ),
            // 悬停时显示操作按钮
            if (_hoveredTaskIndex == index) ...[
              const SizedBox(width: 8),
              _buildTaskActionIcon(
                icon: Icons.edit_outlined,
                onTap: () => _editTask(index),
                color: WsColors.accentCyan,
              ),
              const SizedBox(width: 4),
              _buildTaskActionIcon(
                icon: Icons.delete_outline,
                onTap: () => _deleteTask(index),
                color: WsColors.errorRed,
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

// 添加任务操作图标组件
Widget _buildTaskActionIcon({
  required IconData icon,
  required VoidCallback onTap,
  required Color color,
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

// 编辑任务方法
void _editTask(int index) {
  final task = _selectedModule.tasks[index];
  showDialog(
    context: context,
    builder: (ctx) => TaskEditDialog(
      task: task,
      onSave: (updatedTask) {
        setState(() {
          _selectedModule.tasks[index] = updatedTask;
        });
      },
    ),
  );
}

// 删除任务方法
void _deleteTask(int index) {
  final task = _selectedModule.tasks[index];
  showDialog(
    context: context,
    builder: (ctx) => TaskDeleteDialog(
      taskTitle: task.title,
      onConfirm: () {
        setState(() {
          _selectedModule.tasks.removeAt(index);
        });
      },
    ),
  );
}

// 修改_showAddTaskDialog使用TaskEditDialog
void _showAddTaskDialog(BuildContext context, dynamic s) {
  showDialog(
    context: context,
    builder: (ctx) => TaskEditDialog(
      onSave: (newTask) {
        setState(() {
          _selectedModule.tasks.add(newTask);
        });
      },
    ),
  );
}
```

只输出修改后的UnifiedTimerPage文件代码。
```

------

## ✅ Phase 1 完成标准

```text
- TaskEditDialog组件创建完成
- TaskDeleteDialog组件创建完成
- 任务可正常编辑（标题和时间）
- 任务可正常删除（带确认对话框）
- 悬停显示操作按钮功能正常
- 国际化字符串完整
- 颜色常量添加完成
- 竞赛模块和练习模块都支持编辑
```

------

## 🚀 Phase 2 — 任务排序功能（第2周）

### Phase 2 总目标

```text
目标：
- 实现任务拖拽排序
- 添加拖拽视觉反馈
- 保持任务状态同步
- 优化拖拽性能
```

------

## 🧩 Step 6 — 修改任务列表支持拖拽

### Claude Code Prompt

```text
修改文件：lib/features/unified_timer/widgets/unified_timer_page.dart

要求：
- 将ListView替换为ReorderableListView
- 实现onReorder回调更新任务顺序
- 添加拖拽手柄图标
- 保持悬停编辑功能
- 禁止计时器运行时拖拽

修改要点：
1. 导入flutter/material.dart中的ReorderableListView
2. 替换ListView.builder为ReorderableListView.builder
3. 在_buildTaskItem中添加拖拽手柄
4. 添加onReorder处理函数
5. _controller.isRunning时禁用拖拽

实现框架：
// 修改任务列表部分
Expanded(
  child: ReorderableListView.builder(
    itemCount: _selectedModule.tasks.length,
    onReorder: _controller.isRunning ? null : _onReorder,
    buildDefaultDragHandles: false,
    proxyDecorator: (child, index, animation) {
      return AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? child) {
          return Transform.translate(
            offset: Offset(0, 50 * animation.value),
            child: child,
          );
        },
        child: child,
      );
    },
    itemBuilder: (context, index) {
      final task = _selectedModule.tasks[index];
      return _buildTaskItem(s, task, index);
    },
  ),
),

// 修改_buildTaskItem添加拖拽手柄
Widget _buildTaskItem(dynamic s, TaskItem task, int index) {
  // ... 现有代码 ...

  return ReorderableDelayedStartListener(
    key: ValueKey(task.id),
    child: MouseRegion(
      onEnter: (_) => setState(() => _hoveredTaskIndex = index),
      onExit: (_) => setState(() => _hoveredTaskIndex = null),
      child: GestureDetector(
        onTap: () => _toggleTask(index),
        child: Container(
          // ... 现有装饰 ...
          child: Row(
            children: [
              // 拖拽手柄
              if (!_controller.isRunning) ...[
                ReorderableDragStartListener(
                  index: index,
                  child: Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.drag_indicator,
                      size: 16,
                      color: WsColors.textSecondary.withAlpha(100),
                    ),
                  ),
                ),
              ],
              Expanded(
                child: Column(
                  // ... 现有任务内容 ...
                ),
              ),
              // 悬停操作按钮
              if (_hoveredTaskIndex == index) ...[
                // ... 现有编辑删除按钮 ...
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

// 添加onReorder回调
void _onReorder(int oldIndex, int newIndex) {
  setState(() {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final task = _selectedModule.tasks.removeAt(oldIndex);
    _selectedModule.tasks.insert(newIndex, task);
  });
}
```

只输出修改后的相关代码部分。
```

------

## ✅ Phase 2 完成标准

```text
- 任务可拖拽排序
- 拖拽手柄显示正常
- 拖拽视觉反馈流畅
- 计时器运行时禁止拖拽
- 任务顺序更新正确
- 悬停编辑功能正常工作
- 性能无问题（60fps）
```

------

## 🚀 Phase 3 — 高级功能完善（第3周）

### Phase 3 总目标

```text
目标：
- 添加任务详情视图
- 实现批量操作
- 优化动画效果
- 添加数据持久化
```

------

## 🧩 Step 7 — 创建任务详情视图

### Claude Code Prompt

```text
创建文件：lib/features/unified_timer/widgets/task_detail_dialog.dart

要求：
- 显示任务完整信息
- 包含创建时间和修改时间
- 显示实际用时和预估时间
- 支持在详情中编辑任务
- 显示任务完成记录
- 使用WorldSkills主题

实现框架：
import 'package:flutter/material.dart';
import '../../../core/constants/ws_colors.dart';
import '../../../core/i18n/locale_provider.dart';
import '../models/unified_timer_model.dart';
import 'task_edit_dialog.dart';

class TaskDetailDialog extends StatelessWidget {
  final TaskItem task;
  final Function(TaskItem) onUpdate;

  const TaskDetailDialog({
    super.key,
    required this.task,
    required this.onUpdate,
  });

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '-';
    return '${dateTime.month}/${dateTime.day} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
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
        width: 450,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题栏
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getStatusIcon(),
                    size: 20,
                    color: _getStatusColor(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: WsColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getStatusText(s),
                        style: TextStyle(
                          fontSize: 12,
                          color: _getStatusColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            // 时间信息
            _buildInfoRow(
              s.estimatedDuration,
              _formatDuration(task.estimatedDuration ?? Duration.zero),
              Icons.access_time,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              s.actualSpent,
              _formatDuration(task.actualSpent),
              Icons.timer_outlined,
            ),
            const SizedBox(height: 12),
            if (task.completedAt != null)
              _buildInfoRow(
                s.completedAt,
                _formatDateTime(task.completedAt),
                Icons.check_circle,
              ),
            const Divider(height: 32),
            // 操作按钮
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: WsColors.textSecondary.withAlpha(40)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      s.close,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showEditDialog(context, s);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WsColors.accentCyan,
                      foregroundColor: WsColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      s.editTask,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: WsColors.textSecondary),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: WsColors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        const Text(':'),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: WsColors.textPrimary,
            fontFamily: 'JetBrainsMono',
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (task.status) {
      case TaskStatus.done:
        return WsColors.accentGreen;
      case TaskStatus.current:
        return WsColors.accentCyan;
      case TaskStatus.upcoming:
        return WsColors.textSecondary;
    }
  }

  IconData _getStatusIcon() {
    switch (task.status) {
      case TaskStatus.done:
        return Icons.check_circle;
      case TaskStatus.current:
        return Icons.play_circle;
      case TaskStatus.upcoming:
        return Icons.radio_button_unchecked;
    }
  }

  String _getStatusText(dynamic s) {
    switch (task.status) {
      case TaskStatus.done:
        return s.done.toUpperCase();
      case TaskStatus.current:
        return s.current.toUpperCase();
      case TaskStatus.upcoming:
        return s.upcoming.toUpperCase();
    }
  }

  void _showEditDialog(BuildContext context, dynamic s) {
    showDialog(
      context: context,
      builder: (ctx) => TaskEditDialog(
        task: task,
        onSave: (updatedTask) => onUpdate(updatedTask),
      ),
    );
  }
}
```

只输出该文件完整代码。
```

------

## 🧩 Step 8 — 双击任务显示详情

### Claude Code Prompt

```text
修改文件：lib/features/unified_timer/widgets/unified_timer_page.dart

要求：
- 在_buildTaskItem的GestureDetector添加onDoubleTap
- 调用TaskDetailDialog显示任务详情
- 保持单击切换任务状态功能

修改要点：
1. 添加onDoubleTap回调
2. 创建_showTaskDetail方法
3. 传入任务更新回调

实现框架：
// 修改_buildTaskItem的GestureDetector
GestureDetector(
  onTap: () => _toggleTask(index),
  onDoubleTap: () => _showTaskDetail(index),
  child: Container(
    // ... 现有代码 ...
  ),
),

// 添加任务详情方法
void _showTaskDetail(int index) {
  final task = _selectedModule.tasks[index];
  showDialog(
    context: context,
    builder: (ctx) => TaskDetailDialog(
      task: task,
      onUpdate: (updatedTask) {
        setState(() {
          _selectedModule.tasks[index] = updatedTask;
        });
      },
    ),
  );
}
```

只输出修改后的相关代码部分。
```

------

## ✅ Phase 3 完成标准

```text
- TaskDetailDialog组件创建完成
- 双击任务显示详情正常
- 详情信息完整准确
- 详情中可编辑任务
- 时间格式化正确
- UI美观符合主题
```

------

## 🚀 Phase 4 — 优化和测试（第4周）

### Phase 4 总目标

```text
目标：
- 添加动画效果
- 性能优化
- 全面测试
- 文档完善
```

------

## 🧩 Step 9 — 添加动画效果

### Claude Code Prompt

```text
修改文件：lib/features/unified_timer/widgets/unified_timer_page.dart

要求：
- 任务添加动画（淡入+滑动）
- 任务删除动画（淡出+收缩）
- 编辑切换动画
- 状态切换颜色渐变
- 保持动画流畅（60fps）

实现框架：
// 使用AnimatedContainer包装任务卡片
Widget _buildTaskItem(dynamic s, TaskItem task, int index) {
  // ... 现有代码 ...

  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOut,
    decoration: BoxDecoration(
      color: isCurrent
          ? accentColor.withAlpha(15)
          : WsColors.bgDeep.withAlpha(120),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: isCurrent ? accentColor.withAlpha(60) : WsColors.border,
      ),
    ),
    child: MouseRegion(
      // ... 现有MouseRegion和GestureDetector ...
    ),
  );
}

// 任务列表使用AnimatedList
Expanded(
  child: ReorderableListView.builder(
    // ... 现有参数 ...
    itemBuilder: (context, index) {
      final task = _selectedModule.tasks[index];
      return AnimatedSize(
        duration: const Duration(milliseconds: 300),
        child: _buildTaskItem(s, task, index),
      );
    },
  ),
),
```

只输出修改后的相关代码部分。
```

------

## 🧩 Step 10 — 性能优化

### 优化任务

```text
1. 减少不必要的重建
   - 使用const构造函数
   - 拆分Widget避免级联更新
   - 使用RepaintBoundary隔离重绘区域

2. 拖拽性能优化
   - 减少拖拽时的重绘范围
   - 使用proxyDecorator优化拖拽效果
   - 限制同时操作的任务数量

3. 列表滚动优化
   - 使用itemExtent固定高度
   - 启用addAutomaticKeepAlives
   - 优化ReorderableListView参数

4. 内存优化
   - 及时释放Controller
   - 避免内存泄漏
   - 优化大对象的使用
```

运行性能测试：
```bash
flutter run --profile
flutter run --release
```

------

## 🧩 Step 11 — 功能测试

### 测试清单

```text
任务编辑功能测试：
✅ 编辑任务标题
✅ 修改预估时间
✅ 保存后列表更新
✅ 取消编辑无变化
✅ 竞赛模块编辑正常
✅ 练习模块编辑正常

任务删除功能测试：
✅ 显示确认对话框
✅ 确认后任务删除
✅ 取消删除无变化
✅ 删除后索引正确
✅ 进度计数更新

任务排序功能测试：
✅ 拖拽手柄显示
✅ 拖拽流畅无卡顿
✅ 松手后位置正确
✅ 计时器运行时禁用拖拽
✅ 状态保持正确

任务详情功能测试：
✅ 双击显示详情
✅ 详情信息完整
✅ 时间格式正确
✅ 详情中可编辑
✅ 编辑后列表更新

边界情况测试：
✅ 空标题无法保存
✅ 删除最后一个任务
✅ 拖拽到边界位置
✅ 快速连续操作
✅ 切换模块后编辑
```

运行测试：
```bash
flutter test
flutter test integration_test/
```

------

## 🧩 Step 12 — 文档完善

### 文档任务

```text
1. 更新用户指南
   - 任务编辑操作说明
   - 任务删除注意事项
   - 任务排序方法
   - 任务详情查看

2. 更新代码注释
   - TaskEditDialog功能说明
   - TaskDeleteDialog警告说明
   - 拖拽排序实现注释
   - 性能优化说明

3. 创建FAQ文档
   - 常见问题解答
   - 操作技巧说明
   - 故障排除指南
```

------

## ✅ Phase 4 完成标准

```text
- 动画流畅无卡顿
- 性能优化完成（> 60fps）
- 所有功能测试通过
- 边界情况处理正确
- 文档完整清晰
- 代码注释充分
- 用户体验良好
```

------

## 📊 总体验收标准

### 功能完整性

```text
✅ 所有任务可编辑
✅ 所有任务可删除
✅ 任务可拖拽排序
✅ 任务详情可查看
✅ 竞赛和练习模块功能一致
✅ 所有原有功能保留
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
✅ 任务加载 < 100ms
✅ 拖拽响应 < 16ms
✅ 动画流畅度 60fps
✅ 内存使用合理
✅ CPU占用 < 30%
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
✅ 单元测试覆盖率 > 70%
✅ 集成测试通过
✅ 手工测试完成
✅ 边界情况测试通过
✅ 性能测试达标
```

------

## 🎯 风险与应对

### 潜在风险

1. **拖拽性能问题**
   - 风险：大量任务时拖拽卡顿
   - 应对：优化ReorderableListView，限制同时操作数量

2. **状态同步问题**
   - 风险：编辑后状态不一致
   - 应对：统一状态管理，添加数据验证

3. **用户误操作**
   - 风险：误删任务或打乱顺序
   - 应对：添加确认对话框，提供撤销功能

4. **动画兼容性**
   - 风险：部分平台动画不流畅
   - 应对：平台适配，降级处理

------

## 📅 时间线总览

| 阶段 | 周次 | 主要任务 | 交付物 |
|------|------|----------|--------|
| Phase 1 | 第1周 | 基础编辑功能 | 编辑/删除对话框 |
| Phase 2 | 第2周 | 任务排序功能 | 拖拽排序 |
| Phase 3 | 第3周 | 高级功能 | 任务详情 |
| Phase 4 | 第4周 | 优化测试 | 生产就绪版本 |

**总工期：4周**

------

## 🎓 总结

这份执行计划通过分阶段、渐进式的方式，为UnifiedTimerPage添加完整的任务管理功能。采用悬停按钮的交互模式，既保持了UI的简洁性，又提供了直观的操作体验。

### 核心价值

1. **功能完整**：CRUD操作全覆盖，支持编辑、删除、排序、详情
2. **用户体验**：直观操作，流畅动画，及时反馈
3. **性能优化**：减少重建，优化拖拽，保持60fps
4. **代码质量**：组件复用，架构清晰，易于维护

### 关键成功因素

- 严格按照计划执行
- 每个阶段充分测试
- 持续性能优化
- 及时风险评估与应对

祝项目顺利！🚀
