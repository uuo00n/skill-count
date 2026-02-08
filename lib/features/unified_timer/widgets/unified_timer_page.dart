import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../core/constants/ws_colors.dart';
import '../../../core/i18n/locale_provider.dart';
import '../controllers/unified_timer_controller.dart';
import '../models/unified_timer_model.dart';
import 'module_delete_dialog.dart';
import 'module_edit_dialog.dart';
import 'task_delete_dialog.dart';
import 'task_detail_dialog.dart';
import 'task_edit_dialog.dart';

class UnifiedTimerPage extends StatefulWidget {
  const UnifiedTimerPage({super.key});

  static final ValueNotifier<bool> isTimerRunning = ValueNotifier(false);

  @override
  State<UnifiedTimerPage> createState() => _UnifiedTimerPageState();
}

class _UnifiedTimerPageState extends State<UnifiedTimerPage> {
  late UnifiedTimerController _controller;
  late ConfettiController _confettiController;
  bool _hasCompleted = false;
  bool _isPracticeMode = false;
  int _selectedModuleIndex = 1;
  int _selectedMinutes = 90;
  int? _hoveredTaskIndex;
  int? _hoveredModuleIndex;

  static const _durationOptions = [45, 60, 90, 120, 180];

  // Competition modules
  late List<ModuleModel> _competitionModules;
  // Practice modules
  late List<ModuleModel> _practiceModules;

  List<ModuleModel> get _currentModules =>
      _isPracticeMode ? _practiceModules : _competitionModules;

  ModuleModel get _selectedModule => _currentModules[_selectedModuleIndex];

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));

    _competitionModules = [
      ModuleModel(
        id: 'A',
        name: 'Module A - Design',
        description:
            'Create responsive web design mockups and implement HTML/CSS layouts according to specifications.',
        defaultDuration: const Duration(hours: 3),
        status: ModuleStatus.completed,
        type: ModuleType.competition,
        tasks: [
          TaskItem(
              id: 'a1', title: 'Wireframe Design', status: TaskStatus.done),
          TaskItem(
              id: 'a2', title: 'HTML Structure', status: TaskStatus.done),
          TaskItem(id: 'a3', title: 'CSS Styling', status: TaskStatus.done),
          TaskItem(
              id: 'a4', title: 'Responsive Layout', status: TaskStatus.done),
        ],
      ),
      ModuleModel(
        id: 'B',
        name: 'Module B - Frontend',
        description:
            'Build interactive frontend components with JavaScript frameworks and client-side logic.',
        defaultDuration: const Duration(hours: 3),
        status: ModuleStatus.inProgress,
        type: ModuleType.competition,
        tasks: [
          TaskItem(
            id: 'b1',
            title: 'Component Architecture',
            status: TaskStatus.done,
          ),
          TaskItem(
            id: 'b2',
            title: 'State Management',
            status: TaskStatus.current,
            estimatedDuration: const Duration(minutes: 45),
          ),
          TaskItem(
            id: 'b3',
            title: 'API Integration',
            status: TaskStatus.upcoming,
            estimatedDuration: const Duration(minutes: 60),
          ),
          TaskItem(
            id: 'b4',
            title: 'Form Validation',
            status: TaskStatus.upcoming,
            estimatedDuration: const Duration(minutes: 30),
          ),
        ],
      ),
      ModuleModel(
        id: 'C',
        name: 'Module C - Backend',
        description:
            'Develop server-side APIs, database schemas, and business logic implementation.',
        defaultDuration: const Duration(hours: 3),
        status: ModuleStatus.upcoming,
        type: ModuleType.competition,
        tasks: [
          TaskItem(
            id: 'c1',
            title: 'Database Design',
            status: TaskStatus.upcoming,
            estimatedDuration: const Duration(minutes: 40),
          ),
          TaskItem(
            id: 'c2',
            title: 'REST API Endpoints',
            status: TaskStatus.upcoming,
            estimatedDuration: const Duration(minutes: 50),
          ),
          TaskItem(
            id: 'c3',
            title: 'Authentication',
            status: TaskStatus.upcoming,
            estimatedDuration: const Duration(minutes: 30),
          ),
          TaskItem(
            id: 'c4',
            title: 'Data Validation',
            status: TaskStatus.upcoming,
            estimatedDuration: const Duration(minutes: 20),
          ),
        ],
      ),
      ModuleModel(
        id: 'D',
        name: 'Module D - Integration',
        description:
            'Connect frontend and backend, deploy application, and perform integration testing.',
        defaultDuration: const Duration(hours: 3),
        status: ModuleStatus.upcoming,
        type: ModuleType.competition,
        tasks: [
          TaskItem(
            id: 'd1',
            title: 'API Connection',
            status: TaskStatus.upcoming,
            estimatedDuration: const Duration(minutes: 35),
          ),
          TaskItem(
            id: 'd2',
            title: 'Error Handling',
            status: TaskStatus.upcoming,
            estimatedDuration: const Duration(minutes: 25),
          ),
          TaskItem(
            id: 'd3',
            title: 'Performance Optimization',
            status: TaskStatus.upcoming,
            estimatedDuration: const Duration(minutes: 40),
          ),
          TaskItem(
            id: 'd4',
            title: 'Final Testing',
            status: TaskStatus.upcoming,
            estimatedDuration: const Duration(minutes: 30),
          ),
        ],
      ),
    ];

    _practiceModules = [
      ModuleModel(
        id: 'P1',
        name: 'Practice - HTML/CSS',
        description: 'Practice responsive design, flexbox, grid layout.',
        defaultDuration: const Duration(minutes: 90),
        type: ModuleType.practice,
        allowCustomDuration: true,
        tasks: [
          TaskItem(
            id: 'p1-1',
            title: 'Flexbox Layout Exercise',
            status: TaskStatus.upcoming,
            estimatedDuration: const Duration(minutes: 30),
          ),
          TaskItem(
            id: 'p1-2',
            title: 'Grid Layout Exercise',
            status: TaskStatus.upcoming,
            estimatedDuration: const Duration(minutes: 30),
          ),
          TaskItem(
            id: 'p1-3',
            title: 'Responsive Breakpoints',
            status: TaskStatus.upcoming,
            estimatedDuration: const Duration(minutes: 30),
          ),
        ],
      ),
      ModuleModel(
        id: 'P2',
        name: 'Practice - JavaScript',
        description: 'Practice DOM manipulation, async/await, frameworks.',
        defaultDuration: const Duration(minutes: 90),
        type: ModuleType.practice,
        allowCustomDuration: true,
        tasks: [
          TaskItem(
            id: 'p2-1',
            title: 'DOM Manipulation',
            status: TaskStatus.upcoming,
            estimatedDuration: const Duration(minutes: 25),
          ),
          TaskItem(
            id: 'p2-2',
            title: 'Async/Await Patterns',
            status: TaskStatus.upcoming,
            estimatedDuration: const Duration(minutes: 35),
          ),
          TaskItem(
            id: 'p2-3',
            title: 'Framework Components',
            status: TaskStatus.upcoming,
            estimatedDuration: const Duration(minutes: 30),
          ),
        ],
      ),
    ];

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
    );
    _controller.currentModule = _competitionModules[_selectedModuleIndex];
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  int get _completedTaskCount =>
      _selectedModule.tasks.where((t) => t.status == TaskStatus.done).length;

  void _selectModule(int index) {
    setState(() {
      _selectedModuleIndex = index;
      final module = _currentModules[index];
      _controller.startModule(module);
      _hasCompleted = false;
    });
  }

  void _toggleMode() {
    setState(() {
      _isPracticeMode = !_isPracticeMode;
      _selectedModuleIndex = 0;
      final module = _currentModules[0];
      _controller.startModule(module);
      _hasCompleted = false;
    });
  }

  void _toggleTask(int index) {
    setState(() {
      final task = _selectedModule.tasks[index];
      if (task.status == TaskStatus.done) {
        task.status = TaskStatus.upcoming;
        task.completedAt = null;
      } else {
        task.status = TaskStatus.done;
        task.completedAt = DateTime.now();
      }
    });
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
            _selectedModule.tasks.removeAt(index);
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
            _selectedModule.tasks.add(newTask);
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
            _currentModules.add(newModule);
            _selectedModuleIndex = _currentModules.length - 1;
            _controller.startModule(newModule);
            _hasCompleted = false;
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
            _currentModules[index] = updatedModule;
            if (index == _selectedModuleIndex) {
              _controller.startModule(updatedModule);
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
            _currentModules.removeAt(index);
            _hoveredModuleIndex = null;
            if (_selectedModuleIndex >= _currentModules.length) {
              _selectedModuleIndex = _currentModules.length - 1;
            } else if (_selectedModuleIndex == index) {
              _selectedModuleIndex = 0;
            } else if (_selectedModuleIndex > index) {
              _selectedModuleIndex--;
            }
            _controller.startModule(_currentModules[_selectedModuleIndex]);
            _hasCompleted = false;
          });
        },
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final task = _selectedModule.tasks.removeAt(oldIndex);
      _selectedModule.tasks.insert(newIndex, task);
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
              setState(() {
                _controller.reset();
                _hasCompleted = false;
              });
              UnifiedTimerPage.isTimerRunning.value = false;
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
                _hasCompleted = false;
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

    return Center(
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
                      _controller.pause();
                    } else {
                      _controller.start();
                    }
                    setState(() {});
                    UnifiedTimerPage.isTimerRunning.value =
                        _controller.isRunning;
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
                              : Icons.play_arrow,
                          color: WsColors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _controller.isRunning
                              ? s.pause.toUpperCase()
                              : s.start.toUpperCase(),
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
          // Duration selector (practice mode only)
          if (_isPracticeMode || _selectedModule.allowCustomDuration) ...[
            Row(
              children: _durationOptions.map((m) {
                final isSelected = _selectedMinutes == m;
                final accentColor = _isPracticeMode
                    ? WsColors.accentGreen
                    : WsColors.accentCyan;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTap: _controller.isRunning
                            ? null
                            : () {
                                setState(() => _selectedMinutes = m);
                                _controller.setDuration(
                                  Duration(minutes: m),
                                );
                                _hasCompleted = false;
                              },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? accentColor.withAlpha(30)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isSelected
                                  ? accentColor
                                  : WsColors.textSecondary.withAlpha(40),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${m}m',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? accentColor
                                    : WsColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
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
