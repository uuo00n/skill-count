/// 推荐优先级
enum RecommendationPriority {
  high,
  medium,
  low,
}

/// 趋势类型
enum TrendType {
  improving,
  stable,
  declining,
}

/// 分析类型
enum AnalysisType {
  comprehensive,
  efficiency,
  timeTrend,
  prediction,
  weaknessAnalysis,
}

/// 训练建议
class TrainingRecommendation {
  final String title;
  final String description;
  final RecommendationPriority priority;
  final List<String> actionSteps;
  final String? relatedModule;

  const TrainingRecommendation({
    required this.title,
    required this.description,
    required this.priority,
    required this.actionSteps,
    this.relatedModule,
  });

  factory TrainingRecommendation.fromJson(Map<String, dynamic> json) {
    return TrainingRecommendation(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      priority: RecommendationPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => RecommendationPriority.medium,
      ),
      actionSteps: (json['action_steps'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      relatedModule: json['related_module'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'priority': priority.name,
        'action_steps': actionSteps,
        if (relatedModule != null) 'related_module': relatedModule,
      };
}

/// 模块效率分析
class ModuleEfficiencyAnalysis {
  final String moduleId;
  final String moduleName;
  final double efficiency;
  final List<String> insights;
  final List<String> tips;

  const ModuleEfficiencyAnalysis({
    required this.moduleId,
    required this.moduleName,
    required this.efficiency,
    required this.insights,
    required this.tips,
  });

  factory ModuleEfficiencyAnalysis.fromJson(Map<String, dynamic> json) {
    return ModuleEfficiencyAnalysis(
      moduleId: json['module_id'] as String? ?? '',
      moduleName: json['module_name'] as String? ?? '',
      efficiency: (json['efficiency'] as num?)?.toDouble() ?? 0.0,
      insights: (json['insights'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      tips: (json['tips'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'module_id': moduleId,
        'module_name': moduleName,
        'efficiency': efficiency,
        'insights': insights,
        'tips': tips,
      };
}

/// 时间趋势分析
class TimeTrendAnalysis {
  final TrendType trend;
  final double improvementRate;
  final String summary;

  const TimeTrendAnalysis({
    required this.trend,
    required this.improvementRate,
    required this.summary,
  });

  factory TimeTrendAnalysis.fromJson(Map<String, dynamic> json) {
    return TimeTrendAnalysis(
      trend: TrendType.values.firstWhere(
        (e) => e.name == json['trend'],
        orElse: () => TrendType.stable,
      ),
      improvementRate:
          (json['improvement_rate'] as num?)?.toDouble() ?? 0.0,
      summary: json['summary'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'trend': trend.name,
        'improvement_rate': improvementRate,
        'summary': summary,
      };
}

/// AI分析结果
class AIAnalysisResult {
  final String id;
  final double overallRating;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<TrainingRecommendation> recommendations;
  final Map<String, ModuleEfficiencyAnalysis> moduleEfficiencies;
  final TimeTrendAnalysis timeTrend;
  final Duration predictedBestTime;
  final DateTime analyzedAt;
  final double confidence;

  const AIAnalysisResult({
    required this.id,
    required this.overallRating,
    required this.strengths,
    required this.weaknesses,
    required this.recommendations,
    required this.moduleEfficiencies,
    required this.timeTrend,
    required this.predictedBestTime,
    required this.analyzedAt,
    required this.confidence,
  });

  factory AIAnalysisResult.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return AIAnalysisResult(
      id: json['id'] as String? ??
          now.millisecondsSinceEpoch.toString(),
      overallRating:
          (json['overall_rating'] as num?)?.toDouble() ?? 0.0,
      strengths: (json['strengths'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      weaknesses: (json['weaknesses'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      recommendations: (json['recommendations'] as List<dynamic>?)
              ?.map((r) =>
                  TrainingRecommendation.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
      moduleEfficiencies: (json['module_efficiencies']
                  as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(
                  key,
                  ModuleEfficiencyAnalysis.fromJson(
                      value as Map<String, dynamic>))) ??
          {},
      timeTrend: json['time_trend'] != null
          ? TimeTrendAnalysis.fromJson(
              json['time_trend'] as Map<String, dynamic>)
          : const TimeTrendAnalysis(
              trend: TrendType.stable,
              improvementRate: 0,
              summary: '',
            ),
      predictedBestTime: Duration(
        seconds: (json['predicted_best_time'] as num?)?.toInt() ?? 0,
      ),
      analyzedAt: json['analyzed_at'] != null
          ? DateTime.parse(json['analyzed_at'] as String)
          : now,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'overall_rating': overallRating,
        'strengths': strengths,
        'weaknesses': weaknesses,
        'recommendations': recommendations.map((r) => r.toJson()).toList(),
        'module_efficiencies': moduleEfficiencies
            .map((key, value) => MapEntry(key, value.toJson())),
        'time_trend': timeTrend.toJson(),
        'predicted_best_time': predictedBestTime.inSeconds,
        'analyzed_at': analyzedAt.toIso8601String(),
        'confidence': confidence,
      };
}

/// 预测结果
class PredictionResult {
  final Duration predictedTime;
  final double confidence;
  final List<String> factors;
  final String explanation;

  const PredictionResult({
    required this.predictedTime,
    required this.confidence,
    required this.factors,
    required this.explanation,
  });
}

/// 聊天消息
class ChatMessage {
  final String role;
  final String content;
  final DateTime timestamp;

  const ChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
  });
}
