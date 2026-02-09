import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ai/ai_models.dart';
import '../../../core/ai/ai_providers.dart';
import '../../../core/ai/prompts/training_analysis_prompt.dart';
import '../../../core/constants/ws_colors.dart';
import '../../../core/i18n/locale_provider.dart';
import '../../../core/providers/time_providers.dart';
import '../../timezone/timezone_converter.dart';

/// AI分析面板 - 练习历史中的AI分析Tab
class AIAnalysisPanel extends ConsumerStatefulWidget {
  const AIAnalysisPanel({super.key});

  @override
  ConsumerState<AIAnalysisPanel> createState() => _AIAnalysisPanelState();
}

class _AIAnalysisPanelState extends ConsumerState<AIAnalysisPanel> {
  // final _chatController = TextEditingController();

  @override
  void dispose() {
    // _chatController.dispose();
    super.dispose();
  }

  void _startAnalysis() {
    final locale = LocaleScope.providerOf(context).locale;
    final langName = TrainingAnalysisPrompt.languageNameForLocale(locale);
    ref.read(aiAnalysisProvider.notifier).analyze(languageName: langName);
  }

  @override
  Widget build(BuildContext context) {
    final s = LocaleScope.of(context);
    final analysisState = ref.watch(aiAnalysisProvider);
    final historyAsync = ref.watch(aiAnalysisHistoryProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(s, analysisState.status),
          const SizedBox(height: 16),
          switch (analysisState.status) {
            AIAnalysisStatus.idle => _buildIdleState(s),
            AIAnalysisStatus.loading => _buildLoadingState(s),
            AIAnalysisStatus.success =>
              _buildAnalysisContent(s, analysisState.result!),
            AIAnalysisStatus.error =>
              _buildErrorState(s, analysisState.errorMessage ?? ''),
          },
          const SizedBox(height: 24),
          _buildHistorySection(s, historyAsync),
        ],
      ),
    );
  }

  Widget _buildHeader(dynamic s, AIAnalysisStatus status) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WsColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: WsColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: WsColors.accentCyan.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 22,
              color: WsColors.accentCyan,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.aiAnalysis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: WsColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  s.aiAnalysisDesc,
                  style: const TextStyle(
                    fontSize: 12,
                    color: WsColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (status != AIAnalysisStatus.idle)
            TextButton.icon(
              onPressed: status == AIAnalysisStatus.loading
                  ? null
                  : _startAnalysis,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(s.reanalyze),
              style: TextButton.styleFrom(
                foregroundColor: WsColors.accentCyan,
                backgroundColor: WsColors.accentCyan.withAlpha(12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: WsColors.accentCyan.withAlpha(40),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIdleState(dynamic s) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: WsColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: WsColors.border),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.psychology_outlined,
              size: 56,
              color: WsColors.textSecondary.withAlpha(100),
            ),
            const SizedBox(height: 16),
            Text(
              s.noAnalysisData,
              style: const TextStyle(
                fontSize: 15,
                color: WsColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _startAnalysis,
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: Text(s.startAnalysis),
              style: ElevatedButton.styleFrom(
                backgroundColor: WsColors.accentCyan,
                foregroundColor: WsColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(dynamic s) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      decoration: BoxDecoration(
        color: WsColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: WsColors.border),
      ),
      child: Center(
        child: Column(
          children: [
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: WsColors.accentCyan,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              s.generatingAnalysis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: WsColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(dynamic s, String errorMessage) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: WsColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: WsColors.border),
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: WsColors.errorRed,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              style: const TextStyle(
                fontSize: 13,
                color: WsColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _startAnalysis,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(s.retry),
              style: ElevatedButton.styleFrom(
                backgroundColor: WsColors.accentCyan,
                foregroundColor: WsColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisContent(dynamic s, AIAnalysisResult analysis) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 概览卡片
        _buildOverviewCard(s, analysis),
        const SizedBox(height: 16),
        // 洞察网格
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildInsightColumn(s.strengths, analysis.strengths, WsColors.accentGreen)),
            const SizedBox(width: 12),
            Expanded(child: _buildInsightColumn(s.weaknessesLabel, analysis.weaknesses, WsColors.accentRed)),
          ],
        ),
        const SizedBox(height: 16),
        // 建议列表
        if (analysis.recommendations.isNotEmpty)
          _buildRecommendations(s, analysis.recommendations),
      ],
    );
  }

  Widget _buildOverviewCard(dynamic s, AIAnalysisResult analysis) {
    final ratingColor = analysis.overallRating >= 80
        ? WsColors.accentGreen
        : analysis.overallRating >= 60
            ? WsColors.accentYellow
            : WsColors.accentRed;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: WsColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: WsColors.border),
      ),
      child: Row(
        children: [
          // 评分
          Column(
            children: [
              Text(
                s.overallRating,
                style: const TextStyle(
                  fontSize: 12,
                  color: WsColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: ratingColor, width: 3),
                ),
                child: Center(
                  child: Text(
                    '${analysis.overallRating.toInt()}',
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: ratingColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          // 信心度 + 趋势
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${s.confidence}: ',
                      style: const TextStyle(
                        fontSize: 13,
                        color: WsColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${(analysis.confidence * 100).toInt()}%',
                      style: const TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: WsColors.accentCyan,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      analysis.timeTrend.trend == TrendType.improving
                          ? Icons.trending_up
                          : analysis.timeTrend.trend == TrendType.declining
                              ? Icons.trending_down
                              : Icons.trending_flat,
                      size: 18,
                      color: analysis.timeTrend.trend == TrendType.improving
                          ? WsColors.accentGreen
                          : analysis.timeTrend.trend == TrendType.declining
                              ? WsColors.accentRed
                              : WsColors.accentYellow,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        analysis.timeTrend.summary,
                        style: const TextStyle(
                          fontSize: 13,
                          color: WsColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (analysis.predictedBestTime.inSeconds > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${s.aiPrediction}: ',
                        style: const TextStyle(
                          fontSize: 12,
                          color: WsColors.textSecondary,
                        ),
                      ),
                      Text(
                        _formatDuration(analysis.predictedBestTime),
                        style: const TextStyle(
                          fontFamily: 'JetBrainsMono',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: WsColors.accentBlue,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightColumn(
    String title,
    List<String> items,
    Color color,
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
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const Text(
              '-',
              style: TextStyle(
                fontSize: 13,
                color: WsColors.textSecondary,
              ),
            )
          else
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.withAlpha(150),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 13,
                          color: WsColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecommendations(
    dynamic s,
    List<TrainingRecommendation> recommendations,
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
                Icons.lightbulb_outline,
                size: 18,
                color: WsColors.accentYellow,
              ),
              const SizedBox(width: 8),
              Text(
                s.aiRecommendations,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: WsColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...recommendations.map(
            (rec) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: WsColors.bgPrimary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildPriorityBadge(rec.priority),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            rec.title,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: WsColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (rec.description.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        rec.description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: WsColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                    if (rec.actionSteps.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      ...rec.actionSteps.map(
                        (step) => Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '  →  ',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: WsColors.accentCyan,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  step,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: WsColors.textPrimary,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityBadge(RecommendationPriority priority) {
    final color = switch (priority) {
      RecommendationPriority.high => WsColors.accentRed,
      RecommendationPriority.medium => WsColors.accentYellow,
      RecommendationPriority.low => WsColors.accentGreen,
    };
    final label = switch (priority) {
      RecommendationPriority.high => 'HIGH',
      RecommendationPriority.medium => 'MED',
      RecommendationPriority.low => 'LOW',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /*
  Widget _buildChatSection(dynamic s) {
    final chatState = ref.watch(aiChatProvider);

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
                Icons.chat_bubble_outline,
                size: 18,
                color: WsColors.accentCyan,
              ),
              const SizedBox(width: 8),
              Text(
                s.talkToAI,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: WsColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (chatState.messages.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              margin: const EdgeInsets.only(bottom: 12),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: chatState.messages.length,
                itemBuilder: (context, index) {
                  final msg = chatState.messages[index];
                  final isUser = msg.role == 'user';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: isUser
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        if (!isUser) ...[
                          const Icon(
                            Icons.auto_awesome,
                            size: 16,
                            color: WsColors.accentCyan,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? WsColors.accentCyan.withAlpha(15)
                                  : WsColors.bgPrimary,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isUser
                                    ? WsColors.accentCyan.withAlpha(40)
                                    : WsColors.border,
                              ),
                            ),
                            child: Text(
                              msg.content,
                              style: const TextStyle(
                                fontSize: 13,
                                color: WsColors.textPrimary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          if (chatState.isLoading && chatState.currentResponse.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color: WsColors.accentCyan,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: WsColors.bgPrimary,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: WsColors.border),
                      ),
                      child: Text(
                        chatState.currentResponse,
                        style: const TextStyle(
                          fontSize: 13,
                          color: WsColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatController,
                  enabled: !chatState.isLoading,
                  decoration: InputDecoration(
                    hintText: s.typeYourQuestion,
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: WsColors.textSecondary,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: WsColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: WsColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: WsColors.accentCyan,
                      ),
                    ),
                    filled: true,
                    fillColor: WsColors.bgPrimary,
                  ),
                  style: const TextStyle(fontSize: 13),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: chatState.isLoading ? null : _sendMessage,
                icon: chatState.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: WsColors.accentCyan,
                        ),
                      )
                    : const Icon(
                        Icons.send_rounded,
                        color: WsColors.accentCyan,
                      ),
                style: IconButton.styleFrom(
                  backgroundColor: WsColors.accentCyan.withAlpha(15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;
    _chatController.clear();
    ref.read(aiChatProvider.notifier).sendMessage(text);
  }
  */

  Widget _buildHistorySection(
    dynamic s,
    AsyncValue<List<AIAnalysisResult>> historyAsync,
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
                Icons.history,
                size: 18,
                color: WsColors.accentCyan,
              ),
              const SizedBox(width: 8),
              Text(
                s.analysisHistory,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: WsColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (historyAsync.valueOrNull?.isNotEmpty ?? false)
                TextButton(
                  onPressed: () async {
                    final service =
                        ref.read(aiAnalysisHistoryServiceProvider);
                    await service.initialize();
                    await service.clearAll();
                    ref.invalidate(aiAnalysisHistoryProvider);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: WsColors.textSecondary,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: Text(
                    s.clearHistory,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          historyAsync.when(
            data: (history) {
              if (history.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      s.noHistoryRecords,
                      style: const TextStyle(
                        fontSize: 13,
                        color: WsColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }
              return Column(
                children: history.map((result) {
                  return _buildHistoryCard(result);
                }).toList(),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: WsColors.accentCyan,
                  ),
                ),
              ),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(AIAnalysisResult result) {
    final ratingColor = result.overallRating >= 80
        ? WsColors.accentGreen
        : result.overallRating >= 60
            ? WsColors.accentYellow
            : WsColors.accentRed;

    final trendIcon = result.timeTrend.trend == TrendType.improving
        ? Icons.trending_up
        : result.timeTrend.trend == TrendType.declining
            ? Icons.trending_down
            : Icons.trending_flat;

    final trendColor = result.timeTrend.trend == TrendType.improving
        ? WsColors.accentGreen
        : result.timeTrend.trend == TrendType.declining
            ? WsColors.accentRed
            : WsColors.accentYellow;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: WsColors.bgPrimary,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _showHistoryDetail(result),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: ratingColor, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      '${result.overallRating.toInt()}',
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: ratingColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDateTime(result.analyzedAt),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: WsColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (result.timeTrend.summary.isNotEmpty)
                        Text(
                          result.timeTrend.summary,
                          style: const TextStyle(
                            fontSize: 11,
                            color: WsColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                Icon(trendIcon, size: 18, color: trendColor),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: WsColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showHistoryDetail(AIAnalysisResult result) {
    final s = LocaleScope.of(context);
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.history,
                      size: 18,
                      color: WsColors.accentCyan,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDateTime(result.analyzedAt),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: WsColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: const Icon(Icons.close, size: 20),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _buildAnalysisContent(s, result),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final tz = ref.read(appTimezoneProvider);
    final local = TimezoneConverter.convert(dt, tz);
    final y = local.year;
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    final h = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $h:$min';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}
