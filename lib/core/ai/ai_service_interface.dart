import '../../features/practice_history/models/practice_record_model.dart';
import 'ai_models.dart';

/// AI服务抽象接口
abstract class AIService {
  /// 分析训练数据并生成建议
  Future<AIAnalysisResult> analyzeTrainingData({
    required List<PracticeRecord> records,
    AnalysisType type = AnalysisType.comprehensive,
  });

  /// 生成个性化建议
  Future<String> generateRecommendations({
    required AIAnalysisResult analysis,
    String? customPrompt,
  });

  /// 预测未来表现
  Future<PredictionResult> predictPerformance({
    required List<PracticeRecord> records,
    Duration? targetDuration,
  });

  /// 流式对话（支持实时交互）
  Stream<String> chatStream({
    required String message,
    List<ChatMessage>? history,
  });

  /// 获取服务名称
  String get serviceName;

  /// 是否可用
  bool get isAvailable;
}
