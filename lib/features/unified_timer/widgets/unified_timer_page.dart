import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../core/constants/ws_colors.dart';
import '../../../core/i18n/locale_provider.dart';
import '../../../core/providers/practice_history_provider.dart';
import '../../../core/providers/time_providers.dart';
import '../../practice_history/models/practice_record_model.dart' as ph;
import '../controllers/unified_timer_controller.dart';
import '../models/unified_timer_model.dart';
import 'module_delete_dialog.dart';
import 'module_edit_dialog.dart';
import 'task_delete_dialog.dart';
import 'task_detail_dialog.dart';
import 'task_edit_dialog.dart';

class UnifiedTimerPage extends ConsumerStatefulWidget {
  const UnifiedTimerPage({super.key});

  @override
  ConsumerState<UnifiedTimerPage> createState() => _UnifiedTimerPageState();
}

class _UnifiedTimerPageState extends ConsumerState<UnifiedTimerPage> {
  late UnifiedTimerController _controller;
  late ConfettiController _confettiController;
  final AudioPlayer _timerEndPlayer = AudioPlayer();
  bool _hasCompleted = false;
  bool _hasSavedRecord = false;
  bool _hasStartedSession = false;
  bool _isSavingRecord = false;
  bool _isPracticeMode = false;
  int _selectedModuleIndex = 0;
  int? _hoveredTaskIndex;
  int? _hoveredModuleIndex;
  final List<ph.KeyEvent> _sessionKeyEvents = [];

  // Competition modules
  late List<ModuleModel> _competitionModules;
  // Practice modules
  late List<ModuleModel> _practiceModules;

  List<ModuleModel> get _currentModules =>
      _isPracticeMode ? _practiceModules : _competitionModules;

  ModuleModel get _selectedModule => _currentModules[_selectedModuleIndex];

  void _updateSelectedModule(ModuleModel updatedModule) {
    _currentModules[_selectedModuleIndex] = updatedModule;
    if (_controller.currentModule?.id == updatedModule.id) {
      _controller.currentModule = updatedModule;
      final currentTask = _controller.currentTask;
      if (currentTask != null) {
        TaskItem? matched;
        for (final t in updatedModule.tasks) {
          if (t.id == currentTask.id) {
            matched = t;
            break;
          }
        }
        if (matched != null) {
          _controller.currentTask = matched;
        }
      }
    }
  }

  ModuleModel _resolveModuleForRecord() {
    final active = _controller.currentModule;
    if (active == null) return _selectedModule;
    for (final m in _currentModules) {
      if (m.id == active.id) return m;
    }
    return active;
  }

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));

    _timerEndPlayer.setAsset('assets/audio/timer-end.wav');

    _competitionModules = [
      ModuleModel(
        id: 'A',
        name: 'A模块：APP原型设计',
        description: '基于 Flutter 的高保真界面构建与交互设计，实现 Pixel-Perfect 的 UI 还原。',
        defaultDuration: const Duration(hours: 3),
        status: ModuleStatus.upcoming,
        type: ModuleType.competition,
        tasks: [
          TaskItem(
            id: 'a1',
            title: 'UI 架构搭建与路由配置',
            status: TaskStatus.upcoming,
            estimatedDuration: const Duration(minutes: 30),
          ),
          TaskItem(
            id: 'a2',
            title: '核心页面静态布局实现',
            status: TaskStatus.upcoming,
            estimatedDuration: const Duration(minutes: 60),
          ),
          TaskItem(
            id: 'a3',
            title: '自定义组件封装与复用',
            status: TaskStatus.upcoming,
            estimatedDuration: const Duration(minutes: 45),
          ),
          TaskItem(
            id: 'a4',
            title: '复杂动画与交互效果',
            status: TaskStatus.upcoming,
            estimatedDuration: const Duration(minutes: 45),
          ),
        ],
      ),
      ModuleModel(
        id: 'B',
        name: 'B模块：单机APP开发',
        description: '开发具备本地持久化能力的离线应用，集成 SQLite 数据库与文件系统。',
        defaultDuration: const Duration(hours: 3),
        status: ModuleStatus.upcoming,
        type: ModuleType.competition,
        tasks: [
          TaskItem(
            id: 'b1',
            title: '本地数据库模型设计 (Drift/Isar)',
            status: TaskStatus.upcoming,
            estimatedDuration: const Duration(minutes: 40),
          ),
          TaskItem(
            id: 'b2',
            title: 'Riverpod 状态管理架构',
            status: TaskStatus.upcoming,
            estimatedDuration: const Duration(minutes: 40),
          ),
          TaskItem(
            id: 'b3',
            title: '业务逻辑层 (Service) 实现',
            status: TaskStatus.upcoming,
            estimatedDuration: const Duration(minutes: 50),
          ),
          TaskItem(
            id: 'b4',
            title: '本地数据 CRUD 完整链路',
            status: TaskStatus.upcoming,
            estimatedDuration: const Duration(minutes: 50),
          ),
        ],
      ),
      ModuleModel(
        id: 'C',
        name: 'C模块：联网APP开发',
        description: '实现 RESTful API 完整对接，处理复杂的网络状态、缓存策略与异常管理。',
        defaultDuration: const Duration(hours: 3),
        status: ModuleStatus.upcoming,
        type: ModuleType.competition,
        tasks: [
          TaskItem(
            id: 'c1',
            title: '网络层封装与拦截器 (Dio)',
            status: TaskStatus.upcoming,
            estimatedDuration: const Duration(minutes: 30),
          ),
          TaskItem(
            id: 'c2',
            title: '用户认证与 Token 刷新机制',
            status: TaskStatus.upcoming,
            estimatedDuration: const Duration(minutes: 40),
          ),
          TaskItem(
            id: 'c3',
            title: 'API 数据序列化 (JsonSerializable)',
            status: TaskStatus.upcoming,
            estimatedDuration: const Duration(minutes: 50),
          ),
          TaskItem(
            id: 'c4',
            title: '分页加载与下拉刷新实现',
            status: TaskStatus.upcoming,
            estimatedDuration: const Duration(minutes: 60),
          ),
        ],
      ),
      ModuleModel(
        id: 'D',
        name: 'D模块：游戏APP开发',
        description: '基于 Flame 引擎或 Flutter 渲染机制开发 2D 休闲游戏，包含物理引擎与粒子效果。',
        defaultDuration: const Duration(hours: 3),
        status: ModuleStatus.upcoming,
        type: ModuleType.competition,
        tasks: [
          TaskItem(
            id: 'd1',
            title: '游戏循环与场景管理器',
            status: TaskStatus.upcoming,
            estimatedDuration: const Duration(minutes: 40),
          ),
          TaskItem(
            id: 'd2',
            title: '精灵动画与资源加载',
            status: TaskStatus.upcoming,
            estimatedDuration: const Duration(minutes: 40),
          ),
          TaskItem(
            id: 'd3',
            title: '物理碰撞检测系统',
            status: TaskStatus.upcoming,
            estimatedDuration: const Duration(minutes: 50),
          ),
          TaskItem(
            id: 'd4',
            title: '游戏状态与得分系统',
            status: TaskStatus.upcoming,
            estimatedDuration: const Duration(minutes: 50),
          ),
        ],
      ),
      ModuleModel(
        id: 'E',
        name: 'E模块：vibe coding APP开发',
        description: '探索 AI 辅助编程与智能化应用场景，集成 LLM 能力提升编码体验。',
        defaultDuration: const Duration(hours: 3),
        status: ModuleStatus.upcoming,
        type: ModuleType.competition,
        tasks: [
          TaskItem(
            id: 'e1',
            title: 'AI 模型接口对接 (OpenAI/Gemini)',
            status: TaskStatus.upcoming,
            estimatedDuration: const Duration(minutes: 40),
          ),
          TaskItem(
            id: 'e2',
            title: 'Prompt 工程与上下文管理',
            status: TaskStatus.upcoming,
            estimatedDuration: const Duration(minutes: 50),
          ),
          TaskItem(
            id: 'e3',
            title: '流式响应与打字机效果',
            status: TaskStatus.upcoming,
            estimatedDuration: const Duration(minutes: 40),
          ),
          TaskItem(
            id: 'e4',
            title: '代码高亮与差异对比视图',
            status: TaskStatus.upcoming,
            estimatedDuration: const Duration(minutes: 50),
          ),
        ],
      ),
    ];

    _practiceModules = [
      ModuleModel(
        id: 'P1',
        name: '练习 - Flutter UI 基础',
        description: '练习 Flutter 基础布局、Widget 组合与样式定制，掌握 Material 3 设计规范。',
        defaultDuration: const Duration(minutes: 90),
        type: ModuleType.practice,
        allowCustomDuration: true,
        tasks: [
          TaskItem(
            id: 'p1-1',
            title: 'Row/Column 弹性布局练习',
            status: TaskStatus.upcoming,
            estimatedDuration: const Duration(minutes: 20),
          ),
          TaskItem(
            id: 'p1-2',
            title: 'Stack 层叠与 Positioned 定位',
            status: TaskStatus.upcoming,
            estimatedDuration: const Duration(minutes: 20),
          ),
          TaskItem(
            id: 'p1-3',
            title: '自定义 Widget 封装与复用',
            status: TaskStatus.upcoming,
            estimatedDuration: const Duration(minutes: 25),
          ),
          TaskItem(
            id: 'p1-4',
            title: 'ListView/GridView 列表构建',
            status: TaskStatus.upcoming,
            estimatedDuration: const Duration(minutes: 25),
          ),
        ],
      ),
      ModuleModel(
        id: 'P2',
        name: '练习 - 状态管理',
        description: '练习 Riverpod 状态管理模式，掌握 Provider、StateNotifier 与异步数据流。',
        defaultDuration: const Duration(minutes: 90),
        type: ModuleType.practice,
        allowCustomDuration: true,
        tasks: [
          TaskItem(
            id: 'p2-1',
            title: 'Provider 与 StateProvider 基础',
            status: TaskStatus.upcoming,
            estimatedDuration: const Duration(minutes: 20),
          ),
          TaskItem(
            id: 'p2-2',
            title: 'StateNotifier 状态管理实践',
            status: TaskStatus.upcoming,
            estimatedDuration: const Duration(minutes: 25),
          ),
          TaskItem(
            id: 'p2-3',
            title: 'FutureProvider 异步数据加载',
            status: TaskStatus.upcoming,
            estimatedDuration: const Duration(minutes: 20),
          ),
          TaskItem(
            id: 'p2-4',
            title: 'Consumer 与 ref.watch/listen 使用',
            status: TaskStatus.upcoming,
            estimatedDuration: const Duration(minutes: 25),
          ),
        ],
      ),
      ModuleModel(
        id: 'P3',
        name: '练习 - 动画与交互',
        description: '练习 Flutter 隐式/显式动画、手势识别与自定义绘制，提升交互体验。',
        defaultDuration: const Duration(minutes: 90),
        type: ModuleType.practice,
        allowCustomDuration: true,
        tasks: [
          TaskItem(
            id: 'p3-1',
            title: 'AnimatedContainer 隐式动画',
            status: TaskStatus.upcoming,
            estimatedDuration: const Duration(minutes: 20),
          ),
          TaskItem(
            id: 'p3-2',
            title: 'AnimationController 显式动画',
            status: TaskStatus.upcoming,
            estimatedDuration: const Duration(minutes: 25),
          ),
          TaskItem(
            id: 'p3-3',
            title: 'GestureDetector 手势交互',
            status: TaskStatus.upcoming,
            estimatedDuration: const Duration(minutes: 20),
          ),
          TaskItem(
            id: 'p3-4',
            title: 'CustomPainter 自定义绘制',
            status: TaskStatus.upcoming,
            estimatedDuration: const Duration(minutes: 25),
          ),
        ],
      ),
      ModuleModel(
        id: 'P4',
        name: '练习 - 数据与网络',
        description: '练习 RESTful API 对接、JSON 序列化与本地数据持久化，构建完整数据链路。',
        defaultDuration: const Duration(minutes: 90),
        type: ModuleType.practice,
        allowCustomDuration: true,
        tasks: [
          TaskItem(
            id: 'p4-1',
            title: 'Dio 网络请求封装',
            status: TaskStatus.upcoming,
            estimatedDuration: const Duration(minutes: 20),
          ),
          TaskItem(
            id: 'p4-2',
            title: 'JSON 序列化与模型转换',
            status: TaskStatus.upcoming,
            estimatedDuration: const Duration(minutes: 20),
          ),
          TaskItem(
            id: 'p4-3',
            title: 'SharedPreferences 本地存储',
            status: TaskStatus.upcoming,
            estimatedDuration: const Duration(minutes: 25),
          ),
          TaskItem(
            id: 'p4-4',
            title: '数据缓存与离线策略',
            status: TaskStatus.upcoming,
            estimatedDuration: const Duration(minutes: 25),
          ),
        ],
      ),
    ];

    _controller = UnifiedTimerController(
      totalDuration: _competitionModules[_selectedModuleIndex].defaultDuration,
      onTick: () {
        setState(() {});
        ref.read(isTimerRunningProvider.notifier).state = _controller.isRunning;
        if (_controller.remaining.inSeconds == 0 &&
            !_hasCompleted &&
            _controller.totalDuration.inSeconds > 0) {
          _finalizeModuleCompletion(isManual: false);
        }
      },
    );
    _controller.currentModule = _competitionModules[_selectedModuleIndex];
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    _timerEndPlayer.dispose();
    super.dispose();
  }

  int get _completedTaskCount =>
      _selectedModule.tasks.where((t) => t.status == TaskStatus.done).length;
  bool get _hasPendingTasks =>
      _selectedModule.tasks.any((t) => t.status != TaskStatus.done);

  void _selectModule(int index) {
    setState(() {
      _selectedModuleIndex = index;
      final module = _currentModules[index];
      _controller.startModule(module);
      _resetSessionState();
    });
  }

  void _toggleMode() {
    setState(() {
      _isPracticeMode = !_isPracticeMode;
      _selectedModuleIndex = 0;
      final module = _currentModules[0];
      _controller.startModule(module);
      _resetSessionState();
    });
  }

  void _toggleTask(int index) {
    setState(() {
      final task = _selectedModule.tasks[index];
      if (task.status == TaskStatus.done) {
        _selectedModule.tasks[index] = task.copyWith(
          status: TaskStatus.upcoming,
          clearCompletedAt: true,
        );
      } else {
        if (_controller.currentTask?.id == task.id) {
          _controller.completeTask();
          if (_controller.isRunning) {
            _controller.nextTask();
          }
        } else {
          _selectedModule.tasks[index] = task.copyWith(
            status: TaskStatus.done,
            completedAt: DateTime.now().toUtc(),
          );
        }
      }
    });
  }

  void _ensureCurrentTask() {
    final currentTask = _controller.currentTask;
    if (currentTask != null) {
      TaskItem? taskInModule;
      for (final t in _selectedModule.tasks) {
        if (t.id == currentTask.id) {
          taskInModule = t;
          break;
        }
      }
      if (taskInModule != null && taskInModule.status != TaskStatus.done) {
        if (taskInModule.status != TaskStatus.current) {
          _controller.selectTask(taskInModule);
        }
        return;
      }
    }

    for (final task in _selectedModule.tasks) {
      if (task.status == TaskStatus.current) {
        _controller.selectTask(task);
        return;
      }
    }

    for (final task in _selectedModule.tasks) {
      if (task.status == TaskStatus.upcoming) {
        _controller.selectTask(task);
        return;
      }
    }
  }

  void _handleModuleComplete() {
    if (!_controller.isRunning) return;
    _finalizeModuleCompletion(isManual: true);
  }

  void _finalizeModuleCompletion({required bool isManual}) {
    if (_hasCompleted) return;

    _playTimerEndSound();

    final allTasksDone = !_hasPendingTasks;
    _addKeyEvent(
      ph.KeyEventType.moduleComplete,
      data: {
        'manual': isManual,
        'allTasksDone': allTasksDone,
      },
    );
    setState(() {
      _hasCompleted = true;
      _confettiController.play();
      _controller.pause();
      ref.read(isTimerRunningProvider.notifier).state = false;
    });
    _savePracticeRecord(
      recordType: allTasksDone
          ? ph.RecordType.moduleComplete
          : ph.RecordType.partial,
    );
  }

  void _playTimerEndSound() {
    if (_timerEndPlayer.processingState == ProcessingState.idle) {
      _timerEndPlayer
          .setAsset('assets/audio/timer-end.wav')
          .then((_) => _timerEndPlayer.seek(Duration.zero))
          .then((_) => _timerEndPlayer.play())
          .catchError((_) {});
      return;
    }

    _timerEndPlayer.seek(Duration.zero);
    _timerEndPlayer.play();
  }

  void _resetAllTasks() {
    final newTasks = _selectedModule.tasks
        .map((task) => task.copyWith(
              status: TaskStatus.upcoming,
              actualSpent: Duration.zero,
              clearCompletedAt: true,
            ))
        .toList();
    _updateSelectedModule(_selectedModule.copyWith(tasks: newTasks));
    _controller.currentTask = null;
  }

  void _resetSessionState() {
    _hasCompleted = false;
    _hasSavedRecord = false;
    _hasStartedSession = false;
    _isSavingRecord = false;
    _sessionKeyEvents.clear();
  }

  void _addKeyEvent(ph.KeyEventType type, {Map<String, dynamic>? data}) {
    _sessionKeyEvents.add(
      ph.KeyEvent(
        type: type,
        timestamp: DateTime.now().toUtc(),
        data: data,
      ),
    );
  }

  Future<void> _savePracticeRecord({required ph.RecordType recordType}) async {
    if (_hasSavedRecord || _isSavingRecord) return;
    _isSavingRecord = true;
    final module = _resolveModuleForRecord();
    final actualDuration = _controller.totalDuration - _controller.remaining;
    final safeActualDuration =
        actualDuration.isNegative ? Duration.zero : actualDuration;
    final record = ph.PracticeRecord(
      id: 'record_${DateTime.now().millisecondsSinceEpoch}',
      moduleId: module.id,
      moduleName: module.name,
      recordType: recordType,
      completedAt: DateTime.now().toUtc(),
      totalDuration: safeActualDuration,
      estimatedDuration: _controller.totalDuration,
      taskRecords: module.tasks
          .map(
            (task) => ph.TaskRecord(
              taskId: task.id,
              taskTitle: task.title,
              actualSpent: task.actualSpent,
              estimatedDuration: task.estimatedDuration,
              status: task.status.name,
            ),
          )
          .toList(),
      keyEvents: List<ph.KeyEvent>.from(_sessionKeyEvents),
    );

    try {
      final service = await ref.read(practiceHistoryServiceProvider.future);
      await service.addRecord(record);
      if (!mounted) return;
      ref.read(recordsRefreshTriggerProvider.notifier).state++;
      _hasSavedRecord = true;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Record save failed'),
            backgroundColor: WsColors.errorRed,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        _isSavingRecord = false;
      }
    }
  }

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

  void _deleteTask(int index) {
    final task = _selectedModule.tasks[index];
    showDialog(
      context: context,
      builder: (ctx) => TaskDeleteDialog(
        taskTitle: task.title,
        onConfirm: () {
          setState(() {
            final newTasks = [
              ..._selectedModule.tasks.sublist(0, index),
              ..._selectedModule.tasks.sublist(index + 1),
            ];
            _updateSelectedModule(_selectedModule.copyWith(tasks: newTasks));
            _hoveredTaskIndex = null;
          });
        },
      ),
    );
  }

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

  void _showAddTaskDialog(BuildContext context, dynamic s) {
    showDialog(
      context: context,
      builder: (ctx) => TaskEditDialog(
        onSave: (newTask) {
          setState(() {
            _updateSelectedModule(
              _selectedModule.copyWith(tasks: [..._selectedModule.tasks, newTask]),
            );
          });
        },
      ),
    );
  }

  void _addModule() {
    showDialog(
      context: context,
      builder: (ctx) => ModuleEditDialog(
        moduleType:
            _isPracticeMode ? ModuleType.practice : ModuleType.competition,
        onSave: (newModule) {
          setState(() {
            if (_isPracticeMode) {
              _practiceModules = [..._practiceModules, newModule];
            } else {
              _competitionModules = [..._competitionModules, newModule];
            }
            _selectedModuleIndex = _currentModules.length - 1;
            _controller.startModule(newModule);
            _resetSessionState();
          });
        },
      ),
    );
  }

  void _editModule(int index) {
    final module = _currentModules[index];
    showDialog(
      context: context,
      builder: (ctx) => ModuleEditDialog(
        module: module,
        moduleType: module.type,
        onSave: (updatedModule) {
          setState(() {
            final durationChanged =
                updatedModule.defaultDuration != module.defaultDuration;
            _currentModules[index] = updatedModule;
            if (index == _selectedModuleIndex) {
              if (durationChanged) {
                _controller.startModule(updatedModule);
                _resetSessionState();
              } else {
                _controller.currentModule = updatedModule;
              }
            }
          });
        },
      ),
    );
  }

  void _deleteModule(int index) {
    if (_currentModules.length <= 1) return;
    final module = _currentModules[index];
    showDialog(
      context: context,
      builder: (ctx) => ModuleDeleteDialog(
        moduleName: module.name,
        taskCount: module.tasks.length,
        onConfirm: () {
          setState(() {
            final newList = [
              ..._currentModules.sublist(0, index),
              ..._currentModules.sublist(index + 1),
            ];
            if (_isPracticeMode) {
              _practiceModules = newList;
            } else {
              _competitionModules = newList;
            }
            _hoveredModuleIndex = null;
            if (_selectedModuleIndex >= _currentModules.length) {
              _selectedModuleIndex = _currentModules.length - 1;
            } else if (_selectedModuleIndex == index) {
              _selectedModuleIndex = 0;
            } else if (_selectedModuleIndex > index) {
              _selectedModuleIndex--;
            }
            _controller.startModule(_currentModules[_selectedModuleIndex]);
            _resetSessionState();
          });
        },
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      final tasks = List<TaskItem>.from(_selectedModule.tasks);
      if (newIndex > oldIndex) newIndex -= 1;
      final task = tasks.removeAt(oldIndex);
      tasks.insert(newIndex, task);
      _updateSelectedModule(_selectedModule.copyWith(tasks: tasks));
    });
  }

  void _stopTimer() {
    final s = LocaleScope.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
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
                Icons.stop_circle_outlined,
                size: 24,
                color: WsColors.errorRed,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              s.stopTimer,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: WsColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              s.confirmStopTimer,
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
            onPressed: () => Navigator.of(ctx).pop(),
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
              Navigator.of(ctx).pop();
              _addKeyEvent(ph.KeyEventType.timerStop);
              _savePracticeRecord(recordType: ph.RecordType.partial);
              setState(() {
                _controller.reset();
                _resetSessionState();
              });
              ref.read(isTimerRunningProvider.notifier).state = false;
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: WsColors.errorRed,
              foregroundColor: WsColors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              s.stopTimer,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmReset() {
    final s = LocaleScope.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
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
                color: WsColors.accentCyan.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.refresh,
                size: 24,
                color: WsColors.accentCyan,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              s.reset,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: WsColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              s.confirmResetTimer,
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
            onPressed: () => Navigator.of(ctx).pop(),
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
              Navigator.of(ctx).pop();
              setState(() {
                _controller.reset();
                _resetSessionState();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: WsColors.accentCyan,
              foregroundColor: WsColors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              s.reset,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _restartTimer() {
    setState(() {
      _controller.reset();
      _resetSessionState();
      _resetAllTasks();
      _ensureCurrentTask();
      _controller.start();
      _addKeyEvent(ph.KeyEventType.timerStart);
      _hasStartedSession = true;
      ref.read(isTimerRunningProvider.notifier).state = _controller.isRunning;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = LocaleScope.of(context);

    return Stack(
      children: [
        Row(
          children: [
            // Left Panel: Module Selector
            _buildLeftPanel(s),
            // Center Panel: Timer Display
            Expanded(flex: 3, child: _buildCenterPanel(s)),
            // Right Panel: Task List
            _buildRightPanel(s),
          ],
        ),
        // Confetti overlay
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            maxBlastForce: 20,
            minBlastForce: 8,
            emissionFrequency: 0.05,
            numberOfParticles: 25,
            gravity: 0.1,
            colors: const [
              WsColors.accentCyan,
              WsColors.secondaryMint,
              WsColors.white,
              WsColors.accentGreen,
            ],
          ),
        ),
      ],
    );
  }

  // ─── Left Panel: Module Selector ────────────────────────────────

  Widget _buildLeftPanel(dynamic s) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(left: 20, top: 16, bottom: 16),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mode toggle
          _buildModeToggle(s),
          const SizedBox(height: 16),
          // Module list header
          Row(
            children: [
              Icon(
                _isPracticeMode ? Icons.fitness_center : Icons.view_module,
                size: 16,
                color: _isPracticeMode
                    ? WsColors.accentGreen
                    : WsColors.accentCyan,
              ),
              const SizedBox(width: 8),
              Text(
                _isPracticeMode
                    ? s.practiceModules.toUpperCase()
                    : s.competitionModules.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: WsColors.textSecondary,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Module cards
          Expanded(
            child: ListView.separated(
              itemCount: _currentModules.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final module = _currentModules[index];
                final isSelected = index == _selectedModuleIndex;
                return _buildModuleCard(s, module, isSelected, index, () {
                  if (!_controller.isRunning) _selectModule(index);
                });
              },
            ),
          ),
          // Add module button
          const SizedBox(height: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: _controller.isRunning ? null : _addModule,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: WsColors.textSecondary.withAlpha(40),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add,
                        size: 16, color: WsColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      s.addModule,
                      style: const TextStyle(
                        fontSize: 12,
                        color: WsColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeToggle(dynamic s) {
    return Container(
      decoration: BoxDecoration(
        color: WsColors.bgDeep,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _isPracticeMode && !_controller.isRunning
                  ? _toggleMode
                  : null,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  color: !_isPracticeMode ? WsColors.surface : null,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: !_isPracticeMode
                      ? [
                          BoxShadow(
                            color: Colors.black.withAlpha(10),
                            blurRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.emoji_events,
                      size: 13,
                      color: !_isPracticeMode
                          ? WsColors.accentCyan
                          : WsColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      s.competition,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: !_isPracticeMode
                            ? WsColors.darkBlue
                            : WsColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: !_isPracticeMode && !_controller.isRunning
                  ? _toggleMode
                  : null,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  color: _isPracticeMode ? WsColors.surface : null,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: _isPracticeMode
                      ? [
                          BoxShadow(
                            color: Colors.black.withAlpha(10),
                            blurRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.fitness_center,
                      size: 13,
                      color: _isPracticeMode
                          ? WsColors.accentGreen
                          : WsColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      s.practice,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _isPracticeMode
                            ? WsColors.darkBlue
                            : WsColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(
    dynamic s,
    ModuleModel module,
    bool isSelected,
    int index,
    VoidCallback onTap,
  ) {
    String statusLabel;
    Color statusColor;
    switch (module.status) {
      case ModuleStatus.completed:
        statusLabel = s.completed;
        statusColor = WsColors.accentGreen;
      case ModuleStatus.inProgress:
        statusLabel = s.inProgress;
        statusColor = WsColors.accentYellow;
      case ModuleStatus.upcoming:
        statusLabel = s.upcoming;
        statusColor = WsColors.textSecondary;
    }

    final accentColor =
        _isPracticeMode ? WsColors.accentGreen : WsColors.accentCyan;
    final isHovered = _hoveredModuleIndex == index;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredModuleIndex = index),
      onExit: (_) => setState(() => _hoveredModuleIndex = null),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color:
                  isSelected ? accentColor.withAlpha(20) : WsColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color:
                    isSelected ? accentColor.withAlpha(80) : WsColors.border,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 40,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
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
                          statusLabel,
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        module.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w600,
                          color: WsColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${module.defaultDuration.inHours}h ${module.defaultDuration.inMinutes % 60}m',
                        style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'JetBrainsMono',
                          color: WsColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isHovered && !_controller.isRunning) ...[
                  _buildTaskActionIcon(
                    icon: Icons.edit_outlined,
                    onTap: () => _editModule(index),
                    color: WsColors.accentCyan,
                  ),
                  const SizedBox(width: 4),
                  if (_currentModules.length > 1)
                    _buildTaskActionIcon(
                      icon: Icons.delete_outline,
                      onTap: () => _deleteModule(index),
                      color: WsColors.errorRed,
                    ),
                ] else if (isSelected)
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: accentColor,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Center Panel: Timer Display ────────────────────────────────

  Widget _buildCenterPanel(dynamic s) {
    final totalSeconds = _controller.totalDuration.inSeconds;
    final remainingSeconds = _controller.remaining.inSeconds;
    final progress =
        totalSeconds > 0 ? remainingSeconds / totalSeconds : 0.0;

    final rHours = _controller.remaining.inHours;
    final rMinutes = _controller.remaining.inMinutes % 60;
    final rSeconds = _controller.remaining.inSeconds % 60;

    // Show HH:MM:SS for competition (3h), MM:SS for practice
    final bool showHours = _controller.totalDuration.inHours > 0;
    final timeText = showHours
        ? '${rHours.toString().padLeft(2, '0')}:${rMinutes.toString().padLeft(2, '0')}:${rSeconds.toString().padLeft(2, '0')}'
        : '${rMinutes.toString().padLeft(2, '0')}:${rSeconds.toString().padLeft(2, '0')}';

    final accentColor =
        _isPracticeMode ? WsColors.accentGreen : WsColors.accentCyan;
    final isCompleted = _controller.isCompleted || _hasCompleted;
    final isPaused = !_controller.isRunning && _hasStartedSession && !isCompleted;
    final actionLabel = _controller.isRunning
        ? s.pause
        : isCompleted
            ? s.restart
            : isPaused
                ? s.resume
                : s.start;

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Module name
            Text(
            _selectedModule.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: WsColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          // Status label
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _controller.isRunning
                      ? WsColors.accentGreen
                      : accentColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _controller.isRunning
                    ? s.focusSession.toUpperCase()
                    : s.ready.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _controller.isRunning
                      ? WsColors.accentGreen
                      : accentColor,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Circular timer
          CircularPercentIndicator(
            radius: 120.0,
            lineWidth: 8.0,
            percent: progress.clamp(0.0, 1.0),
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeText,
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: showHours ? 36 : 48,
                    fontWeight: FontWeight.bold,
                    color: WsColors.darkBlue,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  s.remaining.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: WsColors.textSecondary,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            progressColor: accentColor,
            backgroundColor: WsColors.secondaryMint.withAlpha(60),
            circularStrokeCap: CircularStrokeCap.round,
            animation: true,
            animationDuration: 300,
            animateFromLastPercent: true,
          ),
          const SizedBox(height: 20),
          // Controls
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!_controller.isRunning)
                _buildCircleButton(
                  icon: Icons.refresh,
                  onTap: _confirmReset,
                ),
              if (_controller.isRunning) ...[
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: _handleModuleComplete,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: WsColors.accentGreen,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.celebration,
                            color: WsColors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            s.moduleComplete.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: WsColors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: _stopTimer,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: WsColors.errorRed,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.stop,
                            color: WsColors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            s.stopTimer.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: WsColors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              if (!_controller.isRunning) const SizedBox(width: 20),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () {
                    if (_controller.isRunning) {
                      setState(() {
                        _controller.pause();
                        _addKeyEvent(ph.KeyEventType.timerPause);
                        ref.read(isTimerRunningProvider.notifier).state =
                            _controller.isRunning;
                      });
                      return;
                    }
                    if (isCompleted) {
                      _restartTimer();
                      return;
                    }
                    setState(() {
                      if (!_hasStartedSession) {
                        _resetAllTasks();
                      }
                      _controller.start();
                      _ensureCurrentTask();
                      if (_hasStartedSession) {
                        _addKeyEvent(ph.KeyEventType.timerResume);
                      } else {
                        _addKeyEvent(ph.KeyEventType.timerStart);
                        _hasStartedSession = true;
                      }
                      ref.read(isTimerRunningProvider.notifier).state =
                          _controller.isRunning;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _controller.isRunning
                              ? Icons.pause
                              : isCompleted
                                  ? Icons.refresh
                                  : Icons.play_arrow,
                          color: WsColors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          actionLabel.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: WsColors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              if (!_controller.isRunning)
                _buildCircleButton(
                  icon: Icons.tune,
                  onTap: () => _editModule(_selectedModuleIndex),
                ),
            ],
          ),
          // Description (below controls, compact)
          const SizedBox(height: 16),
          Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: WsColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: WsColors.border),
            ),
            child: Text(
              _selectedModule.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: WsColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  // ─── Right Panel: Task List ─────────────────────────────────────

  Widget _buildRightPanel(dynamic s) {
    return Container(
      width: 320,
      margin: const EdgeInsets.only(right: 20, top: 16, bottom: 16),
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                s.moduleTasks,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: WsColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: (_isPracticeMode
                          ? WsColors.accentGreen
                          : WsColors.accentCyan)
                      .withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$_completedTaskCount/${_selectedModule.tasks.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _isPracticeMode
                        ? WsColors.accentGreen
                        : WsColors.accentCyan,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _isPracticeMode
                ? s.practiceMode
                : 'Web Technologies · ${_selectedModule.id}',
            style: const TextStyle(
              fontSize: 12,
              color: WsColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          // Progress summary
          _buildProgressSummary(s),
          const SizedBox(height: 12),
          // Task list (ReorderableListView)
          Expanded(
            child: ReorderableListView.builder(
              itemCount: _selectedModule.tasks.length,
              buildDefaultDragHandles: false,
              onReorder: _controller.isRunning
                  ? (_, __) {}
                  : _onReorder,
              proxyDecorator: (child, index, animation) {
                return Material(
                  color: Colors.transparent,
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                  child: child,
                );
              },
              itemBuilder: (context, index) {
                final task = _selectedModule.tasks[index];
                return _buildTaskItem(s, task, index);
              },
            ),
          ),
          // Add task button
          const SizedBox(height: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: _controller.isRunning
                  ? null
                  : () => _showAddTaskDialog(context, s),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: WsColors.textSecondary.withAlpha(40),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add,
                        size: 16, color: WsColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      s.addTask,
                      style: const TextStyle(
                        fontSize: 12,
                        color: WsColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSummary(dynamic s) {
    final totalTasks = _selectedModule.tasks.length;
    final doneTasks = _completedTaskCount;
    final progressPercent =
        totalTasks > 0 ? (doneTasks / totalTasks * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: WsColors.bgDeep.withAlpha(120),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.progress.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: WsColors.textSecondary,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: totalTasks > 0 ? doneTasks / totalTasks : 0,
                    minHeight: 6,
                    backgroundColor: WsColors.border,
                    valueColor: AlwaysStoppedAnimation(
                      _isPracticeMode
                          ? WsColors.accentGreen
                          : WsColors.accentCyan,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$progressPercent%',
            style: const TextStyle(
              fontSize: 18,
              fontFamily: 'JetBrainsMono',
              fontWeight: FontWeight.bold,
              color: WsColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(dynamic s, TaskItem task, int index) {
    final isCurrent = task.status == TaskStatus.current;
    final isDone = task.status == TaskStatus.done;
    final isHovered = _hoveredTaskIndex == index;

    Color statusColor;
    String statusLabel;
    if (isDone) {
      statusColor = WsColors.accentGreen;
      statusLabel = s.done.toUpperCase();
    } else if (isCurrent) {
      statusColor =
          _isPracticeMode ? WsColors.accentGreen : WsColors.accentCyan;
      statusLabel = s.current.toUpperCase();
    } else {
      statusColor = WsColors.textSecondary;
      statusLabel = s.upcoming.toUpperCase();
    }

    final accentColor =
        _isPracticeMode ? WsColors.accentGreen : WsColors.accentCyan;
    final hideCheckbox =
        !_isPracticeMode &&
        !_controller.isRunning &&
        !_controller.isCompleted &&
        _controller.remaining == _controller.totalDuration;

    return MouseRegion(
      key: ValueKey(task.id),
      onEnter: (_) => setState(() => _hoveredTaskIndex = index),
      onExit: (_) => setState(() => _hoveredTaskIndex = null),
      child: GestureDetector(
        onTap: () => _toggleTask(index),
        onDoubleTap:
            _controller.isRunning ? null : () => _showTaskDetail(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isCurrent
                ? accentColor.withAlpha(15)
                : WsColors.bgDeep.withAlpha(120),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isCurrent ? accentColor.withAlpha(60) : WsColors.border,
            ),
          ),
          child: Row(
            children: [
              // Drag handle (hidden when timer is running)
              if (!_controller.isRunning)
                ReorderableDragStartListener(
                  index: index,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.drag_indicator,
                      size: 16,
                      color: isHovered
                          ? WsColors.textSecondary
                          : WsColors.textSecondary.withAlpha(60),
                    ),
                  ),
                ),
              // Task content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withAlpha(20),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        if (task.estimatedDuration != null &&
                            !isDone) ...[
                          const SizedBox(width: 6),
                          Text(
                            '${task.estimatedDuration!.inMinutes} MIN',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: WsColors.textSecondary,
                            ),
                          ),
                        ],
                        const Spacer(),
                        if (!hideCheckbox) ...[
                          if (isDone)
                            const Icon(Icons.check_circle,
                                size: 16, color: WsColors.accentGreen)
                          else if (!isCurrent)
                            const Icon(Icons.radio_button_unchecked,
                                size: 16, color: WsColors.textSecondary),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isCurrent ? FontWeight.w600 : FontWeight.normal,
                        color: WsColors.textPrimary,
                        decoration:
                            isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ],
                ),
              ),
              // Hover action buttons
              if (isHovered && !_controller.isRunning) ...[
                const SizedBox(width: 4),
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

  Widget _buildTaskActionIcon({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: WsColors.textSecondary.withAlpha(60),
            ),
          ),
          child: Icon(icon, size: 18, color: WsColors.textSecondary),
        ),
      ),
    );
  }
}
