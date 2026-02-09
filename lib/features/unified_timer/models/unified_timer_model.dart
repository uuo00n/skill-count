enum ModuleType { competition, practice }

enum ModuleStatus { completed, inProgress, upcoming }

enum TaskStatus { current, done, upcoming }

class TaskItem {
  final String id;
  final String title;
  final TaskStatus status;
  final Duration? estimatedDuration;
  final Duration actualSpent;
  final DateTime? completedAt;

  const TaskItem({
    required this.id,
    required this.title,
    this.status = TaskStatus.upcoming,
    this.estimatedDuration,
    this.actualSpent = Duration.zero,
    this.completedAt,
  });

  TaskItem copyWith({
    String? id,
    String? title,
    TaskStatus? status,
    Duration? estimatedDuration,
    Duration? actualSpent,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      status: status ?? this.status,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      actualSpent: actualSpent ?? this.actualSpent,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
    );
  }
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

  ModuleModel copyWith({
    String? id,
    String? name,
    String? description,
    Duration? defaultDuration,
    ModuleStatus? status,
    List<TaskItem>? tasks,
    ModuleType? type,
    bool? allowCustomDuration,
    List<Duration>? presetDurations,
  }) {
    return ModuleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      defaultDuration: defaultDuration ?? this.defaultDuration,
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      type: type ?? this.type,
      allowCustomDuration: allowCustomDuration ?? this.allowCustomDuration,
      presetDurations: presetDurations ?? this.presetDurations,
    );
  }
}
