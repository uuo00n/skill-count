import 'package:flutter/material.dart';
import '../../core/constants/ws_colors.dart';
import '../../core/i18n/locale_provider.dart';
import '../../features/timezone/timezone_converter.dart';
import '../../widgets/ws_flip_digit.dart';
import 'milestone_model.dart';

class MilestoneCard extends StatefulWidget {
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

  @override
  State<MilestoneCard> createState() => _MilestoneCardState();
}

class _MilestoneCardState extends State<MilestoneCard> {
  @override
  void didUpdateWidget(MilestoneCard oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

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
          widget.milestone.title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: WsColors.textPrimary,
          ),
        ),
        content: Text(
          widget.milestone.description ?? '',
          style: const TextStyle(
            fontSize: 12,
            color: WsColors.textSecondary,
          ),
        ),
        actions: [
          if (widget.onEdit != null)
            TextButton.icon(
              onPressed: () {
                Navigator.of(ctx).pop();
                widget.onEdit!(widget.milestone);
              },
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: Text(s.editMilestone),
              style: TextButton.styleFrom(
                foregroundColor: WsColors.accentCyan,
              ),
            ),
          if (widget.onDelete != null)
            TextButton.icon(
              onPressed: () {
                Navigator.of(ctx).pop();
                widget.onDelete!(widget.milestone.id);
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
    final remaining = widget.milestone.targetTime.difference(widget.utcNow);
    final isPast = remaining.isNegative || remaining == Duration.zero;
    final days = isPast ? 0 : remaining.inDays;

    final statusLabel = isPast ? s.completed : s.milestoneEvent;
    final statusColor = isPast ? WsColors.accentGreen : WsColors.accentYellow;

    // Format target date using selected timezone
    final target =
        TimezoneConverter.convert(widget.milestone.targetTime, widget.timezoneId);
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
                    widget.milestone.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: WsColors.textPrimary,
                    ),
                  ),
                  if (widget.milestone.description != null &&
                      widget.milestone.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.milestone.description!,
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
            const SizedBox(width: 12),
            // Right days ticker
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isPast ? WsColors.bgDeep : WsColors.darkBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: days.toString().split('').map((digit) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1),
                        child: WsFlipDigit(
                          value: int.parse(digit),
                          width: 18,
                          height: 26,
                          textStyle: TextStyle(
                            fontFamily: 'JetBrainsMono',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isPast
                                ? WsColors.textSecondary
                                : WsColors.white,
                            height: 1.0,
                          ),
                          backgroundColor:
                              isPast ? WsColors.bgDeep : WsColors.darkBlue,
                          borderColor: Colors.transparent,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  s.days,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isPast
                        ? WsColors.textSecondary
                        : WsColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
