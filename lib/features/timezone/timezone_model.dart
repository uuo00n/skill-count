class TimeZoneCity {
  final String name;
  final String timezoneId;

  const TimeZoneCity({
    required this.name,
    required this.timezoneId,
  });

  /// 按语言顺序排列: zh, zhTw, zhHk/zhMo, en, ja, de, fr, ko
  static const cities = [
    TimeZoneCity(
      name: '北京',
      timezoneId: 'Asia/Shanghai',
    ),
    TimeZoneCity(
      name: '台北',
      timezoneId: 'Asia/Taipei',
    ),
    TimeZoneCity(
      name: '香港',
      timezoneId: 'Asia/Hong_Kong',
    ),
    TimeZoneCity(
      name: 'New York',
      timezoneId: 'America/New_York',
    ),
    TimeZoneCity(
      name: 'Tokyo',
      timezoneId: 'Asia/Tokyo',
    ),
    TimeZoneCity(
      name: 'Berlin',
      timezoneId: 'Europe/Berlin',
    ),
    TimeZoneCity(
      name: 'Paris',
      timezoneId: 'Europe/Paris',
    ),
    TimeZoneCity(
      name: 'Seoul',
      timezoneId: 'Asia/Seoul',
    ),
  ];
}
