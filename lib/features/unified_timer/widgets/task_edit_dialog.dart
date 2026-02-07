import 'package:flutter/material.dart';

import '../../../core/constants/ws_colors.dart';
import '../../../core/i18n/locale_provider.dart';
import '../models/unified_timer_model.dart';

class TaskEditDialog extends StatefulWidget {
  final TaskItem? task;
  final Function(TaskItem) onSave;

  const TaskEditDialog({
    super.key,
    this.task,
    required this.onSave,
  });

  @override
  State<TaskEditDialog> createState() => _TaskEditDialogState();
}

class _TaskEditDialogState extends State<TaskEditDialog> {
  late TextEditingController _titleController;
  late int _selectedMinutes;

  static const _durationOptions = [15, 30, 45, 60, 90, 120];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.task?.title ?? '',
    );
    _selectedMinutes = widget.task?.estimatedDuration?.inMinutes ?? 30;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_titleController.text.trim().isEmpty) return;

    final task = TaskItem(
      id: widget.task?.id ??
          'custom_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      status: widget.task?.status ?? TaskStatus.upcoming,
      estimatedDuration: Duration(minutes: _selectedMinutes),
      actualSpent: widget.task?.actualSpent ?? Duration.zero,
      completedAt: widget.task?.completedAt,
    );

    widget.onSave(task);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final s = LocaleScope.of(context);
    final isEditMode = widget.task != null;

    return AlertDialog(
      backgroundColor: WsColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Text(
        isEditMode ? s.editTask : s.addTask,
        style: const TextStyle(
          color: WsColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.taskTitle,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: WsColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              autofocus: true,
              style: const TextStyle(
                color: WsColors.textPrimary,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: s.enterTaskTitle,
                hintStyle: const TextStyle(
                  color: WsColors.textSecondary,
                ),
                filled: true,
                fillColor: WsColors.bgDeep.withAlpha(80),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: WsColors.accentCyan,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              s.estimatedDuration,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: WsColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: _durationOptions.map((minutes) {
                final isSelected = _selectedMinutes == minutes;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTap: () =>
                            setState(() => _selectedMinutes = minutes),
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? WsColors.accentCyan.withAlpha(30)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isSelected
                                  ? WsColors.accentCyan
                                  : WsColors.textSecondary
                                      .withAlpha(40),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${minutes}m',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? WsColors.accentCyan
                                    : WsColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
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
          onPressed: _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: WsColors.accentCyan,
            foregroundColor: WsColors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            s.save,
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
