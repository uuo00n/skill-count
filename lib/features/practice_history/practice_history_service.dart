import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/practice_record_model.dart';

class PracticeHistoryService {
  static const String _storageKey = 'practice_records';
  SharedPreferences? _prefs;

  PracticeHistoryService();

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// 添加新的练习记录
  Future<void> addRecord(PracticeRecord record) async {
    final records = await getRecords();
    records.add(record);
    await _saveRecords(records);
  }

  /// 获取所有练习记录
  Future<List<PracticeRecord>> getRecords() async {
    final prefs = await _getPrefs();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => PracticeRecord.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading records: $e');
      return [];
    }
  }

  /// 按模块 ID 获取记录
  Future<List<PracticeRecord>> getRecordsByModuleId(String moduleId) async {
    final records = await getRecords();
    return records.where((r) => r.moduleId == moduleId).toList();
  }

  /// 删除记录
  Future<void> deleteRecord(String recordId) async {
    final records = await getRecords();
    records.removeWhere((r) => r.id == recordId);
    await _saveRecords(records);
  }

  /// 清空所有记录
  Future<void> clearAllRecords() async {
    final prefs = await _getPrefs();
    await prefs.remove(_storageKey);
  }

  /// 获取统计数据
  Future<Map<String, dynamic>> getStatistics() async {
    final records = await getRecords();

    if (records.isEmpty) {
      return {
        'totalSessions': 0,
        'totalTime': Duration.zero,
        'averageEfficiency': 0.0,
        'completionRate': 0.0,
      };
    }

    final totalTime = records.fold<Duration>(
      Duration.zero,
      (sum, r) => sum + r.totalDuration,
    );

    final averageEfficiency = records.fold<double>(0, (sum, r) => sum + r.efficiency) /
        records.length;

    final completedTasks = records.fold<int>(0, (sum, r) => sum + r.completedTasks);
    final totalTasks = records.fold<int>(0, (sum, r) => sum + r.totalTasks);
    final completionRate = totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0.0;

    return {
      'totalSessions': records.length,
      'totalTime': totalTime,
      'averageEfficiency': averageEfficiency,
      'completionRate': completionRate,
    };
  }

  /// 按模块获取统计
  Future<Map<String, dynamic>> getModuleStatistics(String moduleId) async {
    final records = await getRecordsByModuleId(moduleId);

    if (records.isEmpty) {
      return {
        'sessions': 0,
        'totalTime': Duration.zero,
        'averageDuration': Duration.zero,
        'bestTime': Duration.zero,
        'trend': [],
      };
    }

    final totalTime = records.fold<Duration>(Duration.zero, (sum, r) => sum + r.totalDuration);
    final avgDuration = Duration(seconds: (totalTime.inSeconds / records.length).toInt());
    final bestTime = records.reduce((a, b) =>
        a.totalDuration.inSeconds < b.totalDuration.inSeconds ? a : b).totalDuration;

    return {
      'sessions': records.length,
      'totalTime': totalTime,
      'averageDuration': avgDuration,
      'bestTime': bestTime,
      'trend': records.map((r) => {
            'date': r.completedAt,
            'duration': r.totalDuration.inSeconds,
            'efficiency': r.efficiency,
          }).toList(),
    };
  }

  Future<void> _saveRecords(List<PracticeRecord> records) async {
    final prefs = await _getPrefs();
    final jsonList = records.map((r) => r.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await prefs.setString(_storageKey, jsonString);
  }
}
