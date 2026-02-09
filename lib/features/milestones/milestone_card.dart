import 'package:flutter/material.dart';
import '../../core/constants/ws_colors.dart';
import '../../core/i18n/locale_provider.dart';
import '../../features/timezone/timezone_converter.dart';
import 'milestone_model.dart';

class MilestoneCard extends StatelessWidget {
  final Milestone milestone;
  final DateTime utcNow;
  final String timezoneId;
  final Function(Milestone)? onEdit;
  final Function(String)? onDelete;

  const MilestoneCard({
    super.key,
    required this.milestone,
    required this.utcNow,
    required this.timezoneId,
    this.onEdit,
    this.onDelete,
  });

  void _showActionMenu(BuildContext context) {
    final s = LocaleScope.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: WsColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          milestone.title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: WsColors.textPrimary,
          ),
        ),
        content: Text(
          milestone.description ?? '',
          style: const TextStyle(
            fontSize: 12,
            color: WsColors.textSecondary,
          ),
        ),
        actions: [
          if (onEdit != null)
            TextButton.icon(
              onPressed: () {
                Navigator.of(ctx).pop();
                onEdit!(milestone);
              },
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: Text(s.editMilestone),
              style: TextButton.styleFrom(
                foregroundColor: WsColors.accentCyan,
              ),
            ),
          if (onDelete != null)
            TextButton.icon(
              onPressed: () {
                Navigator.of(ctx).pop();
                onDelete!(milestone.id);
              },
              icon: const Icon(Icons.delete_outline, size: 18),
              label: Text(s.confirmDelete),
              style: TextButton.styleFrom(
                foregroundColor: WsColors.errorRed,
              ),
            ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(s.close),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = LocaleScope.of(context);
    final remaining = milestone.targetTime.difference(utcNow);
    final isPast = remaining.isNegative || remaining == Duration.zero;
    final days = isPast ? 0 : remaining.inDays;

    final statusLabel = isPast ? s.completed : s.milestoneEvent;
    final statusColor = isPast ? WsColors.accentGreen : WsColors.accentYellow;

    // Format target date using selected timezone
    final target = TimezoneConverter.convert(milestone.targetTime, timezoneId);
    final dateStr =
        '${s.monthNames[target.month - 1]} ${target.day.toString().padLeft(2, '0')}, ${target.year}';

    return GestureDetector(
      onLongPress: () => _showActionMenu(context),
      child: Container(
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
                  if (milestone.description != null &&
                      milestone.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      milestone.description!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: WsColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
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
                color:
                    isPast ? WsColors.textSecondary : WsColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
