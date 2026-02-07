import 'dart:async';
import '../models/unified_timer_model.dart';

class UnifiedTimerController {
  ModuleModel? currentModule;
  TaskItem? currentTask;
  Duration totalDuration;
  Duration remaining;
  bool isRunning = false;
  bool isPracticeMode = false;
  Timer? _timer;
  final void Function() onTick;

  UnifiedTimerController({
    required this.totalDuration,
    required this.onTick,
  }) : remaining = totalDuration;

  void startModule(ModuleModel module) {
    _timer?.cancel();
    currentModule = module;
    totalDuration = module.defaultDuration;
    remaining = totalDuration;
    isRunning = false;
    isPracticeMode = module.type == ModuleType.practice;
    onTick();
  }

  void setDuration(Duration duration) {
    _timer?.cancel();
    isRunning = false;
    totalDuration = duration;
    remaining = duration;
    onTick();
  }

  void start() {
    if (isRunning) return;
    isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (remaining.inSeconds > 0) {
        remaining -= const Duration(seconds: 1);
        if (currentTask != null) {
          currentTask!.actualSpent += const Duration(seconds: 1);
        }
        onTick();
      } else {
        pause();
      }
    });
    onTick();
  }

  void pause() {
    _timer?.cancel();
    isRunning = false;
    onTick();
  }

  void reset() {
    _timer?.cancel();
    isRunning = false;
    remaining = totalDuration;
    onTick();
  }

  void selectTask(TaskItem task) {
    currentTask = task;
    if (task.status == TaskStatus.upcoming) {
      task.status = TaskStatus.current;
    }
    onTick();
  }

  void completeTask() {
    if (currentTask != null) {
      currentTask!.status = TaskStatus.done;
      currentTask!.completedAt = DateTime.now();
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

  void dispose() {
    _timer?.cancel();
  }
}
