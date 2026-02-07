/// WorldSkills 关键时间点
///
/// 所有时间以 UTC 存储，显示时转换为本地时区。
/// competitionOpenTime: 2026-09-22 19:00 UTC+8 = 2026-09-22 11:00 UTC
class WsTimes {
  WsTimes._();

  /// 比赛开幕式时间 (UTC)
  static final DateTime competitionOpenTime =
      DateTime.utc(2026, 9, 22, 11, 0, 0);
}
