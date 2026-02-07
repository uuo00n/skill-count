class TimezoneConverter {
  TimezoneConverter._();

  /// 将 UTC 时间转换为指定偏移的本地时间
  static DateTime convert(DateTime base, int offset) {
    final utc = base.toUtc();
    return utc.add(Duration(hours: offset));
  }
}
