import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/ws_colors.dart';
import '../../core/i18n/locale_provider.dart';
import '../../widgets/glass_panel.dart';
import 'timezone_model.dart';
import 'timezone_converter.dart';

class TimezonePage extends StatefulWidget {
  const TimezonePage({super.key});

  @override
  State<TimezonePage> createState() => _TimezonePageState();
}

class _TimezonePageState extends State<TimezonePage> {
  late Timer _timer;
  DateTime _now = DateTime.now().toUtc();

  static const _cities = [
    TimeZoneCity(name: '上海', utcOffset: 8),
    TimeZoneCity(name: 'Lyon', utcOffset: 1),
    TimeZoneCity(name: 'Tokyo', utcOffset: 9),
    TimeZoneCity(name: 'New York', utcOffset: -5),
    TimeZoneCity(name: 'London', utcOffset: 0),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now().toUtc());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = LocaleScope.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              s.worldTimezones.toUpperCase(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: WsColors.textSecondary,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              s.internationalCollaboration,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: WsColors.accentYellow,
              ),
            ),
            const SizedBox(height: 32),
            ..._cities.map((city) {
              final localTime = TimezoneConverter.convert(_now, city.utcOffset);
              final isShanghai = city.utcOffset == 8;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GlassPanel(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  borderRadius: 10,
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isShanghai
                              ? WsColors.accentYellow
                              : WsColors.accentBlue,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              city.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isShanghai
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: WsColors.textPrimary,
                              ),
                            ),
                            Text(
                              'UTC${city.utcOffset >= 0 ? '+' : ''}${city.utcOffset}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: WsColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}:${localTime.second.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontFamily: 'JetBrainsMono',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isShanghai
                              ? WsColors.accentYellow
                              : WsColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${localTime.year}-${localTime.month.toString().padLeft(2, '0')}-${localTime.day.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: WsColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
