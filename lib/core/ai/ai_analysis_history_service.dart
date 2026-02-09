import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'ai_models.dart';

class AIAnalysisHistoryService {
  static const String _storageKey = 'ai_analysis_history';
  SharedPreferences? _prefs;

  AIAnalysisHistoryService();

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> initialize() async {
    await _getPrefs();
  }

  /// 保存分析结果
  Future<void> addResult(AIAnalysisResult result) async {
    final results = await getResults();
    results.insert(0, result);
    await _saveResults(results);
  }

  /// 获取所有历史（按时间倒序）
  Future<List<AIAnalysisResult>> getResults() async {
    final prefs = await _getPrefs();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final results = jsonList
          .map((json) =>
              AIAnalysisResult.fromJson(json as Map<String, dynamic>))
          .toList();
      results.sort((a, b) => b.analyzedAt.compareTo(a.analyzedAt));
      return results;
    } catch (e) {
      return [];
    }
  }

  /// 删除指定记录
  Future<void> deleteResult(String id) async {
    final results = await getResults();
    results.removeWhere((r) => r.id == id);
    await _saveResults(results);
  }

  /// 清空所有历史
  Future<void> clearAll() async {
    final prefs = await _getPrefs();
    await prefs.remove(_storageKey);
  }

  Future<void> _saveResults(List<AIAnalysisResult> results) async {
    final prefs = await _getPrefs();
    final jsonList = results.map((r) => r.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await prefs.setString(_storageKey, jsonString);
  }
}
