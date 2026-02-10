import 'package:flutter/material.dart' hide KeyEvent;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/ws_colors.dart';
import '../../../core/i18n/locale_provider.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/providers/time_providers.dart';
import '../../timezone/timezone_converter.dart';
import '../models/practice_record_model.dart';

class RecordsListView extends ConsumerWidget {
  final List<PracticeRecord> records;

  const RecordsListView({
    super.key,
    required this.records,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = LocaleScope.of(context);
    final selectedTz = ref.watch(appTimezoneProvider);
    // Sort records by date, newest first
    final sortedRecords = List<PracticeRecord>.from(records)
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedRecords.length,
      itemBuilder: (context, index) {
        final record = sortedRecords[index];
        return _buildRecordCard(context, record, s, selectedTz);
      },
    );
  }

  Widget _buildRecordCard(
    BuildContext context,
    PracticeRecord record,
    AppStrings s,
    String timezoneId,
  ) {
    final hours = record.totalDuration.inHours;
    final minutes = (record.totalDuration.inMinutes % 60);
    final seconds = (record.totalDuration.inSeconds % 60);

    final durationStr =
        '${hours > 0 ? '$hours:' : ''}${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    final efficiencyColor = record.efficiency >= 1.0
        ? WsColors.accentGreen
        : record.efficiency >= 0.8
            ? WsColors.accentYellow
            : WsColors.accentRed;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: WsColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showRecordDetail(context, record, s, timezoneId),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: WsColors.accentCyan.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.extension_outlined,
                      color: WsColors.accentCyan,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.moduleName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: WsColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 12,
                              color: WsColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(record.completedAt, timezoneId),
                              style: const TextStyle(
                                fontSize: 12,
                                color: WsColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Efficiency badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: efficiencyColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: efficiencyColor.withAlpha(50)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.speed, size: 14, color: efficiencyColor),
                        const SizedBox(width: 4),
                        Text(
                          '${(record.efficiency * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: efficiencyColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: WsColors.border),
              ),
              // Stats row
              Row(
                children: [
                  _statItem(
                    Icons.timer_outlined,
                    s.durationLabel,
                    durationStr,
                  ),
                  _verticalDivider(),
                  _statItem(
                    Icons.check_circle_outline,
                    s.completionLabel,
                    '${record.completedTasks}/${record.totalTasks}',
                  ),
                  _verticalDivider(),
                  _statItem(
                    Icons.schedule,
                    s.averageLabel,
                    _formatDuration(record.averageTaskDuration),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRecordDetail(
    BuildContext context,
    PracticeRecord record,
    AppStrings s,
    String timezoneId,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640, maxHeight: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dialog header
              _buildDetailHeader(ctx, record, s, timezoneId),
              const Divider(height: 1),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailOverview(record, s),
                      if (record.taskRecords.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildTaskRecordsSection(record, s),
                      ],
                      if (record.keyEvents.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildKeyEventsSection(record, s, timezoneId),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailHeader(
    BuildContext ctx,
    PracticeRecord record,
    AppStrings s,
    String timezoneId,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: WsColors.accentCyan.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.extension_outlined,
              size: 18,
              color: WsColors.accentCyan,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.moduleName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: WsColors.textPrimary,
                  ),
                ),
                Text(
                  _formatDate(record.completedAt, timezoneId),
                  style: const TextStyle(
                    fontSize: 12,
                    color: WsColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(ctx).pop(),
            icon: const Icon(Icons.close, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailOverview(PracticeRecord record, AppStrings s) {
    final efficiencyColor = record.efficiency >= 1.0
        ? WsColors.accentGreen
        : record.efficiency >= 0.8
            ? WsColors.accentYellow
            : WsColors.accentRed;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WsColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: WsColors.border),
      ),
      child: Row(
        children: [
          // Efficiency circle
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: efficiencyColor, width: 3),
            ),
            child: Center(
              child: Text(
                '${(record.efficiency * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: efficiencyColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              children: [
                _overviewRow(
                  Icons.timer_outlined,
                  s.durationLabel,
                  _formatDurationLong(record.totalDuration),
                ),
                const SizedBox(height: 6),
                _overviewRow(
                  Icons.schedule,
                  s.estimatedDuration,
                  _formatDurationLong(record.estimatedDuration),
                ),
                const SizedBox(height: 6),
                _overviewRow(
                  Icons.check_circle_outline,
                  s.completionLabel,
                  '${record.completedTasks} / ${record.totalTasks}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _overviewRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: WsColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: WsColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            fontFamily: 'JetBrainsMono',
            color: WsColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTaskRecordsSection(PracticeRecord record, AppStrings s) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WsColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: WsColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.task_alt,
                size: 16,
                color: WsColors.accentCyan,
              ),
              const SizedBox(width: 8),
              Text(
                s.moduleTasks,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: WsColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...record.taskRecords.map((task) => _buildTaskRow(task, s)),
        ],
      ),
    );
  }

  Widget _buildTaskRow(TaskRecord task, AppStrings s) {
    final isDone = task.status == 'done';
    final effColor = task.efficiency >= 1.0
        ? WsColors.accentGreen
        : task.efficiency >= 0.8
            ? WsColors.accentYellow
            : WsColors.accentRed;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: WsColors.bgPrimary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              isDone ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 16,
              color: isDone ? WsColors.accentGreen : WsColors.textSecondary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.taskTitle,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: WsColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${s.actualSpent}: ${_formatDuration(task.actualSpent)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: WsColors.textSecondary,
                          fontFamily: 'JetBrainsMono',
                        ),
                      ),
                      if (task.estimatedDuration != null) ...[
                        const SizedBox(width: 12),
                        Text(
                          '${s.estimatedDuration}: ${_formatDuration(task.estimatedDuration!)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: WsColors.textSecondary,
                            fontFamily: 'JetBrainsMono',
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: effColor.withAlpha(20),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: effColor.withAlpha(60)),
              ),
              child: Text(
                '${(task.efficiency * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'JetBrainsMono',
                  color: effColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyEventsSection(
    PracticeRecord record,
    AppStrings s,
    String timezoneId,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WsColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: WsColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.flag_outlined,
                size: 16,
                color: WsColors.accentYellow,
              ),
              const SizedBox(width: 8),
              Text(
                s.keyEvents,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: WsColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...record.keyEvents.map((event) =>
              _buildEventRow(event, timezoneId)),
        ],
      ),
    );
  }

  Widget _buildEventRow(KeyEvent event, String timezoneId) {
    final (icon, color, label) = _eventMeta(event.type);
    final time = _formatTime(event.timestamp, timezoneId);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            time,
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'JetBrainsMono',
              color: WsColors.textSecondary,
            ),
          ),
          const SizedBox(width: 10),
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  (IconData, Color, String) _eventMeta(KeyEventType type) {
    return switch (type) {
      KeyEventType.timerStart => (
          Icons.play_arrow,
          WsColors.accentGreen,
          'Start',
        ),
      KeyEventType.timerPause => (
          Icons.pause,
          WsColors.accentYellow,
          'Pause',
        ),
      KeyEventType.timerResume => (
          Icons.play_arrow,
          WsColors.accentCyan,
          'Resume',
        ),
      KeyEventType.timerStop => (
          Icons.stop,
          WsColors.accentRed,
          'Stop',
        ),
      KeyEventType.taskComplete => (
          Icons.check,
          WsColors.accentGreen,
          'Task Done',
        ),
      KeyEventType.moduleComplete => (
          Icons.flag,
          WsColors.accentCyan,
          'Module Done',
        ),
    };
  }

  Widget _verticalDivider() {
    return Container(
      height: 24,
      width: 1,
      color: WsColors.border,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _statItem(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 12, color: WsColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: WsColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
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
      ),
    );
  }

  String _formatDate(DateTime dt, String timezoneId) {
    final local = TimezoneConverter.convert(dt, timezoneId);
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')} '
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime dt, String timezoneId) {
    final local = TimezoneConverter.convert(dt, timezoneId);
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}:${local.second.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = (d.inSeconds % 60);
    return '$minutes\'${seconds.toString().padLeft(2, '0')}"';
  }

  String _formatDurationLong(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    final seconds = d.inSeconds % 60;
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
