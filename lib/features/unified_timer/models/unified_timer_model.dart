enum ModuleType { competition, practice }

enum ModuleStatus { completed, inProgress, upcoming }

enum TaskStatus { current, done, upcoming }

class TaskItem {
  final String id;
  final String title;
  TaskStatus status;
  final Duration? estimatedDuration;
  Duration actualSpent;
  DateTime? completedAt;

  TaskItem({
    required this.id,
    required this.title,
    this.status = TaskStatus.upcoming,
    this.estimatedDuration,
    this.actualSpent = Duration.zero,
    this.completedAt,
  });
}

class ModuleModel {
  final String id;
  final String name;
  final String description;
  final Duration defaultDuration;
  ModuleStatus status;
  final List<TaskItem> tasks;
  final ModuleType type;
  final bool allowCustomDuration;
  final List<Duration> presetDurations;

  ModuleModel({
    required this.id,
    required this.name,
    required this.description,
    this.defaultDuration = const Duration(hours: 3),
    this.status = ModuleStatus.upcoming,
    required this.tasks,
    this.type = ModuleType.competition,
    this.allowCustomDuration = false,
    this.presetDurations = const [
      Duration(minutes: 45),
      Duration(minutes: 60),
      Duration(minutes: 90),
      Duration(minutes: 120),
      Duration(minutes: 180),
    ],
  });
}
