import 'strings.dart';

class ZhStrings implements AppStrings {
  const ZhStrings();

  @override
  String get appTitle => 'SkillCount';
  @override
  String get countdown => '倒计时';
  @override
  String get pomodoro => '训练计时';
  @override
  String get milestones => '里程碑';
  @override
  String get timezone => '时区';
  @override
  String get openingCeremony => '世界技能大赛开幕式';
  @override
  String get shanghai2026 => '上海 2026';
  @override
  String get skillPomodoro => '技能训练计时器';
  @override
  String get trainingTimer => '训练计时器';
  @override
  String get start => '开始';
  @override
  String get pause => '暂停';
  @override
  String get reset => '重置';
  @override
  String get resume => '继续';
  @override
  String get restart => '重新开始';
  @override
  String get days => '天';
  @override
  String get hours => '时';
  @override
  String get minutes => '分';
  @override
  String get seconds => '秒';
  @override
  String get keyMilestones => '关键节点';
  @override
  String get ended => '已结束';
  @override
  String get registrationDeadline => '报名截止';
  @override
  String get technicalDescription => '技术描述发布';
  @override
  String get competitionOpening => '比赛开幕';
  @override
  String get competitionClosing => '比赛闭幕';
  @override
  String get worldTimezones => '世界时区';
  @override
  String get internationalCollaboration => '国际比赛协作';

  // Header
  @override
  String get compTimerDashboard => '竞赛计时仪表板';
  @override
  String get trainingMode => '训练模式';
  @override
  String get competitionSimulation => '竞赛模拟';

  // Countdown
  @override
  String get remaining => '剩余';

  // Pomodoro
  @override
  String get focusSession => '专注训练中';
  @override
  String get ready => '准备就绪';
  @override
  String get minutesRemaining => '剩余时间';
  @override
  String get moduleTasks => '模块任务';
  @override
  String get current => '当前';
  @override
  String get done => '完成';
  @override
  String get upcoming => '待办';
  @override
  String get addTask => '添加任务';

  // Milestones
  @override
  String get completed => '已完成';
  @override
  String get toolboxCheck => '工具箱检查';
  @override
  String get infrastructureSetup => '基础设施搭建';

  // Navigation
  @override
  String get dashboard => '仪表板';
  @override
  String get moduleTimer => '模块计时';
  @override
  String get settings => '设置';

  // Settings
  @override
  String get language => '语言';
  @override
  String get competitionCountdown => '技能大赛倒计时';
  @override
  String get countdownTarget => '目标时间';
  @override
  String get setCountdown => '设置';
  @override
  String get about => '关于';
  @override
  String get aboutDescription => 'WorldSkills 竞赛专用计时器';
  @override
  String get version => '版本';

  // Module Timer
  @override
  String get moduleA => '模块 A';
  @override
  String get moduleB => '模块 B';
  @override
  String get moduleC => '模块 C';
  @override
  String get moduleD => '模块 D';
  @override
  String get inProgress => '进行中';
  @override
  String get moduleTimerTitle => '模块计时器';
  @override
  String get taskDescription => '任务描述';
  @override
  String get environment => '竞赛环境';

  // Unified Timer
  @override
  String get competition => '竞赛';
  @override
  String get practice => '练习';
  @override
  String get competitionModules => '竞赛模块';
  @override
  String get practiceModules => '练习模块';
  @override
  String get practiceMode => '练习模式';
  @override
  String get progress => '进度';
  @override
  String get unifiedTimer => '计时器';

  // Competition Timeline
  @override
  String get arrival => '抵达';
  @override
  String get familiarization => '熟悉场地';
  @override
  String get competitionC1 => '竞赛 C1';
  @override
  String get competitionC2 => '竞赛 C2';
  @override
  String get closing => '闭幕';
  @override
  String get competitionProgress => '竞赛进度';

  // Task Management
  @override
  String get editTask => '编辑任务';
  @override
  String get taskTitle => '任务标题';
  @override
  String get enterTaskTitle => '请输入任务标题';
  @override
  String get estimatedDuration => '预估时间';
  @override
  String get save => '保存';
  @override
  String get cancel => '取消';
  @override
  String get confirmDeleteTask => '确认删除任务';
  @override
  String get deleteTaskWarning => '此操作无法撤销，确定要删除';
  @override
  String get confirmDelete => '确认删除';
  @override
  String get actualSpent => '实际用时';
  @override
  String get completedAt => '完成时间';
  @override
  String get close => '关闭';

  // Module Management
  @override
  String get addModule => '添加模块';
  @override
  String get editModule => '编辑模块';
  @override
  String get moduleName => '模块名称';
  @override
  String get enterModuleName => '请输入模块名称';
  @override
  String get moduleDescription => '模块描述';
  @override
  String get enterModuleDescription => '请输入模块描述';
  @override
  String get defaultDuration => '默认时长';
  @override
  String get confirmDeleteModule => '确认删除模块';
  @override
  String get deleteModuleWarning => '此操作将删除该模块及其所有任务，确定要删除';
  @override
  String get customDuration => '自定义时长';

  // Timer Control
  @override
  String get stopTimer => '终止计时';
  @override
  String get confirmStopTimer => '是否要终止当前计时？计时进度将被重置。';
  @override
  String get confirmResetTimer => '是否要重置计时？当前进度将被清零。';
  @override
  String get moduleComplete => '模块完成';

  // Milestone Management
  @override
  String get addMilestone => '添加里程碑';
  @override
  String get editMilestone => '编辑里程碑';
  @override
  String get milestoneTitle => '里程碑标题';
  @override
  String get enterMilestoneTitle => '请输入里程碑标题';
  @override
  String get targetDateTime => '目标日期时间';
  @override
  String get milestonePriority => '优先级';
  @override
  String get milestoneEvent => '事件';
  @override
  String get confirmDeleteMilestone => '确认删除里程碑';
  @override
  String get deleteMilestoneWarning => '此操作无法撤销，里程碑将被永久删除。';
  @override
  String get noMilestones => '暂无里程碑';
  @override
  String get addFirstMilestone => '添加第一个里程碑';

  // White Noise
  @override
  String get whiteNoise => '白噪音';
  @override
  String get whiteNoisePlaying => '白噪音播放中';
  @override
  String get whiteNoiseStopped => '白噪音已停止';

  // Practice History
  @override
  String get practiceHistory => '练习历史';
  @override
  String get recordsList => '记录列表';
  @override
  String get analyticsCharts => '数据分析';
  @override
  String get moduleComparison => '模块对比';
  @override
  String get moduleEfficiency => '模块效率';
  @override
  String get timeTrend => '时间趋势';
  @override
  String get efficiencyDistribution => '效率分布';
  @override
  String get totalSessions => '总计划数';
  @override
  String get totalDuration => '总耗时';
  @override
  String get completionRate => '完成率';
  @override
  String get averageDuration => '平均耗时';
  @override
  String get averageEfficiency => '平均效率';
  @override
  String get durationLabel => '耗时';
  @override
  String get completionLabel => '完成度';
  @override
  String get averageLabel => '平均';
  @override
  String get excellent => '优秀';
  @override
  String get good => '良好';
  @override
  String get fair => '一般';
  @override
  String get needsImprovement => '需改进';
  @override
  String get noRecords => '暂无练习记录';
  @override
  String get practiceCompleted => '练习完成';
  @override
  String get loadFailed => '加载失败';
  @override
  String get displayTimezone => '显示时区';
  @override
  String get selectTimezone => '选择时区';
  @override
  String get aiAnalysis => 'AI智能分析';
  @override
  String get aiAnalysisDesc => '基于训练数据的个性化分析和建议';
  @override
  String get aiInsights => 'AI洞察';
  @override
  String get aiRecommendations => '智能建议';
  @override
  String get aiPrediction => '性能预测';
  @override
  String get overallRating => '综合评分';
  @override
  String get confidence => '信心度';
  @override
  String get strengths => '优势';
  @override
  String get weaknessesLabel => '待改进';
  @override
  String get talkToAI => '与AI对话';
  @override
  String get askAI => '向AI提问';
  @override
  String get generatingAnalysis => 'AI正在分析...';
  @override
  String get analysisComplete => '分析完成';
  @override
  String get noAnalysisData => '暂无分析数据';
  @override
  String get startAnalysis => '开始分析';
  @override
  String get reanalyze => '重新分析';
  @override
  String get aiServiceNotConfigured => 'AI服务未配置，请在.env中设置API密钥';
  @override
  String get retry => '重试';
  @override
  String get send => '发送';
  @override
  String get typeYourQuestion => '输入你的问题...';

  // AI Analysis History
  @override
  String get analysisHistory => '分析历史';
  @override
  String get noHistoryRecords => '暂无分析历史';
  @override
  String get clearHistory => '清空历史';

  // Record Detail
  @override
  String get recordDetail => '记录详情';
  @override
  String get keyEvents => '关键事件';

  // Data Management
  @override
  String get clearRecords => '清空练习记录';
  @override
  String get clearRecordsDesc => '删除所有练习历史记录';
  @override
  String get clearRecordsWarning => '此操作将删除所有练习记录，且无法恢复。确定要清空吗？';
  @override
  String get clearAIHistory => '清空AI分析历史';
  @override
  String get clearAIHistoryDesc => '删除所有AI智能分析记录';
  @override
  String get clearAIHistoryWarning => '此操作将删除所有AI分析历史，且无法恢复。确定要清空吗？';
  @override
  String get dataCleared => '已清空';
}
