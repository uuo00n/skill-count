import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/ws_colors.dart';
import '../../../core/i18n/locale_provider.dart';
import '../../../core/i18n/strings.dart';
import '../models/practice_record_model.dart';

class AnalyticsChartsView extends StatelessWidget {
  final List<PracticeRecord> records;

  const AnalyticsChartsView({
    super.key,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    final s = LocaleScope.of(context);
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
          _buildStatisticsCards(s),
          const SizedBox(height: 24),

          // Module comparison chart (only if multiple modules)
          if (recordsByModule.length > 1) ...[
            _buildModuleComparisonChart(recordsByModule, s),
            const SizedBox(height: 24),
          ],

          // Time trend chart
          if (records.length > 1) ...[
            _buildTimeTrendChart(records, s),
            const SizedBox(height: 24),
          ],

          // Efficiency distribution
          _buildEfficiencyChart(records, s),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: WsColors.accentCyan,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Icon(icon, size: 18, color: WsColors.textPrimary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: WsColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsCards(AppStrings s) {
    final totalTime = records.fold<Duration>(Duration.zero, (sum, r) => sum + r.totalDuration);
    final avgTime = Duration(seconds: (totalTime.inSeconds / records.length).toInt());
    final avgEfficiency = records.fold<double>(0, (sum, r) => sum + r.efficiency) / records.length;

    return Row(
      children: [
        _buildStatCard(s.totalSessions, '${records.length}', WsColors.accentCyan, Icons.list_alt),
        const SizedBox(width: 12),
        _buildStatCard(s.totalDuration, _formatDurationLabel(totalTime), WsColors.accentGreen, Icons.timer),
        const SizedBox(width: 12),
        _buildStatCard(s.averageDuration, _formatDurationLabel(avgTime), WsColors.accentYellow, Icons.schedule),
        const SizedBox(width: 12),
        _buildStatCard(
          s.averageEfficiency,
          '${(avgEfficiency * 100).toInt()}%',
          WsColors.accentBlue,
          Icons.speed,
        ),
      ],
    );
  }

  String _formatDurationLabel(Duration duration) {
    if (duration.inHours > 0) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }
    if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    }
    return '${duration.inSeconds}s';
  }

  String _formatAxisDuration(double secondsValue) {
    final seconds = secondsValue.round().clamp(0, 1000000000);
    if (seconds >= 3600) {
      return '${(seconds / 3600).round()}h';
    }
    if (seconds >= 60) {
      return '${(seconds / 60).round()}m';
    }
    return '${seconds}s';
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          color: Color.alphaBlend(color.withValues(alpha: 0.05), WsColors.surface),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: WsColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
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

  Widget _buildModuleComparisonChart(Map<String, List<PracticeRecord>> recordsByModule, AppStrings s) {
    final modules = recordsByModule.entries.toList();
    final data = modules.map((entry) {
      final avgDuration = entry.value.fold<Duration>(
            Duration.zero,
            (sum, r) => sum + r.totalDuration,
          ).inSeconds /
          entry.value.length;
      return BarChartGroupData(
        x: modules.indexOf(entry),
        barRods: [
          BarChartRodData(
            toY: avgDuration,
            color: WsColors.accentCyan,
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: avgDuration * 1.1, // Slightly higher than the bar for visual consistency
              color: WsColors.accentCyan.withValues(alpha: 0.05),
            ),
          ),
        ],
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WsColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: WsColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(s.moduleComparison, Icons.compare_arrows),
          const SizedBox(height: 24),
          SizedBox(
            height: 240,
            child: BarChart(
              BarChartData(
                barGroups: data,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => WsColors.surface,
                    tooltipBorder: const BorderSide(color: WsColors.border),
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final idx = group.x.toInt();
                      final moduleName = modules[idx].value[0].moduleName;
                      final durationStr = _formatDurationLabel(Duration(seconds: rod.toY.toInt()));
                      return BarTooltipItem(
                        '$moduleName\n',
                        const TextStyle(
                          color: WsColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: durationStr,
                            style: const TextStyle(
                              color: WsColors.accentCyan,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: WsColors.border.withValues(alpha: 0.5),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        if (value == meta.min || value == meta.max) return const SizedBox();
                        return Text(
                          _formatAxisDuration(value),
                          style: const TextStyle(fontSize: 10, color: WsColors.textSecondary),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < modules.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: SizedBox(
                              width: 60,
                              child: Text(
                                modules[idx].value[0].moduleName,
                                style: const TextStyle(fontSize: 10, color: WsColors.textSecondary),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildTimeTrendChart(List<PracticeRecord> records, AppStrings s) {
    final sortedRecords = List<PracticeRecord>.from(records)
      ..sort((a, b) => a.completedAt.compareTo(b.completedAt));

    final spots = sortedRecords.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        entry.value.totalDuration.inSeconds.toDouble(),
      );
    }).toList();

    // Determine interval to avoid crowding (target max ~6 labels)
    final double interval = (sortedRecords.length / 6).ceilToDouble();
    // Determine if we should show dots based on data density
    final showDots = sortedRecords.length < 20;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WsColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: WsColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(s.timeTrend, Icons.trending_up),
          const SizedBox(height: 24),
          SizedBox(
            height: 240,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: WsColors.border.withValues(alpha: 0.5),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: WsColors.accentCyan,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: showDots,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: WsColors.surface,
                          strokeWidth: 2,
                          strokeColor: WsColors.accentCyan,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          WsColors.accentCyan.withValues(alpha: 0.2),
                          WsColors.accentCyan.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        if (value == meta.min || value == meta.max) return const SizedBox();
                        return Text(
                          _formatAxisDuration(value),
                          style: const TextStyle(fontSize: 10, color: WsColors.textSecondary),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: interval,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < sortedRecords.length) {
                          final date = sortedRecords[idx].completedAt;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              '${date.month}/${date.day}',
                              style: const TextStyle(fontSize: 10, color: WsColors.textSecondary),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => WsColors.surface,
                    tooltipBorder: const BorderSide(color: WsColors.border),
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final idx = spot.x.toInt();
                        final date = sortedRecords[idx].completedAt;
                        final durationStr = _formatDurationLabel(Duration(seconds: spot.y.toInt()));
                        return LineTooltipItem(
                          '${date.month}/${date.day}\n',
                          const TextStyle(
                            color: WsColors.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: durationStr,
                              style: const TextStyle(
                                color: WsColors.accentCyan,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEfficiencyChart(List<PracticeRecord> records, AppStrings s) {
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
        color: WsColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: WsColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(s.efficiencyDistribution, Icons.pie_chart),
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
              _buildLegend(s.excellent, WsColors.accentGreen),
              _buildLegend(s.good, WsColors.accentCyan),
              _buildLegend(s.fair, WsColors.accentYellow),
              _buildLegend(s.needsImprovement, WsColors.accentRed),
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
