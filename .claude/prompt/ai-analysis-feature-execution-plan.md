# AI智能分析功能执行计划

## 📋 项目概述

为 SkillCount 应用的数据分析页面添加基于历史训练记录的AI智能分析功能，使用火山云引擎API提供智能训练建议和个性化分析报告，同时为未来集成Dify AI Agent预留扩展点。

## 🎯 核心目标

- **智能分析**：基于历史训练数据，AI分析用户的训练表现和进步趋势
- **个性化建议**：提供针对性的训练改进建议和技能提升方案
- **预测分析**：预测未来表现，设定合理的目标时间
- **模块化架构**：支持火山云API和Dify AI Agent两种后端，便于切换和扩展
- **符合设计**：保持与现有UI风格一致，使用WorldSkills主题配色

## 🛠 技术选型

### 1. 火山云引擎API（主要方案）

**选择理由：**
- ✅ 专为中文优化的AI模型（豆包/字节跳动大模型）
- ✅ 支持多模态输入（文本、结构化数据）
- ✅ API稳定，响应速度快
- ✅ 成本可控，支持免费额度
- ✅ 国内访问稳定，符合合规要求

**相关API：**
- Chat API：对话式交互
- Function Calling：结构化数据输出
- Streaming：流式响应提升体验

### 2. Dify AI Agent（预留扩展点）

**预留理由：**
- ✅ 可视化AI工作流编排
- ✅ 支持自定义知识库
- ✅ 更灵活的Prompt管理
- ✅ 未来可以接入更多AI模型

**扩展策略：**
- 抽象统一AI服务接口
- 配置化切换后端
- 保持Prompt模板兼容

### 3. 依赖管理

```yaml
dependencies:
  # HTTP 客户端
  http: ^1.2.0

  # JSON序列化（已有）
  json_annotation: ^4.9.0

  # 环境配置
  flutter_dotenv: ^5.1.0

  # 状态管理（已有）
  flutter_riverpod: ^2.6.1

dev_dependencies:
  # JSON代码生成
  build_runner: ^2.4.0
  json_serializable: ^6.8.0
```

## 📂 文件结构

```
lib/
├── core/
│   ├── ai/
│   │   ├── ai_service_interface.dart           # AI服务抽象接口
│   │   ├── volcengine_ai_service.dart          # 火山云AI服务实现
│   │   ├── dify_ai_service.dart                # Dify AI服务实现（预留）
│   │   ├── ai_config.dart                      # AI配置管理
│   │   ├── ai_providers.dart                   # Riverpod Providers
│   │   └── prompts/
│   │       ├── training_analysis_prompt.dart  # 训练分析Prompt模板
│   │       ├── recommendation_prompt.dart     # 建议生成Prompt模板
│   │       └── dify_prompts.dart              # Dify专用Prompt（预留）
│   ├── models/
│   │   └── ai_analysis_result.dart            # AI分析结果模型
│   ├── constants/
│   │   └── ai_constants.dart                  # AI相关常量
│   └── i18n/
│       ├── strings.dart                       # 添加AI分析相关字符串
│       ├── zh.dart                            # 中文翻译
│       └── en.dart                            # 英文翻译
├── features/
│   └── practice_history/
│       └── widgets/
│           ├── ai_insight_card.dart           # AI洞察卡片组件
│           ├── ai_analysis_panel.dart         # AI分析面板
│           ├── ai_recommendation_widget.dart  # AI推荐组件
│           └── ai_prediction_chart.dart       # AI预测图表
├── .env                                        # 环境变量配置
└── pubspec.yaml
```

## 🏗 架构设计

### 1. AI服务抽象层

```dart
/// AI服务接口
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
    Duration targetDuration,
  });

  /// 流式对话（支持实时交互）
  Stream<String> chatStream({
    required String message,
    List<ChatMessage>? history,
  });
}
```

### 2. 数据流设计

```
用户触发分析
    ↓
读取历史记录（PracticeHistoryService）
    ↓
格式化数据为AI输入格式
    ↓
调用AI服务（VolcengineAIService）
    ↓
接收结构化分析结果
    ↓
渲染UI（AI分析面板/图表）
    ↓
用户交互（询问/调整目标）
    ↓
流式对话获取进一步建议
```

### 3. API集成设计

#### 3.1 火山云API集成

**认证方式：**
```dart
class VolcengineConfig {
  final String apiKey;
  final String endpoint;
  final String model;
  final int timeout;

  const VolcengineConfig({
    required this.apiKey,
    this.endpoint = 'https://ark.cn-beijing.volces.com/api/v3',
    this.model = 'ep-2024xxxx',
    this.timeout = 30,
  });
}
```

**API请求格式：**
```dart
{
  "model": "ep-2024xxxx",
  "messages": [
    {
      "role": "system",
      "content": "你是WorldSkills竞赛训练分析专家..."
    },
    {
      "role": "user",
      "content": "分析以下训练数据..."
    }
  ],
  "functions": [
    {
      "name": "generate_analysis",
      "description": "生成训练分析报告",
      "parameters": {
        "type": "object",
        "properties": {
          "overall_rating": {"type": "number"},
          "strengths": {"type": "array"},
          "weaknesses": {"type": "array"},
          "recommendations": {"type": "array"},
          "target_time_prediction": {"type": "string"}
        }
      }
    }
  ]
}
```

#### 3.2 Dify扩展点预留

```dart
/// Dify AI服务实现（预留）
class DifyAIService extends AIService {
  final String apiKey;
  final String baseUrl;
  final String appId;

  DifyAIService({
    required this.apiKey,
    this.baseUrl = 'https://api.dify.ai/v1',
    required this.appId,
  });

  // 使用Dify的工作流API
  @override
  Future<AIAnalysisResult> analyzeTrainingData({
    required List<PracticeRecord> records,
    AnalysisType type = AnalysisType.comprehensive,
  }) async {
    // 调用Dify工作流
    // 预留实现
    throw UnimplementedError('Dify integration pending');
  }
}
```

## 📊 数据模型设计

### 1. AI分析结果模型

```dart
/// AI分析结果
class AIAnalysisResult {
  /// 综合评分（0-100）
  final double overallRating;

  /// 优势分析
  final List<String> strengths;

  /// 待改进点
  final List<String> weaknesses;

  /// 改进建议
  final List<TrainingRecommendation> recommendations;

  /// 模块效率分析
  final Map<String, ModuleEfficiencyAnalysis> moduleEfficiencies;

  /// 时间趋势分析
  final TimeTrendAnalysis timeTrend;

  /// 预测的最佳时间
  final Duration predictedBestTime;

  /// 分析时间戳
  final DateTime analyzedAt;

  /// AI信心度（0-1）
  final double confidence;
}

/// 训练建议
class TrainingRecommendation {
  final String title;
  final String description;
  final RecommendationPriority priority;
  final List<String> actionSteps;
  final String? relatedModule;
}

/// 模块效率分析
class ModuleEfficiencyAnalysis {
  final String moduleId;
  final String moduleName;
  final double efficiency;
  final List<String> insights;
  final List<String> tips;
}

/// 时间趋势分析
class TimeTrendAnalysis {
  final TrendType trend; // improving, stable, declining
  final double improvementRate; // 每次练习的改进百分比
  final String summary;
}

/// 预测结果
class PredictionResult {
  final Duration predictedTime;
  final double confidence;
  final List<String> factors;
  final String explanation;
}

/// 聊天消息
class ChatMessage {
  final String role; // system, user, assistant
  final String content;
  final DateTime timestamp;
}
```

## 🎨 UI设计

### 1. AI分析面板布局

```
┌─────────────────────────────────────────────────────────────┐
│  AI 智能分析                            [切换AI引擎: 火山云 ▼] │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  综合评分: 85/100                  信心度: 92%     │    │
│  │  ████████████████████████████░░░░                  │    │
│  │                                                     │    │
│  │  ✅ 你的表现正在稳步提升，相比上次提升了12%          │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
│  📊 核心洞察                                                 │
│  ┌─────────┬─────────┬─────────┬─────────┐               │
│  │ 优势    │ 需改进   │ 建议    │ 预测    │               │
│  ├─────────┼─────────┼─────────┼─────────┤               │
│  │ • 时间  │ • 任务  │ • 练习  │ 最佳:   │               │
│  │   管理强 │   切换  │   模块A │ 2h30m   │               │
│  │         │   效率  │ • 专注  │         │               │
│  │ • 完成  │         │   任务B │         │               │
│  │   率高  │         │         │         │               │
│  └─────────┴─────────┴─────────┴─────────┘               │
│                                                             │
│  📈 改进趋势图                                              │
│  [图表：时间趋势线 + 预测曲线]                              │
│                                                             │
│  💬 与AI对话                                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ 输入你的问题...                                       │    │
│  └─────────────────────────────────────────────────────┘    │
│  [发送]                                                     │
└─────────────────────────────────────────────────────────────┘
```

### 2. 组件层次结构

```
AIAnalysisPanel
├── AIHeader
│   ├── Title (AI智能分析)
│   └── EngineSelector
├── AIOverviewCard
│   ├── RatingGauge
│   ├── SummaryText
│   └── ConfidenceBadge
├── AIInsightsGrid
│   ├── StrengthsColumn
│   ├── WeaknessesColumn
│   ├── RecommendationsColumn
│   └── PredictionColumn
├── AIChartView
│   ├── TimeTrendChart
│   └── PredictionOverlay
└── AIChatPanel
    ├── ChatHistory
    ├── InputField
    └── SendButton
```

## 🚀 实施步骤

### Phase 1: 基础设施搭建（第1周）

#### 步骤 1: 添加依赖和配置

**文件：`pubspec.yaml`**

```yaml
dependencies:
  http: ^1.2.0
  json_annotation: ^4.9.0
  flutter_dotenv: ^5.1.0

dev_dependencies:
  json_serializable: ^6.8.0
```

**文件：`.env`**

```env
# 火山云API配置
VOLCENGINE_API_KEY=your_api_key_here
VOLCENGINE_ENDPOINT=https://ark.cn-beijing.volces.com/api/v3
VOLCENGINE_MODEL=ep-2024xxxx

# Dify配置（预留）
DIFY_API_KEY=your_dify_api_key_here
DIFY_BASE_URL=https://api.dify.ai/v1
DIFY_APP_ID=your_app_id_here

# AI引擎选择：volcengine 或 dify
AI_ENGINE=volcengine
```

#### 步骤 2: 创建AI服务抽象层

**文件：`lib/core/ai/ai_service_interface.dart`**

```dart
import '../models/ai_analysis_result.dart';
import '../models/practice_record_model.dart';

/// 分析类型
enum AnalysisType {
  comprehensive,
  efficiency,
  timeTrend,
  prediction,
  weaknessAnalysis,
}

/// AI服务接口
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
```

#### 步骤 3: 创建AI数据模型

**文件：`lib/core/models/ai_analysis_result.dart`**

```dart
import 'package:json_annotation/json_annotation.dart';

part 'ai_analysis_result.g.dart';

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

/// 训练建议
@JsonSerializable()
class TrainingRecommendation {
  final String title;
  final String description;
  @JsonKey(name: 'priority')
  final RecommendationPriority priority;
  @JsonKey(name: 'action_steps')
  final List<String> actionSteps;
  @JsonKey(name: 'related_module')
  final String? relatedModule;

  TrainingRecommendation({
    required this.title,
    required this.description,
    required this.priority,
    required this.actionSteps,
    this.relatedModule,
  });

  factory TrainingRecommendation.fromJson(Map<String, dynamic> json) =>
      _$TrainingRecommendationFromJson(json);

  Map<String, dynamic> toJson() => _$TrainingRecommendationToJson(this);
}

/// 模块效率分析
@JsonSerializable()
class ModuleEfficiencyAnalysis {
  @JsonKey(name: 'module_id')
  final String moduleId;
  @JsonKey(name: 'module_name')
  final String moduleName;
  final double efficiency;
  final List<String> insights;
  final List<String> tips;

  ModuleEfficiencyAnalysis({
    required this.moduleId,
    required this.moduleName,
    required this.efficiency,
    required this.insights,
    required this.tips,
  });

  factory ModuleEfficiencyAnalysis.fromJson(Map<String, dynamic> json) =>
      _$ModuleEfficiencyAnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$ModuleEfficiencyAnalysisToJson(this);
}

/// 时间趋势分析
@JsonSerializable()
class TimeTrendAnalysis {
  final TrendType trend;
  @JsonKey(name: 'improvement_rate')
  final double improvementRate;
  final String summary;

  TimeTrendAnalysis({
    required this.trend,
    required this.improvementRate,
    required this.summary,
  });

  factory TimeTrendAnalysis.fromJson(Map<String, dynamic> json) =>
      _$TimeTrendAnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$TimeTrendAnalysisToJson(this);
}

/// AI分析结果
@JsonSerializable()
class AIAnalysisResult {
  @JsonKey(name: 'overall_rating')
  final double overallRating;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<TrainingRecommendation> recommendations;
  @JsonKey(name: 'module_efficiencies')
  final Map<String, ModuleEfficiencyAnalysis> moduleEfficiencies;
  @JsonKey(name: 'time_trend')
  final TimeTrendAnalysis timeTrend;
  @JsonKey(name: 'predicted_best_time')
  final Duration predictedBestTime;
  @JsonKey(name: 'analyzed_at')
  final DateTime analyzedAt;
  final double confidence;

  AIAnalysisResult({
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

  factory AIAnalysisResult.fromJson(Map<String, dynamic> json) =>
      _$AIAnalysisResultFromJson(json);

  Map<String, dynamic> toJson() => _$AIAnalysisResultToJson(this);
}

/// 预测结果
@JsonSerializable()
class PredictionResult {
  @JsonKey(name: 'predicted_time')
  final Duration predictedTime;
  final double confidence;
  final List<String> factors;
  final String explanation;

  PredictionResult({
    required this.predictedTime,
    required this.confidence,
    required this.factors,
    required this.explanation,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) =>
      _$PredictionResultFromJson(json);

  Map<String, dynamic> toJson() => _$PredictionResultToJson(this);
}

/// 聊天消息
@JsonSerializable()
class ChatMessage {
  final String role;
  final String content;
  @JsonKey(name: 'timestamp')
  final DateTime timestamp;

  ChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);
}
```

### Phase 2: 火山云API实现（第2周）

#### 步骤 4: 创建火山云AI服务

**文件：`lib/core/ai/volcengine_ai_service.dart`**

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/ws_colors.dart';
import '../models/ai_analysis_result.dart';
import '../models/practice_record_model.dart';
import 'ai_service_interface.dart';
import 'ai_config.dart';
import 'prompts/training_analysis_prompt.dart';

/// 火山云AI服务实现
class VolcengineAIService extends AIService {
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

    try {
      // 格式化数据为AI输入
      final prompt = TrainingAnalysisPrompt.formatRecords(records, type);

      // 构建API请求
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

      // 发送请求
      final response = await _client.post(
        Uri.parse('$_config.endpoint/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_config.apiKey}',
        },
        body: jsonEncode(requestBody),
      ).timeout(
        Duration(seconds: _config.timeout),
      );

      if (response.statusCode != 200) {
        throw Exception('API请求失败: ${response.statusCode}');
      }

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final functionCall = data['choices'][0]['message']['function_call'];
      final functionArgs = jsonDecode(functionCall['arguments']);

      // 解析结构化结果
      return _parseAnalysisResult(functionArgs);
    } catch (e) {
      throw Exception('分析失败: $e');
    }
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

    final response = await _chatWithAI(prompt);
    return response;
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

    final response = await _chatWithAI(prompt, useFunctionCalling: false);

    // 简化处理：从响应中提取预测信息
    final predictedTime = _extractPredictedTime(response);
    final confidence = _extractConfidence(response);

    return PredictionResult(
      predictedTime: predictedTime,
      confidence: confidence,
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

    try {
      final messages = [
        {'role': 'system', 'content': TrainingAnalysisPrompt.systemPrompt},
        ...?history?.map((m) => {
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
        Uri.parse('$_config.endpoint/chat/completions'),
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
              final json = jsonDecode(data);
              final content = json['choices'][0]['delta']['content'];
              if (content != null) {
                yield content;
              }
            } catch (e) {
              // 忽略解析错误
            }
          }
        }
      }
    } catch (e) {
      yield '错误: $e';
    }
  }

  Future<String> _chatWithAI(
    String prompt, {
    bool useFunctionCalling = false,
  }) async {
    final response = await _client.post(
      Uri.parse('$_config.endpoint/chat/completions'),
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
    );

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    return data['choices'][0]['message']['content'];
  }

  AIAnalysisResult _parseAnalysisResult(Map<String, dynamic> args) {
    return AIAnalysisResult(
      overallRating: (args['overall_rating'] as num).toDouble(),
      strengths: List<String>.from(args['strengths']),
      weaknesses: List<String>.from(args['weaknesses']),
      recommendations: (args['recommendations'] as List)
          .map((r) => TrainingRecommendation.fromJson(r))
          .toList(),
      moduleEfficiencies: Map.fromEntries(
        (args['module_efficiencies'] as Map).entries.map((e) =>
            MapEntry(e.key, ModuleEfficiencyAnalysis.fromJson(e.value))),
      ),
      timeTrend: TimeTrendAnalysis.fromJson(args['time_trend']),
      predictedBestTime:
          Duration(seconds: args['predicted_best_time'] as int),
      analyzedAt: DateTime.now(),
      confidence: (args['confidence'] as num).toDouble(),
    );
  }

  Duration _extractPredictedTime(String response) {
    // 简化实现：从响应中提取时间
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
    // 简化实现
    final regex = RegExp(r'信心度[：:]\s*(\d+)');
    final match = regex.firstMatch(response);
    if (match != null) {
      return int.parse(match.group(1)!) / 100;
    }
    return 0.85;
  }

  List<String> _extractFactors(String response) {
    // 简化实现
    return ['时间趋势稳定', '效率持续提升', '任务完成率高'];
  }
}
```

#### 步骤 5: 创建Prompt模板

**文件：`lib/core/ai/prompts/training_analysis_prompt.dart`**

```dart
import '../../models/practice_record_model.dart';
import 'ai_service_interface.dart';

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
      final moduleAvg = moduleRecords.fold<Duration>(
        Duration.zero,
        (sum, r) => sum + r.totalDuration,
      );
      final moduleAvgDuration =
          Duration(seconds: moduleAvg.inSeconds ~/ moduleRecords.length);
      final moduleAvgEfficiency = moduleRecords.fold<double>(
        0,
        (sum, r) => sum + r.efficiency,
      ) / moduleRecords.length;

      buffer.writeln(
        '\n模块: ${moduleRecords.first.moduleName} (${entry.key})',
      );
      buffer.writeln('  - 练习次数: ${moduleRecords.length}');
      buffer.writeln('  - 平均时长: ${_formatDuration(moduleAvgDuration)}');
      buffer.writeln('  - 平均效率: ${(moduleAvgEfficiency * 100).toInt()}%');

      // 时间趋势
      moduleRecords.sort((a, b) => a.completedAt.compareTo(b.completedAt));
      if (moduleRecords.length > 1) {
        final firstDuration = moduleRecords.first.totalDuration.inSeconds;
        final lastDuration = moduleRecords.last.totalDuration.inSeconds;
        final improvement = ((firstDuration - lastDuration) / firstDuration * 100);
        buffer.writeln('  - 时间改进: ${improvement.toStringAsFixed(1)}%');
      }

      // 任务分析
      for (final record in moduleRecords) {
        if (record.taskRecords.isNotEmpty) {
          buffer.writeln('  - 任务完成率: ${record.completedTasks}/${record.totalTasks}');
        }
      }
    }

    // 根据分析类型添加特定要求
    buffer.writeln('\n分析要求：');
    switch (type) {
      case AnalysisType.comprehensive:
        buffer.writeln('- 提供全面的分析，包括所有维度');
        break;
      case AnalysisType.efficiency:
        buffer.writeln('- 重点关注效率分析');
        break;
      case AnalysisType.timeTrend:
        buffer.writeln('- 重点关注时间趋势和改进速度');
        break;
      case AnalysisType.prediction:
        buffer.writeln('- 重点关注未来表现预测');
        break;
      case AnalysisType.weaknessAnalysis:
        buffer.writeln('- 重点关注待改进点和解决方案');
        break;
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
      return '${hours}小时${minutes}分钟';
    } else if (minutes > 0) {
      return '${minutes}分钟${seconds}秒';
    } else {
      return '${seconds}秒';
    }
  }
}
```

#### 步骤 6: 创建AI配置管理

**文件：`lib/core/ai/ai_config.dart`**

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 火山云配置
class VolcengineConfig {
  final String apiKey;
  final String endpoint;
  final String model;
  final int timeout;

  const VolcengineConfig({
    required this.apiKey,
    this.endpoint = 'https://ark.cn-beijing.volces.com/api/v3',
    this.model = 'ep-2024xxxx',
    this.timeout = 30,
  });

  factory VolcengineConfig.fromEnv() {
    return VolcengineConfig(
      apiKey: dotenv.env['VOLCENGINE_API_KEY'] ?? '',
      endpoint: dotenv.env['VOLCENGINE_ENDPOINT'] ??
          'https://ark.cn-beijing.volces.com/api/v3',
      model: dotenv.env['VOLCENGINE_MODEL'] ?? 'ep-2024xxxx',
      timeout: int.tryParse(dotenv.env['VOLCENGINE_TIMEOUT'] ?? '30') ?? 30,
    );
  }
}

/// Dify配置（预留）
class DifyConfig {
  final String apiKey;
  final String baseUrl;
  final String appId;

  const DifyConfig({
    required this.apiKey,
    this.baseUrl = 'https://api.dify.ai/v1',
    required this.appId,
  });

  factory DifyConfig.fromEnv() {
    return DifyConfig(
      apiKey: dotenv.env['DIFY_API_KEY'] ?? '',
      baseUrl: dotenv.env['DIFY_BASE_URL'] ?? 'https://api.dify.ai/v1',
      appId: dotenv.env['DIFY_APP_ID'] ?? '',
    );
  }
}

/// AI配置
class AIConfig {
  final VolcengineConfig volcengineConfig;
  final DifyConfig difyConfig;
  final AIEngine defaultEngine;

  const AIConfig({
    VolcengineConfig? volcengineConfig,
    DifyConfig? difyConfig,
    this.defaultEngine = AIEngine.volcengine,
  })  : volcengineConfig = volcengineConfig ?? const VolcengineConfig(),
        difyConfig = difyConfig ?? const DifyConfig();

  factory AIConfig.fromEnv() {
    final engineStr = dotenv.env['AI_ENGINE'] ?? 'volcengine';
    final engine = AIEngine.values.firstWhere(
      (e) => e.name == engineStr,
      orElse: () => AIEngine.volcengine,
    );

    return AIConfig(
      volcengineConfig: VolcengineConfig.fromEnv(),
      difyConfig: DifyConfig.fromEnv(),
      defaultEngine: engine,
    );
  }
}

/// AI引擎类型
enum AIEngine {
  volcengine,
  dify,
}
```

### Phase 3: UI实现（第3周）

#### 步骤 7: 创建AI分析面板

**文件：`lib/features/practice_history/widgets/ai_analysis_panel.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/ws_colors.dart';
import '../../../core/i18n/locale_provider.dart';
import '../../../core/models/ai_analysis_result.dart';
import '../../../core/ai/ai_providers.dart';
import '../../core/providers/practice_history_provider.dart';
import 'ai_overview_card.dart';
import 'ai_insights_grid.dart';
import 'ai_chart_view.dart';
import 'ai_chat_panel.dart';

/// AI分析面板
class AIAnalysisPanel extends ConsumerStatefulWidget {
  const AIAnalysisPanel({super.key});

  @override
  ConsumerState<AIAnalysisPanel> createState() => _AIAnalysisPanelState();
}

class _AIAnalysisPanelState extends ConsumerState<AIAnalysisPanel> {
  @override
  Widget build(BuildContext context) {
    final s = LocaleScope.of(context);
    final recordsAsync = ref.watch(practiceRecordsProvider);
    final analysisAsync = ref.watch(aiAnalysisProvider);

    return recordsAsync.when(
      data: (records) {
        if (records.isEmpty) {
          return _buildEmptyState(s);
        }

        return Column(
          children: [
            // 标题栏
            _buildHeader(s),
            const SizedBox(height: 16),

            // 分析内容
            Expanded(
              child: analysisAsync.when(
                data: (analysis) => _buildAnalysisContent(analysis),
                loading: () => _buildLoadingState(),
                error: (err, stack) => _buildErrorState(err),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildHeader(dynamic s) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WsColors.surface,
        border: Border(
          bottom: BorderSide(color: WsColors.border),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: WsColors.accentCyan.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: WsColors.accentCyan,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.aiAnalysis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: WsColors.textPrimary,
                  ),
                ),
                Text(
                  s.aiAnalysisDesc,
                  style: const TextStyle(
                    fontSize: 12,
                    color: WsColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // AI引擎选择器（预留）
          _buildEngineSelector(s),
        ],
      ),
    );
  }

  Widget _buildEngineSelector(dynamic s) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: WsColors.bgDeep.withAlpha(120),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: WsColors.border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.memory,
            size: 16,
            color: WsColors.accentCyan,
          ),
          const SizedBox(width: 6),
          Text(
            '火山云AI',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: WsColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisContent(AIAnalysisResult analysis) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 概览卡片
          AIOverviewCard(analysis: analysis),
          const SizedBox(height: 24),

          // 洞察网格
          AIInsightsGrid(analysis: analysis),
          const SizedBox(height: 24),

          // 图表视图
          AIChartView(analysis: analysis),
          const SizedBox(height: 24),

          // 聊天面板
          AIChatPanel(analysis: analysis),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('AI正在分析你的训练数据...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: WsColors.errorRed,
          ),
          const SizedBox(height: 16),
          Text(
            '分析失败',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: WsColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: TextStyle(
              fontSize: 14,
              color: WsColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.invalidate(aiAnalysisProvider),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(dynamic s) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.psychology_outlined,
            size: 64,
            color: WsColors.textSecondary.withAlpha(80),
          ),
          const SizedBox(height: 16),
          Text(
            s.noRecords,
            style: TextStyle(
              fontSize: 16,
              color: WsColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
```

#### 步骤 8: 创建AI Providers

**文件：`lib/core/ai/ai_providers.dart`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/practice_history/models/practice_record_model.dart';
import 'ai_service_interface.dart';
import 'volcengine_ai_service.dart';
import 'dify_ai_service.dart';
import 'ai_config.dart';

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

/// AI分析结果Provider
final aiAnalysisProvider = FutureProvider<AIAnalysisResult>((ref) async {
  final service = ref.watch(aiServiceProvider);
  final recordsAsync = ref.watch(practiceRecordsProvider);

  final records = await recordsAsync;

  if (records.isEmpty) {
    throw Exception('没有训练记录可分析');
  }

  return service.analyzeTrainingData(records: records);
});

/// AI聊天历史Provider
final aiChatHistoryProvider =
    StateProvider<List<ChatMessage>>((ref) => []);

/// AI推荐Provider
final aiRecommendationsProvider =
    FutureProvider.family<String, String>((ref, customPrompt) async {
  final service = ref.watch(aiServiceProvider);
  final analysisAsync = ref.watch(aiAnalysisProvider);

  final analysis = await analysisAsync;

  return service.generateRecommendations(
    analysis: analysis,
    customPrompt: customPrompt.isEmpty ? null : customPrompt,
  );
});

/// AI预测Provider
final aiPredictionProvider = FutureProvider.family<
    PredictionResult, Duration>((ref, targetDuration) async {
  final service = ref.watch(aiServiceProvider);
  final recordsAsync = ref.watch(practiceRecordsProvider);

  final records = await recordsAsync;

  return service.predictPerformance(
    records: records,
    targetDuration: targetDuration,
  );
});
```

## 📝 国际化字符串

### 文件：`lib/core/i18n/strings.dart`

添加以下字符串到 `AppStrings` 抽象类：

```dart
// AI Analysis
String get aiAnalysis;
String get aiAnalysisDesc;
String get aiInsights;
String get aiRecommendations;
String get aiPrediction;
String get overallRating;
String get confidence;
String get strengths;
String get weaknesses;
String get talkToAI;
String get askAI;
String get generatingAnalysis;
String get analysisComplete;
String get noAnalysisData;
```

### 文件：`lib/core/i18n/zh.dart`

```dart
@override
String get aiAnalysis => 'AI智能分析';
@override
String get aiAnalysisDesc => '基于训练数据的个性化分析和建议';
@override
String get aiInsights => 'AI洞察';
@override
String get aiRecommendations => '智能建议';
@override
String get aiPrediction => '性能预测';
@override
String get overallRating => '综合评分';
@override
String get confidence => '信心度';
@override
String get strengths => '优势';
@override
String get weaknesses => '待改进';
@override
String get talkToAI => '与AI对话';
@override
String get askAI => '向AI提问';
@override
String get generatingAnalysis => 'AI正在分析...';
@override
String get analysisComplete => '分析完成';
@override
String get noAnalysisData => '暂无分析数据';
```

### 文件：`lib/core/i18n/en.dart`

```dart
@override
String get aiAnalysis => 'AI Analysis';
@override
String get aiAnalysisDesc => 'Personalized analysis and recommendations based on training data';
@override
String get aiInsights => 'AI Insights';
@override
String get aiRecommendations => 'Smart Recommendations';
@override
String get aiPrediction => 'Performance Prediction';
@override
String get overallRating => 'Overall Rating';
@override
String get confidence => 'Confidence';
@override
String get strengths => 'Strengths';
@override
String get weaknesses => 'Weaknesses';
@override
String get talkToAI => 'Chat with AI';
@override
String get askAI => 'Ask AI';
@override
String get generatingAnalysis => 'AI is analyzing...';
@override
String get analysisComplete => 'Analysis Complete';
@override
String get noAnalysisData => 'No analysis data';
```

## 🔒 安全与隐私

### 1. API密钥管理

- ✅ 使用环境变量存储API密钥
- ✅ .env文件加入.gitignore
- ✅ 生产环境使用安全的密钥管理服务
- ✅ 不在前端代码中硬编码密钥

### 2. 数据隐私

- ✅ 训练数据只在本地处理
- ✅ 发送到AI的数据仅包含匿名化的统计数据
- ✅ 不发送个人身份信息
- ✅ 提供数据删除选项

### 3. 使用限制

- ✅ 实现请求频率限制
- ✅ 错误重试机制（指数退避）
- ✅ 超时处理
- ✅ 离线模式支持

## 🧪 测试策略

### 1. 单元测试

```dart
// test/core/ai/volcengine_ai_service_test.dart
test('should parse AI response correctly', () {
  // 测试响应解析
});

test('should handle API errors gracefully', () {
  // 测试错误处理
});

test('should format records correctly', () {
  // 测试数据格式化
});
```

### 2. 集成测试

```dart
// test/features/ai_integration_test.dart
testWidgets('AI analysis panel displays results', (tester) async {
  // 测试UI显示
});

testWidgets('Chat panel responds to user input', (tester) async {
  // 测试聊天功能
});
```

### 3. Mock数据

创建mock数据用于测试：

```dart
// test/mocks/mock_ai_data.dart
const mockAnalysisResult = AIAnalysisResult(
  overallRating: 85.0,
  strengths: ['时间管理能力强', '完成率高'],
  weaknesses: ['任务切换效率待提升'],
  // ...
);
```

## 📅 实施时间表

| 阶段 | 任务 | 预计时间 | 依赖 |
|------|------|----------|------|
| Phase 1 | 基础设施搭建 | 1周 | - |
| Phase 2 | 火山云API实现 | 1周 | Phase 1 |
| Phase 3 | UI实现 | 1周 | Phase 2 |
| Phase 4 | 测试与优化 | 3天 | Phase 3 |
| Phase 5 | Dify扩展点实现（可选） | 1周 | Phase 1 |

## 🎯 成功标准

- ✅ 能够分析至少10条历史训练记录
- ✅ AI分析响应时间 < 5秒
- ✅ 建议准确率 > 80%（用户反馈）
- ✅ 支持中英文双语
- ✅ UI响应流畅，无明显卡顿
- ✅ 错误处理完善，用户友好

## 🔄 Dify扩展点实现（预留）

当需要集成Dify时，只需：

1. 实现 `DifyAIService` 类
2. 在 `ai_providers.dart` 中添加支持
3. 通过环境变量切换引擎

```dart
// 示例：切换到Dify
// .env
AI_ENGINE=dify
```

## 📚 相关文档

- [火山云API文档](https://www.volcengine.com/docs/82379)
- [Dify文档](https://docs.dify.ai)
- [Riverpod最佳实践](https://riverpod.dev/docs/concepts/providers)

## 🎨 设计资源

- 使用WorldSkills主题配色：`WsColors.accentCyan`, `WsColors.accentGreen`, `WsColors.secondaryMint`
- 图标：Material Icons - `auto_awesome`, `psychology`, `trending_up`, `lightbulb`
- 字体：Inter（UI文本）, JetBrainsMono（数字显示）

---

**注意：**
1. 实施前请先在火山云控制台申请API密钥
2. 建议先用测试数据验证API集成
3. 预留Dify扩展点，便于未来升级
4. 所有AI相关配置应通过环境变量管理
