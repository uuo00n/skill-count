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
  }) : createdAt = createdAt ?? DateTime.now().toUtc();

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
        id: 'selection',
        title: '选手选拔',
        description: '全国各省市及地区开展技能大赛选手选拔工作，确定最终参赛名单。',
        targetTime: DateTime.utc(2026, 4, 10, 0, 0, 0),
        priority: 1,
      ),
      Milestone(
        id: 'reg_deadline',
        title: '选手报名截止',
        description: '所有参赛选手的最终报名信息录入截止，逾期将无法更改。',
        targetTime: DateTime.utc(2026, 5, 20, 0, 0, 0),
        priority: 2,
      ),
      Milestone(
        id: 'tech_docs',
        title: '各项目技术文件发布',
        description: '发布各竞赛项目的技术说明书、评分标准及样题。',
        targetTime: DateTime.utc(2026, 6, 1, 0, 0, 0),
        priority: 3,
      ),
      Milestone(
        id: 'opening',
        title: '赛事开幕式',
        description: '2026年上海世界技能大赛盛大开幕，欢迎来自全球的技能精英。',
        targetTime: DateTime.utc(2026, 6, 20, 0, 0, 0),
        priority: 4,
      ),
      Milestone(
        id: 'closing',
        title: '赛事闭幕式',
        description: '大赛圆满落幕，颁奖典礼及交接仪式。',
        targetTime: DateTime.utc(2026, 7, 10, 0, 0, 0),
        priority: 4,
      ),
      Milestone(
        id: 'summary',
        title: '赛项结束总结',
        description: '各项目裁判长及专家组进行赛事技术点评与总结。',
        targetTime: DateTime.utc(2026, 7, 10, 0, 0, 0),
        priority: 5,
      ),
    ];
  }
}
