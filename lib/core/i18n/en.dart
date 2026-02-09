import 'strings.dart';

class EnStrings implements AppStrings {
  const EnStrings();

  @override
  String get appTitle => 'SkillCount';
  @override
  String get countdown => 'Countdown';
  @override
  String get pomodoro => 'Pomodoro';
  @override
  String get milestones => 'Milestones';
  @override
  String get timezone => 'Timezone';
  @override
  String get openingCeremony => 'WorldSkills Opening Ceremony';
  @override
  String get shanghai2026 => 'Shanghai 2026';
  @override
  String get skillPomodoro => 'Skill Pomodoro';
  @override
  String get trainingTimer => 'Training Timer';
  @override
  String get start => 'Start';
  @override
  String get pause => 'Pause';
  @override
  String get reset => 'Reset';
  @override
  String get resume => 'Resume';
  @override
  String get restart => 'Restart';
  @override
  String get days => 'Days';
  @override
  String get hours => 'Hours';
  @override
  String get minutes => 'Minutes';
  @override
  String get seconds => 'Seconds';
  @override
  String get keyMilestones => 'Key Milestones';
  @override
  String get ended => 'Ended';
  @override
  String get registrationDeadline => 'Registration Deadline';
  @override
  String get technicalDescription => 'Technical Description';
  @override
  String get competitionOpening => 'Competition Opening';
  @override
  String get competitionClosing => 'Competition Closing';
  @override
  String get worldTimezones => 'World Timezones';
  @override
  String get internationalCollaboration => 'International Collaboration';

  // Header
  @override
  String get compTimerDashboard => 'COMP TIMER DASHBOARD';
  @override
  String get trainingMode => 'TRAINING MODE';
  @override
  String get competitionSimulation => 'COMPETITION SIMULATION';

  // Countdown
  @override
  String get remaining => 'REMAINING';

  // Pomodoro
  @override
  String get focusSession => 'FOCUS SESSION';
  @override
  String get ready => 'READY';
  @override
  String get minutesRemaining => 'MINUTES REMAINING';
  @override
  String get moduleTasks => 'Module Tasks';
  @override
  String get current => 'CURRENT';
  @override
  String get done => 'DONE';
  @override
  String get upcoming => 'UPCOMING';
  @override
  String get addTask => 'Add Task';

  // Milestones
  @override
  String get completed => 'COMPLETED';
  @override
  String get toolboxCheck => 'Toolbox Check';
  @override
  String get infrastructureSetup => 'Infrastructure Setup';

  // Navigation
  @override
  String get dashboard => 'Dashboard';
  @override
  String get moduleTimer => 'Module Timer';
  @override
  String get settings => 'Settings';

  // Settings
  @override
  String get language => 'Language';
  @override
  String get competitionCountdown => 'Competition Countdown';
  @override
  String get countdownTarget => 'Target Time';
  @override
  String get setCountdown => 'Set';
  @override
  String get about => 'About';
  @override
  String get aboutDescription => 'WorldSkills Competition Timer';
  @override
  String get version => 'Version';

  // Module Timer
  @override
  String get moduleA => 'Module A';
  @override
  String get moduleB => 'Module B';
  @override
  String get moduleC => 'Module C';
  @override
  String get moduleD => 'Module D';
  @override
  String get inProgress => 'IN PROGRESS';
  @override
  String get moduleTimerTitle => 'Module Timer';
  @override
  String get taskDescription => 'Task Description';
  @override
  String get environment => 'Environment';

  // Unified Timer
  @override
  String get competition => 'Competition';
  @override
  String get practice => 'Practice';
  @override
  String get competitionModules => 'Competition Modules';
  @override
  String get practiceModules => 'Practice Modules';
  @override
  String get practiceMode => 'Practice Mode';
  @override
  String get progress => 'Progress';
  @override
  String get unifiedTimer => 'Timer';

  // Competition Timeline
  @override
  String get arrival => 'ARRIVAL';
  @override
  String get familiarization => 'FAMILIARIZATION';
  @override
  String get competitionC1 => 'COMPETITION C1';
  @override
  String get competitionC2 => 'COMPETITION C2';
  @override
  String get closing => 'CLOSING';
  @override
  String get competitionProgress => 'Competition Progress';

  // Task Management
  @override
  String get editTask => 'Edit Task';
  @override
  String get taskTitle => 'Task Title';
  @override
  String get enterTaskTitle => 'Enter task title';
  @override
  String get estimatedDuration => 'Estimated Duration';
  @override
  String get save => 'Save';
  @override
  String get cancel => 'Cancel';
  @override
  String get confirmDeleteTask => 'Confirm Delete Task';
  @override
  String get deleteTaskWarning => 'This action cannot be undone. Delete';
  @override
  String get confirmDelete => 'Delete';
  @override
  String get actualSpent => 'Actual Spent';
  @override
  String get completedAt => 'Completed At';
  @override
  String get close => 'Close';

  // Module Management
  @override
  String get addModule => 'Add Module';
  @override
  String get editModule => 'Edit Module';
  @override
  String get moduleName => 'Module Name';
  @override
  String get enterModuleName => 'Enter module name';
  @override
  String get moduleDescription => 'Module Description';
  @override
  String get enterModuleDescription => 'Enter module description';
  @override
  String get defaultDuration => 'Default Duration';
  @override
  String get confirmDeleteModule => 'Confirm Delete Module';
  @override
  String get deleteModuleWarning => 'This action will delete the module and all its tasks. Delete';
  @override
  String get customDuration => 'Custom Duration';

  // Timer Control
  @override
  String get stopTimer => 'Stop Timer';
  @override
  String get confirmStopTimer => 'Do you want to stop the current timer? Timer progress will be reset.';
  @override
  String get confirmResetTimer => 'Do you want to reset the timer? Current progress will be cleared.';
  @override
  String get moduleComplete => 'Module Complete';

  // Milestone Management
  @override
  String get addMilestone => 'Add Milestone';
  @override
  String get editMilestone => 'Edit Milestone';
  @override
  String get milestoneTitle => 'Milestone Title';
  @override
  String get enterMilestoneTitle => 'Enter milestone title';
  @override
  String get targetDateTime => 'Target Date & Time';
  @override
  String get milestonePriority => 'Priority';
  @override
  String get milestoneEvent => 'Event';
  @override
  String get confirmDeleteMilestone => 'Confirm Delete Milestone';
  @override
  String get deleteMilestoneWarning => 'This action cannot be undone. The milestone will be permanently removed.';
  @override
  String get noMilestones => 'No milestones yet';
  @override
  String get addFirstMilestone => 'Add your first milestone';

  // White Noise
  @override
  String get whiteNoise => 'White Noise';
  @override
  String get whiteNoisePlaying => 'White Noise Playing';
  @override
  String get whiteNoiseStopped => 'White Noise Stopped';

  // Practice History
  @override
  String get practiceHistory => 'Practice History';
  @override
  String get recordsList => 'Records';
  @override
  String get analyticsCharts => 'Analytics';
  @override
  String get moduleComparison => 'Module Comparison';
  @override
  String get moduleEfficiency => 'Module Efficiency';
  @override
  String get timeTrend => 'Time Trend';
  @override
  String get efficiencyDistribution => 'Efficiency Distribution';
  @override
  String get totalSessions => 'Total Sessions';
  @override
  String get totalDuration => 'Total Duration';
  @override
  String get completionRate => 'Completion Rate';
  @override
  String get averageDuration => 'Avg Duration';
  @override
  String get averageEfficiency => 'Average Efficiency';
  @override
  String get durationLabel => 'Duration';
  @override
  String get completionLabel => 'Completion';
  @override
  String get averageLabel => 'Average';
  @override
  String get excellent => 'Excellent';
  @override
  String get good => 'Good';
  @override
  String get fair => 'Fair';
  @override
  String get needsImprovement => 'Needs Improvement';
  @override
  String get noRecords => 'No practice records yet';
  @override
  String get practiceCompleted => 'Practice Completed';
  @override
  String get loadFailed => 'Failed to load';
  @override
  String get displayTimezone => 'Display Timezone';
  @override
  String get selectTimezone => 'Select Timezone';
  @override
  String get aiAnalysis => 'AI Analysis';
  @override
  String get aiAnalysisDesc => 'Personalized analysis and recommendations based on training data';
  @override
  String get aiInsights => 'AI Insights';
  @override
  String get aiRecommendations => 'Smart Recommendations';
  @override
  String get aiPrediction => 'Performance Prediction';
  @override
  String get overallRating => 'Overall Rating';
  @override
  String get confidence => 'Confidence';
  @override
  String get strengths => 'Strengths';
  @override
  String get weaknessesLabel => 'Weaknesses';
  @override
  String get talkToAI => 'Chat with AI';
  @override
  String get askAI => 'Ask AI';
  @override
  String get generatingAnalysis => 'AI is analyzing...';
  @override
  String get analysisComplete => 'Analysis Complete';
  @override
  String get noAnalysisData => 'No analysis data';
  @override
  String get startAnalysis => 'Start Analysis';
  @override
  String get reanalyze => 'Re-analyze';
  @override
  String get aiServiceNotConfigured => 'AI service not configured. Set API key in .env file';
  @override
  String get retry => 'Retry';
  @override
  String get send => 'Send';
  @override
  String get typeYourQuestion => 'Type your question...';

  // AI Analysis History
  @override
  String get analysisHistory => 'Analysis History';
  @override
  String get noHistoryRecords => 'No analysis history';
  @override
  String get clearHistory => 'Clear History';

  // Record Detail
  @override
  String get recordDetail => 'Record Detail';
  @override
  String get keyEvents => 'Key Events';

  // Data Management
  @override
  String get clearRecords => 'Clear Practice Records';
  @override
  String get clearRecordsDesc => 'Delete all practice history records';
  @override
  String get clearRecordsWarning => 'This will delete all practice records and cannot be undone. Are you sure?';
  @override
  String get clearAIHistory => 'Clear AI Analysis History';
  @override
  String get clearAIHistoryDesc => 'Delete all AI analysis records';
  @override
  String get clearAIHistoryWarning => 'This will delete all AI analysis history and cannot be undone. Are you sure?';
  @override
  String get dataCleared => 'Cleared';
}
