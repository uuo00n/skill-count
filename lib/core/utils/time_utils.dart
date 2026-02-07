class TimeUtils {
  TimeUtils._();

  /// 计算从现在到目标时间的剩余时间
  /// 基于 UTC 计算，避免时区问题
  static Duration timeLeft(DateTime target) {
    final now = DateTime.now().toUtc();
    final diff = target.difference(now);
    return diff.isNegative ? Duration.zero : diff;
  }
}
