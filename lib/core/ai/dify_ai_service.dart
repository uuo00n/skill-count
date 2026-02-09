import '../../features/practice_history/models/practice_record_model.dart';
import 'ai_models.dart';
import 'ai_service_interface.dart';

/// Dify AI服务实现（预留）
class DifyAIService implements AIService {
  final String apiKey;
  final String baseUrl;
  final String appId;

  DifyAIService({
    required this.apiKey,
    this.baseUrl = 'https://api.dify.ai/v1',
    required this.appId,
  });

  @override
  String get serviceName => 'Dify AI';

  @override
  bool get isAvailable => apiKey.isNotEmpty && appId.isNotEmpty;

  @override
  Future<AIAnalysisResult> analyzeTrainingData({
    required List<PracticeRecord> records,
    AnalysisType type = AnalysisType.comprehensive,
    String? languageName,
  }) async {
    throw UnimplementedError('Dify integration pending');
  }

  @override
  Future<String> generateRecommendations({
    required AIAnalysisResult analysis,
    String? customPrompt,
  }) async {
    throw UnimplementedError('Dify integration pending');
  }

  @override
  Future<PredictionResult> predictPerformance({
    required List<PracticeRecord> records,
    Duration? targetDuration,
  }) async {
    throw UnimplementedError('Dify integration pending');
  }

  @override
  Stream<String> chatStream({
    required String message,
    List<ChatMessage>? history,
  }) async* {
    yield '错误：Dify集成尚未实现';
  }
}
