import 'package:flutter/material.dart';
import '../../../core/constants/ws_colors.dart';
import '../../../core/i18n/locale_provider.dart';
import '../../../core/i18n/strings.dart';
import '../models/practice_record_model.dart';

class RecordsListView extends StatelessWidget {
  final List<PracticeRecord> records;

  const RecordsListView({
    super.key,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    final s = LocaleScope.of(context);
    // Sort records by date, newest first
    final sortedRecords = List<PracticeRecord>.from(records)
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedRecords.length,
      itemBuilder: (context, index) {
        final record = sortedRecords[index];
        return _buildRecordCard(record, s);
      },
    );
  }

  Widget _buildRecordCard(PracticeRecord record, AppStrings s) {
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
                            _formatDate(record.completedAt),
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: efficiencyColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: efficiencyColor.withAlpha(50)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.speed,
                        size: 14,
                        color: efficiencyColor,
                      ),
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
                _statItem(Icons.timer_outlined, s.durationLabel, durationStr),
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
    );
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

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = (d.inSeconds % 60);
    return '$minutes\'${seconds.toString().padLeft(2, '0')}"';
  }
}
