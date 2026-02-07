import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/ws_colors.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/providers/time_providers.dart';
import '../../widgets/glass_panel.dart';
import 'timezone_converter.dart';
import 'timezone_model.dart';

class TimezonePage extends ConsumerWidget {
  const TimezonePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = LocaleScope.of(context);
    final utcNow = ref.watch(unifiedTimeProvider);

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
                color: WsColors.accentCyan,
              ),
            ),
            const SizedBox(height: 32),
            ...TimeZoneCity.cities.map((city) {
              final localTime =
                  TimezoneConverter.convert(utcNow, city.timezoneId);
              final isShanghai = city.timezoneId == 'Asia/Shanghai';
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
                              ? WsColors.accentCyan
                              : WsColors.secondaryMint,
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
                        '${localTime.hour.toString().padLeft(2, '0')}:'
                        '${localTime.minute.toString().padLeft(2, '0')}:'
                        '${localTime.second.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontFamily: 'JetBrainsMono',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isShanghai
                              ? WsColors.accentCyan
                              : WsColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${localTime.year}-'
                        '${localTime.month.toString().padLeft(2, '0')}-'
                        '${localTime.day.toString().padLeft(2, '0')}',
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
