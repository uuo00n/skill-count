import 'dart:async';

import '../../../core/timer/competition_timer.dart';
import '../models/unified_timer_model.dart';

/// 统一计时器控制器
///
/// 包装 [CompetitionTimer]，在核心计时能力之上增加
/// 模块选择、任务管理等业务逻辑。
class UnifiedTimerController {
  ModuleModel? currentModule;
  TaskItem? currentTask;
  Duration totalDuration;
  bool isPracticeMode = false;
  final void Function() onTick;

  CompetitionTimer _timer;
  StreamSubscription<Duration>? _subscription;
  Duration _lastElapsed = Duration.zero;

  UnifiedTimerController({
    required this.totalDuration,
    required this.onTick,
  }) : _timer = CompetitionTimer(
          totalDuration: totalDuration,
          mode: TimerMode.countDown,
        ) {
    _listenTimer();
  }

  // — 代理属性 ——————————————————————————————

  Duration get remaining => _timer.remaining;
  bool get isRunning => _timer.isRunning;
  bool get isCompleted => _timer.isCompleted;
  double get progress => _timer.progress;

  // — 模块操作 ——————————————————————————————

  void startModule(ModuleModel module) {
    currentModule = module;
    totalDuration = module.defaultDuration;
    isPracticeMode = module.type == ModuleType.practice;
    _replaceTimer(totalDuration);
    onTick();
  }

  void setDuration(Duration duration) {
    totalDuration = duration;
    _replaceTimer(duration);
    onTick();
  }

  // — 计时器控制 ——————————————————————————————

  void start() => _timer.start();

  void pause() => _timer.pause();

  void reset() {
    _timer.reset();
    onTick();
  }

  // — 任务操作 ——————————————————————————————

  void selectTask(TaskItem task) {
    currentTask = task;
    if (task.status == TaskStatus.upcoming && currentModule != null) {
      final tasks = currentModule!.tasks;
      final idx = tasks.indexWhere((t) => t.id == task.id);
      if (idx != -1) {
        currentModule!.tasks[idx] = task.copyWith(status: TaskStatus.current);
        currentTask = currentModule!.tasks[idx];
      }
    }
    onTick();
  }

  void completeTask() {
    if (currentTask != null && currentModule != null) {
      final tasks = currentModule!.tasks;
      final idx = tasks.indexWhere((t) => t.id == currentTask!.id);
      if (idx != -1) {
        final updated = currentTask!.copyWith(
          status: TaskStatus.done,
          completedAt: DateTime.now().toUtc(),
        );
        currentModule!.tasks[idx] = updated;
      }
      currentTask = null;
      onTick();
    }
  }

  void nextTask() {
    if (currentModule == null) return;
    final tasks = currentModule!.tasks;
    final idx = tasks.indexWhere((t) => t.status == TaskStatus.upcoming);
    if (idx != -1) {
      selectTask(tasks[idx]);
    }
  }

  // — 生命周期 ——————————————————————————————

  void dispose() {
    _subscription?.cancel();
    _timer.dispose();
  }

  // — 私有方法 ——————————————————————————————

  void _replaceTimer(Duration duration) {
    _subscription?.cancel();
    _timer.dispose();
    _timer = CompetitionTimer(
      totalDuration: duration,
      mode: TimerMode.countDown,
    );
    _listenTimer();
  }

  void _listenTimer() {
    _lastElapsed = Duration.zero;
    _subscription = _timer.timeUpdates.listen((_) {
      final elapsed = _timer.elapsed;
      if (currentTask != null && elapsed > _lastElapsed && currentModule != null) {
        final delta = elapsed - _lastElapsed;
        final tasks = currentModule!.tasks;
        final idx = tasks.indexWhere((t) => t.id == currentTask!.id);
        if (idx != -1) {
          final updated = currentTask!.copyWith(
            actualSpent: currentTask!.actualSpent + delta,
          );
          tasks[idx] = updated;
          currentTask = updated;
        }
      }
      _lastElapsed = elapsed;
      onTick();
    });
  }
}
