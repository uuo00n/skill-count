class TimeZoneCity {
  final String name;
  final int utcOffset;
  final String timezoneId;

  const TimeZoneCity({
    required this.name,
    required this.utcOffset,
    required this.timezoneId,
  });

  static const cities = [
    TimeZoneCity(
      name: '上海',
      utcOffset: 8,
      timezoneId: 'Asia/Shanghai',
    ),
    TimeZoneCity(
      name: 'Lyon',
      utcOffset: 1,
      timezoneId: 'Europe/Paris',
    ),
    TimeZoneCity(
      name: 'Tokyo',
      utcOffset: 9,
      timezoneId: 'Asia/Tokyo',
    ),
    TimeZoneCity(
      name: 'New York',
      utcOffset: -5,
      timezoneId: 'America/New_York',
    ),
    TimeZoneCity(
      name: 'London',
      utcOffset: 0,
      timezoneId: 'Europe/London',
    ),
  ];
}
