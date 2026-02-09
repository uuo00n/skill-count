import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/ws_colors.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/providers/practice_history_provider.dart';
import 'widgets/records_list_view.dart';
import 'widgets/analytics_charts_view.dart';

class PracticeHistoryPage extends ConsumerStatefulWidget {
  const PracticeHistoryPage({super.key});

  @override
  ConsumerState<PracticeHistoryPage> createState() => _PracticeHistoryPageState();
}

class _PracticeHistoryPageState extends ConsumerState<PracticeHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = LocaleScope.of(context);
    final recordsAsync = ref.watch(practiceRecordsProvider);

    return Column(
      children: [
        // TabBar
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: WsColors.bgPrimary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: WsColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: const EdgeInsets.all(4),
            labelColor: WsColors.accentCyan,
            unselectedLabelColor: WsColors.textSecondary,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            dividerColor: Colors.transparent,
            tabs: [
              Tab(text: s.recordsList),
              Tab(text: s.analyticsCharts),
            ],
          ),
        ),
        // TabBarView
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Records List Tab
              recordsAsync.when(
                data: (records) {
                  if (records.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 64,
                            color: WsColors.textSecondary.withAlpha(80),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            s.noRecords,
                            style: TextStyle(
                              fontSize: 16,
                              color: WsColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return RecordsListView(records: records);
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (err, stack) => Center(
                  child: Text('Error: $err'),
                ),
              ),
              // Analytics Tab
              recordsAsync.when(
                data: (records) {
                  if (records.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bar_chart,
                            size: 64,
                            color: WsColors.textSecondary.withAlpha(80),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            s.noRecords,
                            style: TextStyle(
                              fontSize: 16,
                              color: WsColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return AnalyticsChartsView(records: records);
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (err, stack) => Center(
                  child: Text('Error: $err'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
