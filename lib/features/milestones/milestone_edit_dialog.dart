import 'package:flutter/material.dart';
import '../../core/constants/ws_colors.dart';
import '../../core/i18n/locale_provider.dart';
import 'milestone_model.dart';

class MilestoneEditDialog extends StatefulWidget {
  final Milestone? milestone;
  final Function(Milestone) onSave;

  const MilestoneEditDialog({
    super.key,
    this.milestone,
    required this.onSave,
  });

  @override
  State<MilestoneEditDialog> createState() => _MilestoneEditDialogState();
}

class _MilestoneEditDialogState extends State<MilestoneEditDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late int _selectedPriority;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.milestone?.title ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.milestone?.description ?? '',
    );
    _selectedDate = widget.milestone?.targetTime ?? DateTime.now().toUtc();
    _selectedPriority = widget.milestone?.priority ?? 1;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_titleController.text.trim().isEmpty) return;

    final milestone = Milestone(
      id: widget.milestone?.id ??
          'milestone_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      targetTime: _selectedDate,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      priority: _selectedPriority,
      isCompleted: widget.milestone?.isCompleted ?? false,
      createdAt: widget.milestone?.createdAt,
    );

    widget.onSave(milestone);
    Navigator.of(context).pop();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );

    if (picked != null && mounted) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );

      if (time != null && mounted) {
        setState(() {
          _selectedDate = DateTime.utc(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = LocaleScope.of(context);
    final isEditMode = widget.milestone != null;

    return AlertDialog(
      backgroundColor: WsColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Text(
        isEditMode ? s.editMilestone : s.addMilestone,
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
            // Title
            Text(
              s.milestoneTitle,
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
                hintText: s.enterMilestoneTitle,
                hintStyle: const TextStyle(color: WsColors.textSecondary),
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
            const SizedBox(height: 16),
            // Description
            Text(
              s.moduleDescription,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: WsColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              style: const TextStyle(
                color: WsColors.textPrimary,
                fontSize: 14,
              ),
              maxLines: 2,
              decoration: InputDecoration(
                hintText: s.enterModuleDescription,
                hintStyle: const TextStyle(color: WsColors.textSecondary),
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
            const SizedBox(height: 16),
            // Target Date & Time
            Text(
              s.targetDateTime,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: WsColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: WsColors.bgDeep.withAlpha(80),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: WsColors.textSecondary.withAlpha(40),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: WsColors.accentCyan,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _formatDateTime(_selectedDate),
                        style: const TextStyle(
                          fontSize: 14,
                          color: WsColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.arrow_drop_down,
                        color: WsColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Priority
            Text(
              s.milestonePriority,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: WsColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (index) {
                final priority = index + 1;
                final isSelected = _selectedPriority == priority;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTap: () =>
                            setState(() => _selectedPriority = priority),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? WsColors.accentCyan.withAlpha(30)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isSelected
                                  ? WsColors.accentCyan
                                  : WsColors.textSecondary.withAlpha(40),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$priority',
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
              }),
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
