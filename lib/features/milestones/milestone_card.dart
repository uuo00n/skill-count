import 'package:flutter/material.dart';
import '../../core/constants/ws_colors.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/utils/time_utils.dart';
import 'milestone_model.dart';

class MilestoneCard extends StatelessWidget {
  final Milestone milestone;

  const MilestoneCard({super.key, required this.milestone});

  @override
  Widget build(BuildContext context) {
    final s = LocaleScope.of(context);
    final remaining = TimeUtils.timeLeft(milestone.targetTime);
    final days = remaining.inDays;
    final isPast = remaining == Duration.zero;

    final statusLabel = isPast ? s.completed : s.upcoming;
    final statusColor = isPast ? WsColors.accentGreen : WsColors.accentYellow;

    // Format target date
    final target = milestone.targetTime.toLocal();
    final dateStr =
        '${_monthName(target.month)} ${target.day.toString().padLeft(2, '0')}, ${target.year}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: WsColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: WsColors.border,
        ),
      ),
      child: Row(
        children: [
          // Left color bar
          Container(
            width: 3,
            height: 44,
            decoration: BoxDecoration(
              color: isPast ? WsColors.accentGreen : WsColors.accentRed,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          // Middle info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    statusLabel.toUpperCase(),
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  milestone.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: WsColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateStr,
                  style: const TextStyle(
                    fontSize: 11,
                    color: WsColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Right days count
          Text(
            isPast ? '--' : days.toString().padLeft(2, '0'),
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isPast
                  ? WsColors.textSecondary
                  : WsColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month - 1];
  }
}
