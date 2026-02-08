import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/practice_history/practice_history_service.dart';
import '../../features/practice_history/models/practice_record_model.dart';

/// 练习历史服务 Provider（单例）
final practiceHistoryServiceProvider = FutureProvider<PracticeHistoryService>((ref) async {
  final service = PracticeHistoryService();
  await service.initialize();
  return service;
});

/// 所有练习记录 Provider
final practiceRecordsProvider = FutureProvider<List<PracticeRecord>>((ref) async {
  final service = await ref.watch(practiceHistoryServiceProvider.future);
  return service.getRecords();
});

/// 按模块 ID 获取记录的 Provider
final moduleRecordsProvider = FutureProvider.family<List<PracticeRecord>, String>((ref, moduleId) async {
  final service = await ref.watch(practiceHistoryServiceProvider.future);
  return service.getRecordsByModuleId(moduleId);
});

/// 整体统计数据 Provider
final practiceStatisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = await ref.watch(practiceHistoryServiceProvider.future);
  return service.getStatistics();
});

/// 按模块的统计数据 Provider
final moduleStatisticsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, moduleId) async {
  final service = await ref.watch(practiceHistoryServiceProvider.future);
  return service.getModuleStatistics(moduleId);
});

/// 新记录触发刷新的状态 Provider
final recordsRefreshTriggerProvider = StateProvider<int>((ref) => 0);

/// 当新增记录后调用此函数触发刷新
final addNewRecordProvider = FutureProvider.family<void, PracticeRecord>((ref, record) async {
  final service = await ref.watch(practiceHistoryServiceProvider.future);
  await service.addRecord(record);
  // 触发刷新
  ref.read(recordsRefreshTriggerProvider.notifier).state++;
});
