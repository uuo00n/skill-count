import 'package:flutter/material.dart';
import '../../core/constants/ws_colors.dart';
import '../../core/i18n/locale_provider.dart';

class CompetitionTimeline extends StatelessWidget {
  const CompetitionTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    final s = LocaleScope.of(context);

    // Competition phases with date ranges
    final phases = [
      _Phase(s.arrival, DateTime.utc(2026, 9, 18), DateTime.utc(2026, 9, 19)),
      _Phase(
          s.familiarization, DateTime.utc(2026, 9, 19), DateTime.utc(2026, 9, 21)),
      _Phase(
          s.competitionC1, DateTime.utc(2026, 9, 22), DateTime.utc(2026, 9, 23)),
      _Phase(
          s.competitionC2, DateTime.utc(2026, 9, 23), DateTime.utc(2026, 9, 25)),
      _Phase(s.closing, DateTime.utc(2026, 9, 25), DateTime.utc(2026, 9, 27)),
    ];

    final now = DateTime.now().toUtc();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
        color: WsColors.bgDeep,
        border: Border(
          top: BorderSide(color: Color(0xFF1e3a5f), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.timeline, size: 14, color: WsColors.accentBlue),
              const SizedBox(width: 8),
              Text(
                s.competitionProgress.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: WsColors.textSecondary,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(phases.length * 2 - 1, (i) {
              if (i.isOdd) {
                return const SizedBox(width: 2);
              }
              final phase = phases[i ~/ 2];
              final isActive =
                  now.isAfter(phase.start) && now.isBefore(phase.end);
              final isPast = now.isAfter(phase.end);

              return Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: isActive
                            ? WsColors.accentYellow
                            : isPast
                                ? WsColors.accentGreen
                                : WsColors.textSecondary.withAlpha(40),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      phase.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight:
                            isActive ? FontWeight.w700 : FontWeight.w500,
                        color: isActive
                            ? WsColors.accentYellow
                            : isPast
                                ? WsColors.accentGreen
                                : WsColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _Phase {
  final String label;
  final DateTime start;
  final DateTime end;

  _Phase(this.label, this.start, this.end);
}
