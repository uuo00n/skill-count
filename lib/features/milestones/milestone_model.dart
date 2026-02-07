import 'dart:convert';

class Milestone {
  final String id;
  final String title;
  final DateTime targetTime;
  final String? description;
  final bool isCompleted;
  final int priority;
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

  bool get isPast => DateTime.now().toUtc().isAfter(targetTime);

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

  static List<Milestone> listFromJson(String jsonStr) {
    final List<dynamic> decoded = jsonDecode(jsonStr);
    return decoded
        .map((json) => Milestone.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  static String listToJson(List<Milestone> milestones) {
    return jsonEncode(milestones.map((m) => m.toJson()).toList());
  }

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
