import 'strings.dart';

class ZhTwStrings implements AppStrings {
  const ZhTwStrings();

  @override
  String get appTitle => 'SkillCount';
  @override
  String get countdown => '倒計時';
  @override
  String get pomodoro => '訓練計時';
  @override
  String get milestones => '里程碑';
  @override
  String get timezone => '時區';
  @override
  String get openingCeremony => '世界技能大賽開幕式';
  @override
  String get shanghai2026 => '上海 2026';
  @override
  String get skillPomodoro => '技能訓練計時器';
  @override
  String get trainingTimer => '訓練計時器';
  @override
  String get start => '開始';
  @override
  String get pause => '暫停';
  @override
  String get reset => '重置';
  @override
  String get resume => '繼續';
  @override
  String get restart => '重新開始';
  @override
  String get days => '天';
  @override
  String get hours => '時';
  @override
  String get minutes => '分';
  @override
  String get seconds => '秒';
  @override
  String get keyMilestones => '關鍵節點';
  @override
  String get ended => '已結束';
  @override
  String get registrationDeadline => '報名截止';
  @override
  String get technicalDescription => '技術描述發布';
  @override
  String get competitionOpening => '比賽開幕';
  @override
  String get competitionClosing => '比賽閉幕';
  @override
  String get worldTimezones => '世界時區';
  @override
  String get internationalCollaboration => '國際比賽協作';

  // Header
  @override
  String get compTimerDashboard => '競賽計時儀表板';
  @override
  String get trainingMode => '訓練模式';
  @override
  String get competitionSimulation => '競賽模擬';

  // Countdown
  @override
  String get remaining => '剩餘';

  // Pomodoro
  @override
  String get focusSession => '專注訓練中';
  @override
  String get ready => '準備就緒';
  @override
  String get minutesRemaining => '剩餘時間';
  @override
  String get moduleTasks => '模組任務';
  @override
  String get current => '當前';
  @override
  String get done => '完成';
  @override
  String get upcoming => '待辦';
  @override
  String get addTask => '新增任務';

  // Milestones
  @override
  String get completed => '已完成';
  @override
  String get toolboxCheck => '工具箱檢查';
  @override
  String get infrastructureSetup => '基礎設施搭建';

  // Navigation
  @override
  String get dashboard => '儀表板';
  @override
  String get moduleTimer => '模組計時';
  @override
  String get settings => '設定';

  // Settings
  @override
  String get language => '語言';
  @override
  String get competitionCountdown => '技能大賽倒計時';
  @override
  String get countdownTarget => '目標時間';
  @override
  String get setCountdown => '設定';
  @override
  String get about => '關於';
  @override
  String get aboutDescription => 'WorldSkills 競賽專用計時器';
  @override
  String get version => '版本';

  // Module Timer
  @override
  String get moduleA => '模組 A';
  @override
  String get moduleB => '模組 B';
  @override
  String get moduleC => '模組 C';
  @override
  String get moduleD => '模組 D';
  @override
  String get inProgress => '進行中';
  @override
  String get moduleTimerTitle => '模組計時器';
  @override
  String get taskDescription => '任務描述';
  @override
  String get environment => '競賽環境';

  // Unified Timer
  @override
  String get competition => '競賽';
  @override
  String get practice => '練習';
  @override
  String get competitionModules => '競賽模組';
  @override
  String get practiceModules => '練習模組';
  @override
  String get practiceMode => '練習模式';
  @override
  String get progress => '進度';
  @override
  String get unifiedTimer => '計時器';

  // Competition Timeline
  @override
  String get arrival => '抵達';
  @override
  String get familiarization => '熟悉場地';
  @override
  String get competitionC1 => '競賽 C1';
  @override
  String get competitionC2 => '競賽 C2';
  @override
  String get closing => '閉幕';
  @override
  String get competitionProgress => '競賽進度';

  // Task Management
  @override
  String get editTask => '編輯任務';
  @override
  String get taskTitle => '任務標題';
  @override
  String get enterTaskTitle => '請輸入任務標題';
  @override
  String get estimatedDuration => '預估時間';
  @override
  String get save => '保存';
  @override
  String get cancel => '取消';
  @override
  String get confirmDeleteTask => '確認刪除任務';
  @override
  String get deleteTaskWarning => '此操作無法撤銷，確定要刪除';
  @override
  String get confirmDelete => '確認刪除';
  @override
  String get actualSpent => '實際用時';
  @override
  String get completedAt => '完成時間';
  @override
  String get close => '關閉';

  // Module Management
  @override
  String get addModule => '新增模組';
  @override
  String get editModule => '編輯模組';
  @override
  String get moduleName => '模組名稱';
  @override
  String get enterModuleName => '請輸入模組名稱';
  @override
  String get moduleDescription => '模組描述';
  @override
  String get enterModuleDescription => '請輸入模組描述';
  @override
  String get defaultDuration => '預設時長';
  @override
  String get confirmDeleteModule => '確認刪除模組';
  @override
  String get deleteModuleWarning => '此操作將刪除該模組及其所有任務，確定要刪除';
  @override
  String get customDuration => '自訂時長';

  // Timer Control
  @override
  String get stopTimer => '終止計時';
  @override
  String get confirmStopTimer => '是否要終止當前計時？計時進度將被重置。';
  @override
  String get confirmResetTimer => '是否要重置計時？當前進度將被清零。';
  @override
  String get moduleComplete => '模組完成';

  // Milestone Management
  @override
  String get addMilestone => '新增里程碑';
  @override
  String get editMilestone => '編輯里程碑';
  @override
  String get milestoneTitle => '里程碑標題';
  @override
  String get enterMilestoneTitle => '請輸入里程碑標題';
  @override
  String get targetDateTime => '目標日期時間';
  @override
  String get milestonePriority => '優先級';
  @override
  String get milestoneEvent => '事件';
  @override
  String get confirmDeleteMilestone => '確認刪除里程碑';
  @override
  String get deleteMilestoneWarning => '此操作無法撤銷，里程碑將被永久刪除。';
  @override
  String get noMilestones => '暫無里程碑';
  @override
  String get addFirstMilestone => '新增第一個里程碑';

  // White Noise
  @override
  String get whiteNoise => '白噪音';
  @override
  String get whiteNoisePlaying => '白噪音播放中';
  @override
  String get whiteNoiseStopped => '白噪音已停止';

  // Practice History
  @override
  String get practiceHistory => '練習歷史';
  @override
  String get recordsList => '記錄列表';
  @override
  String get analyticsCharts => '數據分析';
  @override
  String get moduleComparison => '模組對比';
  @override
  String get moduleEfficiency => '模組效率';
  @override
  String get timeTrend => '時間趨勢';
  @override
  String get efficiencyDistribution => '效率分佈';
  @override
  String get totalSessions => '總計劃數';
  @override
  String get totalDuration => '總耗時';
  @override
  String get completionRate => '完成率';
  @override
  String get averageDuration => '平均耗時';
  @override
  String get averageEfficiency => '平均效率';
  @override
  String get durationLabel => '耗時';
  @override
  String get completionLabel => '完成度';
  @override
  String get averageLabel => '平均';
  @override
  String get excellent => '優秀';
  @override
  String get good => '良好';
  @override
  String get fair => '一般';
  @override
  String get needsImprovement => '需改進';
  @override
  String get noRecords => '暫無練習記錄';
  @override
  String get practiceCompleted => '練習完成';
  @override
  String get loadFailed => '載入失敗';

  // Timezone Settings
  @override
  String get displayTimezone => '顯示時區';
  @override
  String get selectTimezone => '選擇時區';
  @override
  String get aiAnalysis => 'AI智慧分析';
  @override
  String get aiAnalysisDesc => '基於訓練數據的個人化分析和建議';
  @override
  String get aiInsights => 'AI洞察';
  @override
  String get aiRecommendations => '智慧建議';
  @override
  String get aiPrediction => '效能預測';
  @override
  String get overallRating => '綜合評分';
  @override
  String get confidence => '信心度';
  @override
  String get strengths => '優勢';
  @override
  String get weaknessesLabel => '待改進';
  @override
  String get talkToAI => '與AI對話';
  @override
  String get askAI => '向AI提問';
  @override
  String get generatingAnalysis => 'AI正在分析...';
  @override
  String get analysisComplete => '分析完成';
  @override
  String get noAnalysisData => '暫無分析數據';
  @override
  String get startAnalysis => '開始分析';
  @override
  String get reanalyze => '重新分析';
  @override
  String get aiServiceNotConfigured => 'AI服務未配置，請在.env中設定API金鑰';
  @override
  String get retry => '重試';
  @override
  String get send => '發送';
  @override
  String get typeYourQuestion => '輸入你的問題...';

  // AI Analysis History
  @override
  String get analysisHistory => '分析歷史';
  @override
  String get noHistoryRecords => '暫無分析歷史';
  @override
  String get clearHistory => '清空歷史';

  // Record Detail
  @override
  String get recordDetail => '記錄詳情';
  @override
  String get keyEvents => '關鍵事件';

  // Data Management
  @override
  String get clearRecords => '清空練習記錄';
  @override
  String get clearRecordsDesc => '刪除所有練習歷史記錄';
  @override
  String get clearRecordsWarning => '此操作將刪除所有練習記錄，且無法恢復。確定要清空嗎？';
  @override
  String get clearAIHistory => '清空AI分析歷史';
  @override
  String get clearAIHistoryDesc => '刪除所有AI智能分析記錄';
  @override
  String get clearAIHistoryWarning => '此操作將刪除所有AI分析歷史，且無法恢復。確定要清空嗎？';
  @override
  String get dataCleared => '已清空';

  // Month names
  @override
  List<String> get monthNames => const [
    '1月', '2月', '3月', '4月', '5月', '6月',
    '7月', '8月', '9月', '10月', '11月', '12月',
  ];
}
