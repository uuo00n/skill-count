import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../features/practice_history/models/practice_record_model.dart';
import 'ai_config.dart';
import 'ai_models.dart';
import 'ai_service_interface.dart';
import 'prompts/training_analysis_prompt.dart';

/// 火山云AI服务实现
class VolcengineAIService implements AIService {
  final VolcengineConfig _config;
  final http.Client _client;

  VolcengineAIService({
    VolcengineConfig? config,
    http.Client? client,
  })  : _config = config ?? const VolcengineConfig(),
        _client = client ?? http.Client();

  @override
  String get serviceName => '火山云AI';

  @override
  bool get isAvailable => _config.apiKey.isNotEmpty;

  @override
  Future<AIAnalysisResult> analyzeTrainingData({
    required List<PracticeRecord> records,
    AnalysisType type = AnalysisType.comprehensive,
  }) async {
    if (!isAvailable) {
      throw Exception('火山云AI服务未配置');
    }

    if (records.isEmpty) {
      throw Exception('没有可分析的训练记录');
    }

    final prompt =
        TrainingAnalysisPrompt.formatRecords(records, type);

    final requestBody = {
      'model': _config.model,
      'messages': [
        {
          'role': 'system',
          'content': TrainingAnalysisPrompt.systemPrompt,
        },
        {
          'role': 'user',
          'content': prompt,
        },
      ],
      'temperature': 0.7,
      'max_tokens': 2000,
      'functions': TrainingAnalysisPrompt.functions,
      'function_call': {'name': 'generate_analysis'},
      'tools': _buildTools(TrainingAnalysisPrompt.functions),
      'tool_choice': {
        'type': 'function',
        'function': {'name': 'generate_analysis'},
      },
    };

    final response = await _postJson(
      path: '/chat/completions',
      body: requestBody,
      timeoutSeconds: _config.timeout,
    );

    if (response.statusCode != 200) {
      throw Exception('API请求失败: ${response.statusCode}');
    }

    final data =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final choices = data['choices'] as List<dynamic>;
    if (choices.isEmpty) {
      throw Exception('API返回空结果');
    }

    final message = choices[0]['message'] as Map<String, dynamic>;

    final toolArgs = _extractToolOrFunctionArgs(message);
    if (toolArgs != null) {
      return AIAnalysisResult.fromJson(toolArgs);
    }

    final content = message['content'] as String?;
    final contentArgs = _tryParseJsonObject(content);
    if (contentArgs != null) {
      return AIAnalysisResult.fromJson(contentArgs);
    }

    throw Exception('API未返回结构化结果（function_call/tool_calls/JSON content）');
  }

  @override
  Future<String> generateRecommendations({
    required AIAnalysisResult analysis,
    String? customPrompt,
  }) async {
    final prompt = customPrompt ??
        '''
基于以下分析结果，提供具体的改进建议：

综合评分: ${analysis.overallRating}/100
优势: ${analysis.strengths.join(', ')}
待改进: ${analysis.weaknesses.join(', ')}

请提供3-5条具体的、可执行的建议。
''';

    return _chatWithAI(prompt);
  }

  @override
  Future<PredictionResult> predictPerformance({
    required List<PracticeRecord> records,
    Duration? targetDuration,
  }) async {
    if (!isAvailable) {
      throw Exception('火山云AI服务未配置');
    }

    final prompt = TrainingAnalysisPrompt.buildPredictionPrompt(
      records,
      targetDuration,
    );

    final response = await _chatWithAI(prompt);

    return PredictionResult(
      predictedTime: _extractPredictedTime(response),
      confidence: _extractConfidence(response),
      factors: _extractFactors(response),
      explanation: response,
    );
  }

  @override
  Stream<String> chatStream({
    required String message,
    List<ChatMessage>? history,
  }) async* {
    if (!isAvailable) {
      yield '错误：AI服务未配置';
      return;
    }

    final messages = <Map<String, String>>[
      {
        'role': 'system',
        'content': TrainingAnalysisPrompt.systemPrompt,
      },
      if (history != null)
        ...history.map((m) => {
              'role': m.role,
              'content': m.content,
            }),
      {'role': 'user', 'content': message},
    ];

    final requestBody = {
      'model': _config.model,
      'messages': messages,
      'stream': true,
      'temperature': 0.7,
    };

    final request = http.Request(
      'POST',
      Uri.parse('${_config.endpoint}/chat/completions'),
    );
    request.headers.addAll({
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${_config.apiKey}',
    });
    request.body = jsonEncode(requestBody);

    final streamedResponse = await _client
        .send(request)
        .timeout(Duration(seconds: _config.timeout));

    if (streamedResponse.statusCode != 200) {
      final bodyBytes = await streamedResponse.stream.toBytes();
      final bodyText = utf8.decode(bodyBytes);
      throw Exception('API请求失败: ${streamedResponse.statusCode}\n$bodyText');
    }

    await for (final chunk
        in streamedResponse.stream.timeout(Duration(seconds: _config.timeout))) {
      final lines = utf8.decode(chunk).split('\n');
      for (final line in lines) {
        if (line.startsWith('data: ')) {
          final data = line.substring(6);
          if (data == '[DONE]') continue;

          try {
            final json =
                jsonDecode(data) as Map<String, dynamic>;
            final choices = json['choices'] as List<dynamic>;
            if (choices.isNotEmpty) {
              final delta = choices[0]['delta']
                  as Map<String, dynamic>?;
              final content = delta?['content'] as String?;
              if (content != null) {
                yield content;
              }
            }
          } catch (_) {
            // 忽略解析错误
          }
        }
      }
    }
  }

  Future<String> _chatWithAI(String prompt) async {
    final response = await _postJson(
      path: '/chat/completions',
      body: {
        'model': _config.model,
        'messages': [
          {
            'role': 'system',
            'content': TrainingAnalysisPrompt.systemPrompt,
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        'temperature': 0.7,
        'max_tokens': 1000,
      },
      timeoutSeconds: _config.timeout,
    );

    if (response.statusCode != 200) {
      throw Exception('API请求失败: ${response.statusCode}');
    }

    final data =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final choices = data['choices'] as List<dynamic>;
    if (choices.isEmpty) {
      throw Exception('API返回空结果');
    }

    final message =
        choices[0]['message'] as Map<String, dynamic>;
    return message['content'] as String? ?? '';
  }

  List<Map<String, dynamic>> _buildTools(List<Map<String, dynamic>> functions) {
    return functions
        .map(
          (fn) => {
            'type': 'function',
            'function': {
              'name': fn['name'],
              'description': fn['description'],
              'parameters': fn['parameters'],
            },
          },
        )
        .toList();
  }

  Map<String, dynamic>? _extractToolOrFunctionArgs(
    Map<String, dynamic> message,
  ) {
    final toolCalls = message['tool_calls'];
    if (toolCalls is List && toolCalls.isNotEmpty) {
      final first = toolCalls.first;
      if (first is Map<String, dynamic>) {
        final fn = first['function'];
        if (fn is Map<String, dynamic>) {
          final args = fn['arguments'];
          if (args is String && args.trim().isNotEmpty) {
            final decoded = jsonDecode(args);
            if (decoded is Map<String, dynamic>) return decoded;
          }
        }
      }
    }

    final functionCall = message['function_call'];
    if (functionCall is Map<String, dynamic>) {
      final args = functionCall['arguments'];
      if (args is String && args.trim().isNotEmpty) {
        final decoded = jsonDecode(args);
        if (decoded is Map<String, dynamic>) return decoded;
      }
    }

    return null;
  }

  Map<String, dynamic>? _tryParseJsonObject(String? content) {
    if (content == null) return null;
    final text = content.trim();
    if (text.isEmpty) return null;

    try {
      final decoded = jsonDecode(text);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}

    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start >= 0 && end > start) {
      final maybeJson = text.substring(start, end + 1);
      try {
        final decoded = jsonDecode(maybeJson);
        if (decoded is Map<String, dynamic>) return decoded;
      } catch (_) {}
    }

    return null;
  }

  Future<http.Response> _postJson({
    required String path,
    required Map<String, dynamic> body,
    required int timeoutSeconds,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('${_config.endpoint}$path'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${_config.apiKey}',
            },
            body: jsonEncode(body),
          )
          .timeout(Duration(seconds: timeoutSeconds));
      return response;
    } on TimeoutException {
      throw TimeoutException(
        'Timeout after 0:00:${timeoutSeconds.toString().padLeft(2, '0')}.000000: Future not completed',
      );
    } on SocketException catch (e) {
      throw Exception('网络连接失败: ${e.message}');
    } on HandshakeException catch (e) {
      throw Exception('TLS握手失败: ${e.message}');
    }
  }

  Duration _extractPredictedTime(String response) {
    final regex = RegExp(r'(\d+)小时(\d+)分钟');
    final match = regex.firstMatch(response);
    if (match != null) {
      final hours = int.parse(match.group(1)!);
      final minutes = int.parse(match.group(2)!);
      return Duration(hours: hours, minutes: minutes);
    }
    return const Duration(hours: 2, minutes: 30);
  }

  double _extractConfidence(String response) {
    final regex = RegExp(r'信心度[：:]\s*(\d+)');
    final match = regex.firstMatch(response);
    if (match != null) {
      return int.parse(match.group(1)!) / 100;
    }
    return 0.85;
  }

  List<String> _extractFactors(String response) {
    return ['时间趋势稳定', '效率持续提升', '任务完成率高'];
  }
}
