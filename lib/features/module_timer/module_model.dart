enum ModuleStatus { completed, inProgress, upcoming }

class ModuleModel {
  final String id;
  final String name;
  final String description;
  final Duration duration;
  final ModuleStatus status;
  final List<String> tasks;

  const ModuleModel({
    required this.id,
    required this.name,
    required this.description,
    required this.duration,
    required this.status,
    required this.tasks,
  });
}
