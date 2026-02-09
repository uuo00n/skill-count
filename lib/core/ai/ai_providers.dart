import 'dart:async';
import 'dart:io';

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
        errorMessage: _formatAIError(e),
      );
    }
  }
}

String _formatAIError(Object error) {
  if (error is TimeoutException) {
    return '请求超时：AI服务在规定时间内未响应\n\n'
        '可能原因：网络不可达/代理未配置、服务端响应较慢、或模型配置不正确\n\n'
        '建议：检查网络后重试；如仍超时，可在 .env 中设置 VOLCENGINE_TIMEOUT=90 或更大';
  }

  if (error is SocketException) {
    return '网络连接失败：${error.message}\n\n'
        '建议：检查网络、代理/VPN、防火墙设置后重试';
  }

  final message = error.toString();
  if (message.contains('AI服务未配置')) {
    return 'AI服务未配置：请在 .env 中设置 VOLCENGINE_API_KEY（以及 VOLCENGINE_MODEL）';
  }

  if (message.contains('API请求失败')) {
    return '$message\n\n建议：确认 VOLCENGINE_ENDPOINT / VOLCENGINE_MODEL 配置正确';
  }

  if (message.contains('API未返回结构化结果')) {
    return 'AI返回结果格式不符合预期（未包含 function_call/tool_calls，也未输出 JSON）\n\n'
        '常见原因：VOLCENGINE_MODEL 不支持工具/函数调用，或服务端忽略了 function_call\n\n'
        '建议：检查 .env 中 VOLCENGINE_MODEL 是否为支持 function/tool 的模型，并重试';
  }

  return message;
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
        content: _formatAIError(e),
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
