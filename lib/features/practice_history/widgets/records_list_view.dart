import 'package:flutter/material.dart';
import '../../../core/constants/ws_colors.dart';
import '../models/practice_record_model.dart';

class RecordsListView extends StatelessWidget {
  final List<PracticeRecord> records;

  const RecordsListView({
    super.key,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    // Sort records by date, newest first
    final sortedRecords = List<PracticeRecord>.from(records)
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedRecords.length,
      itemBuilder: (context, index) {
        final record = sortedRecords[index];
        return _buildRecordCard(record);
      },
    );
  }

  Widget _buildRecordCard(PracticeRecord record) {
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: WsColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.moduleName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: WsColors.darkBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(record.completedAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: WsColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Efficiency badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: efficiencyColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: efficiencyColor.withAlpha(60)),
                  ),
                  child: Text(
                    '${(record.efficiency * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: efficiencyColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Stats row
            Row(
              children: [
                _statItem('耗时', durationStr),
                const SizedBox(width: 16),
                _statItem(
                  '完成度',
                  '${record.completedTasks}/${record.totalTasks}',
                ),
                const SizedBox(width: 16),
                _statItem(
                  '平均',
                  _formatDuration(record.averageTaskDuration),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: WsColors.textSecondary,
            ),
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
