import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/practice_history/models/practice_record_model.dart';
import '../providers/practice_history_provider.dart';
import 'ai_config.dart';
import 'ai_models.dart';
import 'ai_service_interface.dart';
import 'dify_ai_service.dart';
import 'volcengine_ai_service.dart';

/// AI配置Provider
final aiConfigProvider = Provider<AIConfig>((ref) {
  return AIConfig.fromEnv();
});

/// AI服务Provider（根据配置自动选择）
final aiServiceProvider = Provider<AIService>((ref) {
  final config = ref.watch(aiConfigProvider);

  switch (config.defaultEngine) {
    case AIEngine.volcengine:
      return VolcengineAIService(config: config.volcengineConfig);
    case AIEngine.dify:
      return DifyAIService(
        apiKey: config.difyConfig.apiKey,
        appId: config.difyConfig.appId,
        baseUrl: config.difyConfig.baseUrl,
      );
  }
});

/// AI分析状态
enum AIAnalysisStatus {
  idle,
  loading,
  success,
  error,
}

/// AI分析状态管理
class AIAnalysisState {
  final AIAnalysisStatus status;
  final AIAnalysisResult? result;
  final String? errorMessage;

  const AIAnalysisState({
    this.status = AIAnalysisStatus.idle,
    this.result,
    this.errorMessage,
  });

  AIAnalysisState copyWith({
    AIAnalysisStatus? status,
    AIAnalysisResult? result,
    String? errorMessage,
  }) {
    return AIAnalysisState(
      status: status ?? this.status,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// AI分析状态 Notifier
class AIAnalysisNotifier extends StateNotifier<AIAnalysisState> {
  final AIService _service;
  final List<PracticeRecord> _records;

  AIAnalysisNotifier(this._service, this._records)
      : super(const AIAnalysisState());

  Future<void> analyze({
    AnalysisType type = AnalysisType.comprehensive,
  }) async {
    if (_records.isEmpty) {
      state = const AIAnalysisState(
        status: AIAnalysisStatus.error,
        errorMessage: '没有训练记录可分析',
      );
      return;
    }

    if (!_service.isAvailable) {
      state = const AIAnalysisState(
        status: AIAnalysisStatus.error,
        errorMessage: 'AI服务未配置，请在.env中设置API密钥',
      );
      return;
    }

    state = const AIAnalysisState(status: AIAnalysisStatus.loading);

    try {
      final result = await _service.analyzeTrainingData(
        records: _records,
        type: type,
      );
      state = AIAnalysisState(
        status: AIAnalysisStatus.success,
        result: result,
      );
    } catch (e) {
      state = AIAnalysisState(
        status: AIAnalysisStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}

/// AI分析 Provider
final aiAnalysisProvider =
    StateNotifierProvider<AIAnalysisNotifier, AIAnalysisState>(
  (ref) {
    final service = ref.watch(aiServiceProvider);
    final recordsAsync = ref.watch(practiceRecordsProvider);
    final records = recordsAsync.valueOrNull ?? [];
    return AIAnalysisNotifier(service, records);
  },
);

/// AI聊天历史Provider
final aiChatHistoryProvider =
    StateProvider<List<ChatMessage>>((ref) => []);

/// AI聊天响应状态
class AIChatState {
  final bool isLoading;
  final String currentResponse;
  final List<ChatMessage> messages;

  const AIChatState({
    this.isLoading = false,
    this.currentResponse = '',
    this.messages = const [],
  });

  AIChatState copyWith({
    bool? isLoading,
    String? currentResponse,
    List<ChatMessage>? messages,
  }) {
    return AIChatState(
      isLoading: isLoading ?? this.isLoading,
      currentResponse: currentResponse ?? this.currentResponse,
      messages: messages ?? this.messages,
    );
  }
}

/// AI聊天 Notifier
class AIChatNotifier extends StateNotifier<AIChatState> {
  final AIService _service;

  AIChatNotifier(this._service) : super(const AIChatState());

  Future<void> sendMessage(String message) async {
    if (!_service.isAvailable) return;

    final userMessage = ChatMessage(
      role: 'user',
      content: message,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      isLoading: true,
      currentResponse: '',
      messages: [...state.messages, userMessage],
    );

    final buffer = StringBuffer();
    try {
      await for (final chunk in _service.chatStream(
        message: message,
        history: state.messages,
      )) {
        buffer.write(chunk);
        state = state.copyWith(currentResponse: buffer.toString());
      }

      final assistantMessage = ChatMessage(
        role: 'assistant',
        content: buffer.toString(),
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        isLoading: false,
        currentResponse: '',
        messages: [...state.messages, assistantMessage],
      );
    } catch (e) {
      final errorMessage = ChatMessage(
        role: 'assistant',
        content: '分析失败: $e',
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        isLoading: false,
        currentResponse: '',
        messages: [...state.messages, errorMessage],
      );
    }
  }

  void clearHistory() {
    state = const AIChatState();
  }
}

/// AI聊天 Provider
final aiChatProvider =
    StateNotifierProvider<AIChatNotifier, AIChatState>((ref) {
  final service = ref.watch(aiServiceProvider);
  return AIChatNotifier(service);
});
