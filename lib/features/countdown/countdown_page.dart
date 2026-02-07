import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/ws_colors.dart';
import '../../core/constants/ws_times.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/utils/time_utils.dart';
import '../../widgets/ws_timer_text.dart';
import '../milestones/milestone_list.dart';

class CountdownPage extends StatefulWidget {
  const CountdownPage({super.key});

  @override
  State<CountdownPage> createState() => _CountdownPageState();
}

class _CountdownPageState extends State<CountdownPage> {
  late Timer _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemaining();
    });
  }

  void _updateRemaining() {
    setState(() {
      _remaining = TimeUtils.timeLeft(WsTimes.competitionOpenTime);
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
    final days = _remaining.inDays;
    final hours = _remaining.inHours % 24;
    final minutes = _remaining.inMinutes % 60;
    final seconds = _remaining.inSeconds % 60;

    return Row(
      children: [
        // Left: main countdown
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                        padding: EdgeInsets.only(bottom: 20, left: 12, right: 12),
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
                        padding: EdgeInsets.only(bottom: 20, left: 12, right: 12),
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
        // Right: milestone panel
        Container(
          width: 320,
          margin: const EdgeInsets.only(right: 20, top: 16, bottom: 16),
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
