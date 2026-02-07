import 'package:timezone/timezone.dart' as tz;

class TimezoneConverter {
  TimezoneConverter._();

  /// 兼容旧方法：基于 UTC 固定偏移（不处理夏令时）
  static DateTime convertLegacy(DateTime base, int offset) {
    final utc = base.toUtc();
    return utc.add(Duration(hours: offset));
  }

  /// 使用 IANA 时区 ID 转换（自动处理夏令时）
  static DateTime convert(DateTime base, String timezoneId) {
    final location = tz.getLocation(timezoneId);
    return tz.TZDateTime.from(base.toUtc(), location);
  }

  /// 获取指定时区的当前时间
  static DateTime getCurrentTime(String timezoneId) {
    final location = tz.getLocation(timezoneId);
    return tz.TZDateTime.now(location);
  }
}
