import 'package:flutter/material.dart';
import '../../core/constants/ws_colors.dart';
import '../../core/i18n/locale_provider.dart';

class MilestoneDeleteDialog extends StatelessWidget {
  final String milestoneTitle;
  final DateTime targetTime;
  final VoidCallback onConfirm;

  const MilestoneDeleteDialog({
    super.key,
    required this.milestoneTitle,
    required this.targetTime,
    required this.onConfirm,
  });

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final s = LocaleScope.of(context);

    return AlertDialog(
      backgroundColor: WsColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: WsColors.errorRed.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_rounded,
              size: 24,
              color: WsColors.errorRed,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            s.confirmDeleteMilestone,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: WsColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            milestoneTitle,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: WsColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            _formatDate(targetTime),
            style: const TextStyle(
              fontSize: 12,
              color: WsColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            s.deleteMilestoneWarning,
            style: const TextStyle(
              fontSize: 13,
              color: WsColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            s.cancel,
            style: const TextStyle(
              color: WsColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: WsColors.errorRed,
            foregroundColor: WsColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            s.confirmDelete,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }
}
