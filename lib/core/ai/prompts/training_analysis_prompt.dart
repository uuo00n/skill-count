import '../../../features/practice_history/models/practice_record_model.dart';
import '../ai_models.dart';

/// 训练分析Prompt模板
class TrainingAnalysisPrompt {
  /// 系统Prompt
  static const String systemPrompt = '''
你是WorldSkills 2026竞赛训练分析专家，专精于技能训练数据分析。

你的任务是：
1. 分析用户的训练历史记录，识别优势和改进空间
2. 提供具体、可执行的训练建议
3. 预测用户在竞赛中的可能表现
4. 使用专业、鼓励的语气

分析维度：
- 时间管理：总体时长、模块时间分配、任务切换效率
- 效率表现：完成率、准确率、与预估时间的对比
- 趋势分析：进步速度、稳定性、波动性
- 模块表现：各模块的强项和弱项

输出要求：
- 数据驱动：基于实际数据给出分析
- 具体化：避免空泛的建议
- 建设性：指出问题的同时给出解决方案
- 量化指标：使用具体数字支撑分析
''';

  /// Function Calling定义
  static const List<Map<String, dynamic>> functions = [
    {
      'name': 'generate_analysis',
      'description': '生成训练分析报告',
      'parameters': {
        'type': 'object',
        'properties': {
          'overall_rating': {
            'type': 'number',
            'description': '综合评分（0-100）',
          },
          'strengths': {
            'type': 'array',
            'description': '用户的优势（3-5条）',
            'items': {'type': 'string'},
          },
          'weaknesses': {
            'type': 'array',
            'description': '需要改进的方面（3-5条）',
            'items': {'type': 'string'},
          },
          'recommendations': {
            'type': 'array',
            'description': '改进建议',
            'items': {
              'type': 'object',
              'properties': {
                'title': {'type': 'string'},
                'description': {'type': 'string'},
                'priority': {
                  'type': 'string',
                  'enum': ['high', 'medium', 'low'],
                },
                'action_steps': {
                  'type': 'array',
                  'items': {'type': 'string'},
                },
                'related_module': {'type': 'string'},
              },
            },
          },
          'module_efficiencies': {
            'type': 'object',
            'description': '各模块效率分析',
            'additionalProperties': {
              'type': 'object',
              'properties': {
                'module_id': {'type': 'string'},
                'module_name': {'type': 'string'},
                'efficiency': {'type': 'number'},
                'insights': {
                  'type': 'array',
                  'items': {'type': 'string'},
                },
                'tips': {
                  'type': 'array',
                  'items': {'type': 'string'},
                },
              },
            },
          },
          'time_trend': {
            'type': 'object',
            'properties': {
              'trend': {
                'type': 'string',
                'enum': ['improving', 'stable', 'declining'],
              },
              'improvement_rate': {'type': 'number'},
              'summary': {'type': 'string'},
            },
          },
          'predicted_best_time': {
            'type': 'number',
            'description': '预测的最佳完成时间（秒）',
          },
          'confidence': {
            'type': 'number',
            'description': 'AI信心度（0-1）',
          },
        },
        'required': [
          'overall_rating',
          'strengths',
          'weaknesses',
          'recommendations',
          'module_efficiencies',
          'time_trend',
          'predicted_best_time',
          'confidence',
        ],
      },
    },
  ];

  /// 格式化训练记录为Prompt
  static String formatRecords(
    List<PracticeRecord> records,
    AnalysisType type,
  ) {
    final buffer = StringBuffer();

    buffer.writeln('请分析以下训练数据：\n');

    // 总体统计
    final totalRecords = records.length;
    final totalDuration = records.fold<Duration>(
      Duration.zero,
      (sum, r) => sum + r.totalDuration,
    );
    final avgDuration =
        Duration(seconds: totalDuration.inSeconds ~/ totalRecords);
    final avgEfficiency =
        records.fold<double>(0, (sum, r) => sum + r.efficiency) /
            totalRecords;

    buffer.writeln('总体统计：');
    buffer.writeln('- 总记录数: $totalRecords');
    buffer.writeln('- 总时长: ${_formatDuration(totalDuration)}');
    buffer.writeln('- 平均时长: ${_formatDuration(avgDuration)}');
    buffer.writeln('- 平均效率: ${(avgEfficiency * 100).toInt()}%\n');

    // 按模块分组
    final moduleGroups = <String, List<PracticeRecord>>{};
    for (final record in records) {
      moduleGroups.putIfAbsent(record.moduleId, () => []).add(record);
    }

    buffer.writeln('模块分析：');
    for (final entry in moduleGroups.entries) {
      final moduleRecords = entry.value;
      final moduleTotal = moduleRecords.fold<Duration>(
        Duration.zero,
        (sum, r) => sum + r.totalDuration,
      );
      final moduleAvgDuration = Duration(
        seconds: moduleTotal.inSeconds ~/ moduleRecords.length,
      );
      final moduleAvgEfficiency = moduleRecords.fold<double>(
            0,
            (sum, r) => sum + r.efficiency,
          ) /
          moduleRecords.length;

      buffer.writeln(
        '\n模块: ${moduleRecords.first.moduleName} (${entry.key})',
      );
      buffer.writeln('  - 练习次数: ${moduleRecords.length}');
      buffer
          .writeln('  - 平均时长: ${_formatDuration(moduleAvgDuration)}');
      buffer.writeln(
        '  - 平均效率: ${(moduleAvgEfficiency * 100).toInt()}%',
      );

      // 时间趋势
      final sorted = List<PracticeRecord>.from(moduleRecords)
        ..sort((a, b) => a.completedAt.compareTo(b.completedAt));
      if (sorted.length > 1) {
        final firstDuration = sorted.first.totalDuration.inSeconds;
        final lastDuration = sorted.last.totalDuration.inSeconds;
        if (firstDuration > 0) {
          final improvement =
              ((firstDuration - lastDuration) / firstDuration * 100);
          buffer.writeln(
            '  - 时间改进: ${improvement.toStringAsFixed(1)}%',
          );
        }
      }

      // 任务分析
      for (final record in moduleRecords) {
        if (record.taskRecords.isNotEmpty) {
          buffer.writeln(
            '  - 任务完成率: ${record.completedTasks}/${record.totalTasks}',
          );
        }
      }
    }

    // 根据分析类型添加特定要求
    buffer.writeln('\n分析要求：');
    switch (type) {
      case AnalysisType.comprehensive:
        buffer.writeln('- 提供全面的分析，包括所有维度');
      case AnalysisType.efficiency:
        buffer.writeln('- 重点关注效率分析');
      case AnalysisType.timeTrend:
        buffer.writeln('- 重点关注时间趋势和改进速度');
      case AnalysisType.prediction:
        buffer.writeln('- 重点关注未来表现预测');
      case AnalysisType.weaknessAnalysis:
        buffer.writeln('- 重点关注待改进点和解决方案');
    }

    return buffer.toString();
  }

  /// 构建预测Prompt
  static String buildPredictionPrompt(
    List<PracticeRecord> records,
    Duration? targetDuration,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('基于以下训练数据，预测未来的表现：\n');
    buffer.writeln(formatRecords(records, AnalysisType.prediction));

    if (targetDuration != null) {
      buffer.writeln('\n目标时长: ${_formatDuration(targetDuration)}');
      buffer.writeln('请分析达成目标的可能性，并提供改进建议。');
    }

    return buffer.toString();
  }

  static String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '$hours小时$minutes分钟';
    } else if (minutes > 0) {
      return '$minutes分钟$seconds秒';
    } else {
      return '$seconds秒';
    }
  }
}
