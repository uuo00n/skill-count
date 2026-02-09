import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'milestone_model.dart';

class MilestoneService {
  static const String _storageKey = 'milestones';
  SharedPreferences? _prefs;

  MilestoneService();

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  Future<List<Milestone>> getMilestones() async {
    final prefs = await _getPrefs();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null) {
      // 首次使用，返回默认里程碑并保存
      final defaults = Milestone.getDefaultMilestones();
      await saveMilestones(defaults);
      return defaults;
    }

    try {
      return Milestone.listFromJson(jsonString);
    } catch (e) {
      debugPrint('Error loading milestones: $e');
      return Milestone.getDefaultMilestones();
    }
  }

  Future<void> saveMilestones(List<Milestone> milestones) async {
    final prefs = await _getPrefs();
    await prefs.setString(_storageKey, Milestone.listToJson(milestones));
  }

  Future<void> clearAll() async {
    final prefs = await _getPrefs();
    await prefs.remove(_storageKey);
  }
}
