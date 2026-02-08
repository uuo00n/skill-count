import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/ws_colors.dart';
import '../models/practice_record_model.dart';

class AnalyticsChartsView extends StatelessWidget {
  final List<PracticeRecord> records;

  const AnalyticsChartsView({
    super.key,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    // Group records by module
    final Map<String, List<PracticeRecord>> recordsByModule = {};
    for (final record in records) {
      recordsByModule.putIfAbsent(record.moduleId, () => []).add(record);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall statistics
          _buildStatisticsCards(),
          const SizedBox(height: 24),

          // Module comparison chart (only if multiple modules)
          if (recordsByModule.length > 1) ...[
            const Text(
              '模块对比',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: WsColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildModuleComparisonChart(recordsByModule),
            const SizedBox(height: 24),
          ],

          // Time trend chart
          if (records.length > 1) ...[
            const Text(
              '时间趋势',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: WsColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildTimeTrendChart(records),
            const SizedBox(height: 24),
          ],

          // Efficiency distribution
          _buildEfficiencyChart(records),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards() {
    final totalTime = records.fold<Duration>(Duration.zero, (sum, r) => sum + r.totalDuration);
    final avgTime = Duration(seconds: (totalTime.inSeconds / records.length).toInt());
    final avgEfficiency = records.fold<double>(0, (sum, r) => sum + r.efficiency) / records.length;

    return Row(
      children: [
        _buildStatCard('总计划数', '${records.length}', WsColors.accentCyan),
        const SizedBox(width: 12),
        _buildStatCard('总耗时', '${totalTime.inHours}h', WsColors.accentGreen),
        const SizedBox(width: 12),
        _buildStatCard('平均耗时', '${avgTime.inMinutes}m', WsColors.accentYellow),
        const SizedBox(width: 12),
        _buildStatCard('平均效率', '${(avgEfficiency * 100).toInt()}%', WsColors.accentBlue),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(60)),
          color: color.withAlpha(20),
        ),
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
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: 'JetBrainsMono',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleComparisonChart(Map<String, List<PracticeRecord>> recordsByModule) {
    final modules = recordsByModule.entries.toList();
    final data = modules.map((entry) {
      final avgDuration = entry.value.fold<Duration>(
        Duration.zero,
        (sum, r) => sum + r.totalDuration,
      ).inMinutes ~/
          entry.value.length;
      return BarChartGroupData(
        x: modules.indexOf(entry),
        barRods: [
          BarChartRodData(
            toY: avgDuration.toDouble(),
            color: WsColors.accentCyan,
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
        ],
      );
    }).toList();

    return Container(
      height: 300,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: WsColors.border),
      ),
      child: BarChart(
        BarChartData(
          barGroups: data,
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}m',
                    style: const TextStyle(fontSize: 10, color: WsColors.textSecondary),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx >= 0 && idx < modules.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        modules[idx].value[0].moduleName.substring(0, 3),
                        style: const TextStyle(fontSize: 10, color: WsColors.textSecondary),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeTrendChart(List<PracticeRecord> records) {
    final sortedRecords = List<PracticeRecord>.from(records)
      ..sort((a, b) => a.completedAt.compareTo(b.completedAt));

    final spots = sortedRecords.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        entry.value.totalDuration.inMinutes.toDouble(),
      );
    }).toList();

    return Container(
      height: 280,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: WsColors.border),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: WsColors.accentCyan,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: WsColors.accentCyan.withAlpha(30),
              ),
            ),
          ],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}m',
                    style: const TextStyle(fontSize: 10, color: WsColors.textSecondary),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx >= 0 && idx < sortedRecords.length) {
                    final date = sortedRecords[idx].completedAt;
                    return Text(
                      '${date.month}/${date.day}',
                      style: const TextStyle(fontSize: 9, color: WsColors.textSecondary),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEfficiencyChart(List<PracticeRecord> records) {
    // Group by efficiency ranges
    final veryGood = records.where((r) => r.efficiency >= 1.2).length;
    final good = records.where((r) => r.efficiency >= 1.0 && r.efficiency < 1.2).length;
    final fair = records.where((r) => r.efficiency >= 0.8 && r.efficiency < 1.0).length;
    final poor = records.where((r) => r.efficiency < 0.8).length;

    final sections = [
      if (veryGood > 0)
        PieChartSectionData(
          value: veryGood.toDouble(),
          color: WsColors.accentGreen,
          title: '$veryGood',
          radius: 50,
          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: WsColors.white),
        ),
      if (good > 0)
        PieChartSectionData(
          value: good.toDouble(),
          color: WsColors.accentCyan,
          title: '$good',
          radius: 50,
          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: WsColors.white),
        ),
      if (fair > 0)
        PieChartSectionData(
          value: fair.toDouble(),
          color: WsColors.accentYellow,
          title: '$fair',
          radius: 50,
          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: WsColors.white),
        ),
      if (poor > 0)
        PieChartSectionData(
          value: poor.toDouble(),
          color: WsColors.accentRed,
          title: '$poor',
          radius: 50,
          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: WsColors.white),
        ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: WsColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '效率分布',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: WsColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              height: 200,
              width: 200,
              child: PieChart(
                PieChartData(sections: sections),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegend('优秀', WsColors.accentGreen),
              _buildLegend('良好', WsColors.accentCyan),
              _buildLegend('一般', WsColors.accentYellow),
              _buildLegend('需改进', WsColors.accentRed),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: WsColors.textSecondary),
        ),
      ],
    );
  }
}
