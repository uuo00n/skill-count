// ignore: unused_import
import 'dart:convert';

enum RecordType {
  moduleComplete,
  taskComplete,
  partial,
}

enum KeyEventType {
  timerStart,
  timerPause,
  timerResume,
  timerStop,
  taskComplete,
  moduleComplete,
}

class TaskRecord {
  final String taskId;
  final String taskTitle;
  final Duration actualSpent;
  final Duration? estimatedDuration;
  final String status;

  TaskRecord({
    required this.taskId,
    required this.taskTitle,
    required this.actualSpent,
    this.estimatedDuration,
    required this.status,
  });

  double get efficiency {
    if (estimatedDuration == null || estimatedDuration!.inSeconds == 0) return 1.0;
    final actualSeconds = actualSpent.inSeconds.toDouble();
    if (actualSeconds == 0) return 1.0;
    final estimatedSeconds = estimatedDuration!.inSeconds.toDouble();
    return (estimatedSeconds / actualSeconds).clamp(0.0, 2.0);
  }

  Map<String, dynamic> toJson() {
    return {
      'taskId': taskId,
      'taskTitle': taskTitle,
      'actualSpent': actualSpent.inSeconds,
      'estimatedDuration': estimatedDuration?.inSeconds,
      'status': status,
    };
  }

  factory TaskRecord.fromJson(Map<String, dynamic> json) {
    return TaskRecord(
      taskId: json['taskId'] as String,
      taskTitle: json['taskTitle'] as String,
      actualSpent: Duration(seconds: json['actualSpent'] as int),
      estimatedDuration: json['estimatedDuration'] != null
          ? Duration(seconds: json['estimatedDuration'] as int)
          : null,
      status: json['status'] as String,
    );
  }
}

class KeyEvent {
  final KeyEventType type;
  final DateTime timestamp;
  final Map<String, dynamic>? data;

  KeyEvent({
    required this.type,
    required this.timestamp,
    this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'data': data,
    };
  }

  factory KeyEvent.fromJson(Map<String, dynamic> json) {
    return KeyEvent(
      type: KeyEventType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => KeyEventType.timerStart,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      data: json['data'] as Map<String, dynamic>?,
    );
  }
}

class PracticeRecord {
  final String id;
  final String moduleId;
  final String moduleName;
  final RecordType recordType;
  final DateTime completedAt;
  final Duration totalDuration;
  final Duration estimatedDuration;
  final List<TaskRecord> taskRecords;
  final List<KeyEvent> keyEvents;

  PracticeRecord({
    required this.id,
    required this.moduleId,
    required this.moduleName,
    required this.recordType,
    required this.completedAt,
    required this.totalDuration,
    required this.estimatedDuration,
    required this.taskRecords,
    required this.keyEvents,
  });

  double get efficiency {
    if (estimatedDuration.inSeconds == 0) return 1.0;
    final actualSeconds = totalDuration.inSeconds.toDouble();
    if (actualSeconds == 0) return 1.0;
    final estimatedSeconds = estimatedDuration.inSeconds.toDouble();
    return (estimatedSeconds / actualSeconds).clamp(0.0, 2.0);
  }

  int get completedTasks {
    return taskRecords.where((t) => t.status == 'done').length;
  }

  int get totalTasks => taskRecords.length;

  Duration get averageTaskDuration {
    if (taskRecords.isEmpty) return Duration.zero;
    final totalSeconds = taskRecords.fold<int>(
      0,
      (sum, t) => sum + t.actualSpent.inSeconds,
    );
    return Duration(seconds: totalSeconds ~/ taskRecords.length);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'moduleId': moduleId,
      'moduleName': moduleName,
      'recordType': recordType.name,
      'completedAt': completedAt.toIso8601String(),
      'totalDuration': totalDuration.inSeconds,
      'estimatedDuration': estimatedDuration.inSeconds,
      'taskRecords': taskRecords.map((t) => t.toJson()).toList(),
      'keyEvents': keyEvents.map((e) => e.toJson()).toList(),
    };
  }

  factory PracticeRecord.fromJson(Map<String, dynamic> json) {
    return PracticeRecord(
      id: json['id'] as String,
      moduleId: json['moduleId'] as String,
      moduleName: json['moduleName'] as String,
      recordType: RecordType.values.firstWhere(
        (e) => e.name == json['recordType'],
        orElse: () => RecordType.moduleComplete,
      ),
      completedAt: DateTime.parse(json['completedAt'] as String),
      totalDuration: Duration(seconds: json['totalDuration'] as int),
      estimatedDuration: Duration(seconds: json['estimatedDuration'] as int),
      taskRecords: (json['taskRecords'] as List<dynamic>)
          .map((t) => TaskRecord.fromJson(t as Map<String, dynamic>))
          .toList(),
      keyEvents: (json['keyEvents'] as List<dynamic>?)
              ?.map((e) => KeyEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  PracticeRecord copyWith({
    String? id,
    String? moduleId,
    String? moduleName,
    RecordType? recordType,
    DateTime? completedAt,
    Duration? totalDuration,
    Duration? estimatedDuration,
    List<TaskRecord>? taskRecords,
    List<KeyEvent>? keyEvents,
  }) {
    return PracticeRecord(
      id: id ?? this.id,
      moduleId: moduleId ?? this.moduleId,
      moduleName: moduleName ?? this.moduleName,
      recordType: recordType ?? this.recordType,
      completedAt: completedAt ?? this.completedAt,
      totalDuration: totalDuration ?? this.totalDuration,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      taskRecords: taskRecords ?? this.taskRecords,
      keyEvents: keyEvents ?? this.keyEvents,
    );
  }
}
