import 'dart:async';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../core/constants/ws_colors.dart';
import '../../core/i18n/locale_provider.dart';
import 'module_model.dart';
import 'module_list_panel.dart';

class ModuleTimerPage extends StatefulWidget {
  const ModuleTimerPage({super.key});

  @override
  State<ModuleTimerPage> createState() => _ModuleTimerPageState();
}

class _ModuleTimerPageState extends State<ModuleTimerPage> {
  int _selectedIndex = 1; // Default to "in progress" module
  late Timer _timer;
  Duration _elapsed = Duration.zero;
  bool _isRunning = false;

  static const _modules = [
    ModuleModel(
      id: 'A',
      name: 'Module A - Design',
      description:
          'Create responsive web design mockups and implement HTML/CSS layouts according to specifications.',
      duration: Duration(hours: 3),
      status: ModuleStatus.completed,
      tasks: [
        'Wireframe Design',
        'HTML Structure',
        'CSS Styling',
        'Responsive Layout',
      ],
    ),
    ModuleModel(
      id: 'B',
      name: 'Module B - Frontend',
      description:
          'Build interactive frontend components with JavaScript frameworks and client-side logic.',
      duration: Duration(hours: 3),
      status: ModuleStatus.inProgress,
      tasks: [
        'Component Architecture',
        'State Management',
        'API Integration',
        'Form Validation',
      ],
    ),
    ModuleModel(
      id: 'C',
      name: 'Module C - Backend',
      description:
          'Develop server-side APIs, database schemas, and business logic implementation.',
      duration: Duration(hours: 3),
      status: ModuleStatus.upcoming,
      tasks: [
        'Database Design',
        'REST API Endpoints',
        'Authentication',
        'Data Validation',
      ],
    ),
    ModuleModel(
      id: 'D',
      name: 'Module D - Integration',
      description:
          'Connect frontend and backend, deploy application, and perform integration testing.',
      duration: Duration(hours: 3),
      status: ModuleStatus.upcoming,
      tasks: [
        'API Connection',
        'Error Handling',
        'Performance Optimization',
        'Final Testing',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isRunning) {
        setState(() {
          _elapsed += const Duration(seconds: 1);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = LocaleScope.of(context);
    final module = _modules[_selectedIndex];
    final totalSeconds = module.duration.inSeconds;
    final elapsedSeconds = _elapsed.inSeconds.clamp(0, totalSeconds);
    final remainingDuration =
        Duration(seconds: totalSeconds - elapsedSeconds);
    final progress = totalSeconds > 0 ? elapsedSeconds / totalSeconds : 0.0;

    final rHours = remainingDuration.inHours;
    final rMinutes = remainingDuration.inMinutes % 60;
    final rSeconds = remainingDuration.inSeconds % 60;

    return Row(
      children: [
        // Left: Module list
        Container(
          width: 280,
          margin: const EdgeInsets.only(left: 20, top: 16, bottom: 16),
          decoration: BoxDecoration(
            color: WsColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: WsColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(8),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: ModuleListPanel(
            modules: _modules,
            selectedIndex: _selectedIndex,
            onSelect: (i) {
              setState(() {
                _selectedIndex = i;
                _elapsed = Duration.zero;
                _isRunning = false;
              });
            },
          ),
        ),
        // Right: Timer + details
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Module name
                Text(
                  module.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: WsColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                // Timer ring using CircularPercentIndicator
                CircularPercentIndicator(
                  radius: 110.0,
                  lineWidth: 8.0,
                  percent: progress.clamp(0.0, 1.0),
                  center: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${rHours.toString().padLeft(2, '0')}:${rMinutes.toString().padLeft(2, '0')}:${rSeconds.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontFamily: 'JetBrainsMono',
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: WsColors.darkBlue,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s.remaining.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: WsColors.textSecondary,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  progressColor: WsColors.accentCyan,
                  backgroundColor: WsColors.secondaryMint.withAlpha(60),
                  circularStrokeCap: CircularStrokeCap.round,
                  animation: true,
                  animationDuration: 300,
                  animateFromLastPercent: true,
                ),
                const SizedBox(height: 20),
                // Controls
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildCircleButton(
                      icon: Icons.refresh,
                      onTap: () => setState(() {
                        _elapsed = Duration.zero;
                        _isRunning = false;
                      }),
                    ),
                    const SizedBox(width: 16),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () =>
                            setState(() => _isRunning = !_isRunning),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 10),
                          decoration: BoxDecoration(
                            color: WsColors.accentCyan,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _isRunning ? Icons.pause : Icons.play_arrow,
                                color: WsColors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isRunning
                                    ? s.pause.toUpperCase()
                                    : s.start.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: WsColors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Task description + environment
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Description
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: WsColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: WsColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.taskDescription,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: WsColors.textSecondary,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              module.description,
                              style: const TextStyle(
                                fontSize: 13,
                                color: WsColors.textPrimary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Tasks checklist
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: WsColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: WsColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.moduleTasks.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: WsColors.textSecondary,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            ...module.tasks.map((task) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    children: [
                                      Icon(
                                        module.status ==
                                                ModuleStatus.completed
                                            ? Icons.check_circle
                                            : Icons.radio_button_unchecked,
                                        size: 14,
                                        color: module.status ==
                                                ModuleStatus.completed
                                            ? WsColors.accentGreen
                                            : WsColors.textSecondary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        task,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: WsColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: WsColors.textSecondary.withAlpha(60),
            ),
          ),
          child: Icon(icon, size: 18, color: WsColors.textSecondary),
        ),
      ),
    );
  }
}
