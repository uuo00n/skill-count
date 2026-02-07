import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// 统一时间服务 — 全局唯一时间源
///
/// 每秒更新一次 UTC 时间，所有页面通过 ref.watch 消费，
/// 避免多个 Timer.periodic 导致的漂移与冗余重建。
class UnifiedTimeService extends StateNotifier<DateTime> {
  Timer? _updateTimer;

  UnifiedTimeService() : super(DateTime.now().toUtc()) {
    _startTimer();
  }

  void _startTimer() {
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = DateTime.now().toUtc();
    });
  }

  /// 将当前 UTC 时间转换为指定 IANA 时区
  DateTime toTimezone(String timezoneId) {
    final location = tz.getLocation(timezoneId);
    return tz.TZDateTime.from(state, location);
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
}

/// 全局统一时间 Provider（每秒更新 UTC）
final unifiedTimeProvider =
    StateNotifierProvider<UnifiedTimeService, DateTime>(
  (ref) => UnifiedTimeService(),
);
