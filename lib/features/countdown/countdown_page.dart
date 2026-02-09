import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/ws_colors.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/providers/time_providers.dart';
import '../../widgets/ws_timer_text.dart';
import '../milestones/milestone_list.dart';

class CountdownPage extends ConsumerWidget {
  const CountdownPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = LocaleScope.of(context);
    final now = ref.watch(unifiedTimeProvider);
    final target = ref.watch(competitionCountdownProvider);
    final remaining = target.difference(now);
    final safe = remaining.isNegative ? Duration.zero : remaining;

    final days = safe.inDays;
    final hours = safe.inHours % 24;
    final minutes = safe.inMinutes % 60;
    final seconds = safe.inSeconds % 60;
    final is2026 = DateTime.now().toUtc().year == 2026;
    final logoAsset = is2026
        ? 'assets/images/Logo_WS_Shanghai2026_White_RGB.png'
        : 'assets/images/WS_Logo_DarkBlue_RGB.png';
    final logoColor = is2026 ? WsColors.darkBlue : null;

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 40,
              vertical: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  logoAsset,
                  height: 200,
                  fit: BoxFit.contain,
                  color: logoColor,
                  colorBlendMode: logoColor == null ? null : BlendMode.srcIn,
                ),
                const SizedBox(height: 24),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '$days ${s.days.toUpperCase()}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 72,
                      fontWeight: FontWeight.w900,
                      color: WsColors.darkBlue,
                      height: 1.0,
                    ),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    s.remaining.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 72,
                      fontWeight: FontWeight.w900,
                      color: WsColors.accentCyan,
                      height: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      WsTimerText(
                        value: hours.toString().padLeft(2, '0'),
                        label: s.hours.toUpperCase(),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(
                          bottom: 20,
                          left: 12,
                          right: 12,
                        ),
                        child: Text(
                          ':',
                          style: TextStyle(
                            fontFamily: 'JetBrainsMono',
                            fontSize: 44,
                            fontWeight: FontWeight.bold,
                            color: WsColors.secondaryMint,
                          ),
                        ),
                      ),
                      WsTimerText(
                        value: minutes.toString().padLeft(2, '0'),
                        label: s.minutes.toUpperCase(),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(
                          bottom: 20,
                          left: 12,
                          right: 12,
                        ),
                        child: Text(
                          ':',
                          style: TextStyle(
                            fontFamily: 'JetBrainsMono',
                            fontSize: 44,
                            fontWeight: FontWeight.bold,
                            color: WsColors.secondaryMint,
                          ),
                        ),
                      ),
                      WsTimerText(
                        value: seconds.toString().padLeft(2, '0'),
                        label: s.seconds.toUpperCase(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          width: 320,
          margin: const EdgeInsets.only(
            right: 20,
            top: 16,
            bottom: 16,
          ),
          decoration: BoxDecoration(
            color: WsColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: WsColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(8),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Padding(
            padding: EdgeInsets.all(20),
            child: MilestoneList(),
          ),
        ),
      ],
    );
  }
}
