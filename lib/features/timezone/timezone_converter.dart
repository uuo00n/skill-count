import 'package:timezone/timezone.dart' as tz;

class TimezoneConverter {
  TimezoneConverter._();

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

  /// 获取实际 UTC 偏移（考虑夏令时），返回小时数（可能含小数）
  static Duration getUtcOffset(String timezoneId, DateTime utcNow) {
    final location = tz.getLocation(timezoneId);
    final localTime = tz.TZDateTime.from(utcNow.toUtc(), location);
    return localTime.timeZoneOffset;
  }

  /// 获取偏移显示字符串（如 "UTC+8" 或 "UTC+5:30"）
  static String getOffsetDisplay(String timezoneId, DateTime utcNow) {
    final offset = getUtcOffset(timezoneId, utcNow);
    final hours = offset.inHours;
    final minutes = offset.inMinutes.abs() % 60;
    final sign = hours >= 0 && offset.inMinutes >= 0 ? '+' : '';
    if (minutes == 0) {
      return 'UTC$sign$hours';
    }
    return 'UTC$sign$hours:${minutes.toString().padLeft(2, '0')}';
  }
}
