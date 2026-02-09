import 'dart:async';
import 'dart:convert';

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
    };

    final response = await _client
        .post(
          Uri.parse('${_config.endpoint}/chat/completions'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${_config.apiKey}',
          },
          body: jsonEncode(requestBody),
        )
        .timeout(Duration(seconds: _config.timeout));

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
    final functionCall =
        message['function_call'] as Map<String, dynamic>?;

    if (functionCall == null) {
      throw Exception('API未返回function_call结果');
    }

    final functionArgs = jsonDecode(functionCall['arguments'] as String)
        as Map<String, dynamic>;

    return AIAnalysisResult.fromJson(functionArgs);
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

    final streamedResponse = await _client.send(request);

    await for (final chunk in streamedResponse.stream) {
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
    final response = await _client
        .post(
          Uri.parse('${_config.endpoint}/chat/completions'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${_config.apiKey}',
          },
          body: jsonEncode({
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
          }),
        )
        .timeout(Duration(seconds: _config.timeout));

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
