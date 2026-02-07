import 'package:flutter/material.dart';

import '../../../core/constants/ws_colors.dart';
import '../../../core/i18n/locale_provider.dart';
import '../models/unified_timer_model.dart';
import 'task_edit_dialog.dart';

class TaskDetailDialog extends StatelessWidget {
  final TaskItem task;
  final Function(TaskItem) onUpdate;

  const TaskDetailDialog({
    super.key,
    required this.task,
    required this.onUpdate,
  });

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '-';
    return '${dateTime.month}/${dateTime.day} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor() {
    switch (task.status) {
      case TaskStatus.done:
        return WsColors.accentGreen;
      case TaskStatus.current:
        return WsColors.accentCyan;
      case TaskStatus.upcoming:
        return WsColors.textSecondary;
    }
  }

  IconData _getStatusIcon() {
    switch (task.status) {
      case TaskStatus.done:
        return Icons.check_circle;
      case TaskStatus.current:
        return Icons.play_circle;
      case TaskStatus.upcoming:
        return Icons.radio_button_unchecked;
    }
  }

  String _getStatusText(dynamic s) {
    switch (task.status) {
      case TaskStatus.done:
        return s.done.toUpperCase();
      case TaskStatus.current:
        return s.current.toUpperCase();
      case TaskStatus.upcoming:
        return s.upcoming.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = LocaleScope.of(context);

    return Dialog(
      backgroundColor: WsColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 450,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title bar
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getStatusIcon(),
                    size: 20,
                    color: _getStatusColor(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: WsColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getStatusText(s),
                        style: TextStyle(
                          fontSize: 12,
                          color: _getStatusColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            // Time info
            _buildInfoRow(
              s.estimatedDuration,
              _formatDuration(task.estimatedDuration ?? Duration.zero),
              Icons.access_time,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              s.actualSpent,
              _formatDuration(task.actualSpent),
              Icons.timer_outlined,
            ),
            if (task.completedAt != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                s.completedAt,
                _formatDateTime(task.completedAt),
                Icons.check_circle,
              ),
            ],
            const Divider(height: 32),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(
                        color: WsColors.textSecondary.withAlpha(40),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      s.close,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      showDialog(
                        context: context,
                        builder: (ctx) => TaskEditDialog(
                          task: task,
                          onSave: (updatedTask) => onUpdate(updatedTask),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WsColors.accentCyan,
                      foregroundColor: WsColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      s.editTask,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: WsColors.textSecondary),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: WsColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: WsColors.textPrimary,
            fontFamily: 'JetBrainsMono',
          ),
        ),
      ],
    );
  }
}
