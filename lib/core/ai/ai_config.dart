import 'package:flutter_dotenv/flutter_dotenv.dart';

/// AI引擎类型
enum AIEngine {
  volcengine,
  dify,
}

/// 火山云配置
class VolcengineConfig {
  final String apiKey;
  final String endpoint;
  final String model;
  final int timeout;

  const VolcengineConfig({
    this.apiKey = '',
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
      timeout:
          int.tryParse(dotenv.env['VOLCENGINE_TIMEOUT'] ?? '30') ?? 30,
    );
  }
}

/// Dify配置（预留）
class DifyConfig {
  final String apiKey;
  final String baseUrl;
  final String appId;

  const DifyConfig({
    this.apiKey = '',
    this.baseUrl = 'https://api.dify.ai/v1',
    this.appId = '',
  });

  factory DifyConfig.fromEnv() {
    return DifyConfig(
      apiKey: dotenv.env['DIFY_API_KEY'] ?? '',
      baseUrl:
          dotenv.env['DIFY_BASE_URL'] ?? 'https://api.dify.ai/v1',
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
    this.volcengineConfig = const VolcengineConfig(),
    this.difyConfig = const DifyConfig(),
    this.defaultEngine = AIEngine.volcengine,
  });

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
