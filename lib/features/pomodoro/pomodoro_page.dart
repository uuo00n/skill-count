import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/ws_colors.dart';
import '../../core/i18n/locale_provider.dart';
import 'pomodoro_controller.dart';

class _TaskItem {
  String title;
  String status; // 'current', 'done', 'upcoming'
  int? estimatedMinutes;

  _TaskItem({
    required this.title,
    required this.status,
    this.estimatedMinutes,
  });
}

class PomodoroPage extends StatefulWidget {
  const PomodoroPage({super.key});

  @override
  State<PomodoroPage> createState() => _PomodoroPageState();
}

class _PomodoroPageState extends State<PomodoroPage> {
  late PomodoroController _controller;
  int _selectedMinutes = 90;

  static const _durationOptions = [45, 60, 90, 120, 180];

  final List<_TaskItem> _tasks = [
    _TaskItem(
      title: 'Implement REST API Endpoints',
      status: 'current',
      estimatedMinutes: 15,
    ),
    _TaskItem(title: 'Database Schema Design', status: 'done'),
    _TaskItem(title: 'Setup Project Repository', status: 'done'),
    _TaskItem(
      title: 'Frontend Component Integration',
      status: 'upcoming',
      estimatedMinutes: 25,
    ),
    _TaskItem(
      title: 'Unit Testing & Debugging',
      status: 'upcoming',
      estimatedMinutes: 30,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = PomodoroController(
      totalDuration: const Duration(minutes: 90),
      onTick: () => setState(() {}),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int get _completedCount => _tasks.where((t) => t.status == 'done').length;

  void _toggleTask(int index) {
    setState(() {
      final task = _tasks[index];
      if (task.status == 'done') {
        task.status = 'upcoming';
      } else {
        task.status = 'done';
      }
    });
  }

  void _addTask(String title) {
    setState(() {
      _tasks.add(_TaskItem(
        title: title,
        status: 'upcoming',
        estimatedMinutes: 15,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = LocaleScope.of(context);
    final progress = _controller.totalDuration.inSeconds > 0
        ? _controller.remaining.inSeconds / _controller.totalDuration.inSeconds
        : 0.0;
    final minutes = _controller.remaining.inMinutes;
    final seconds = _controller.remaining.inSeconds % 60;

    return Row(
      children: [
        // Left: circular timer
        Expanded(
          flex: 3,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Status label
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _controller.isRunning
                            ? WsColors.accentGreen
                            : WsColors.accentYellow,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _controller.isRunning
                          ? s.focusSession.toUpperCase()
                          : s.ready.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: WsColors.accentYellow,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Ring timer
                SizedBox(
                  width: 280,
                  height: 280,
                  child: CustomPaint(
                    painter: _RingPainter(progress: progress),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontFamily: 'JetBrainsMono',
                              fontSize: 52,
                              fontWeight: FontWeight.bold,
                              color: WsColors.white,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            s.minutesRemaining.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: WsColors.textSecondary,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                // Controls
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildCircleButton(
                      icon: Icons.refresh,
                      onTap: _controller.reset,
                    ),
                    const SizedBox(width: 20),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: _controller.isRunning
                            ? _controller.pause
                            : _controller.start,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: WsColors.darkBlue,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: WsColors.accentBlue.withAlpha(80),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _controller.isRunning
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: WsColors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _controller.isRunning
                                    ? s.pause.toUpperCase()
                                    : s.start.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 14,
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
                    const SizedBox(width: 20),
                    _buildCircleButton(
                      icon: Icons.tune,
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Right: task panel
        Container(
          width: 320,
          margin: const EdgeInsets.only(right: 20, top: 16, bottom: 16),
          decoration: BoxDecoration(
            color: WsColors.bgPanel.withAlpha(200),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF1e3a5f),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Text(
                    s.moduleTasks,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: WsColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: WsColors.accentBlue.withAlpha(25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$_completedCount/${_tasks.length}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: WsColors.accentBlue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Web Technologies · Module C',
                style: TextStyle(
                  fontSize: 12,
                  color: WsColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              // Duration selector
              Row(
                children: _durationOptions.map((m) {
                  final isSelected = _selectedMinutes == m;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(6),
                          onTap: _controller.isRunning
                              ? null
                              : () {
                                  setState(() => _selectedMinutes = m);
                                  _controller.setDuration(
                                    Duration(minutes: m),
                                  );
                                },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? WsColors.accentBlue.withAlpha(30)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isSelected
                                    ? WsColors.accentBlue
                                    : WsColors.textSecondary.withAlpha(40),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${m}m',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? WsColors.accentBlue
                                      : WsColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              // Task list
              Expanded(
                child: ListView.builder(
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) {
                    final task = _tasks[index];
                    return _buildTaskItem(
                      s,
                      task,
                      index,
                    );
                  },
                ),
              ),
              // Add task button
              const SizedBox(height: 8),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _showAddTaskDialog(context, s),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: WsColors.textSecondary.withAlpha(40),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add, size: 16, color: WsColors.textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          s.addTask,
                          style: const TextStyle(
                            fontSize: 12,
                            color: WsColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddTaskDialog(BuildContext context, dynamic s) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: WsColors.bgPanel,
        title: Text(s.addTask,
            style: const TextStyle(color: WsColors.textPrimary)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: WsColors.textPrimary),
          decoration: InputDecoration(
            hintText: s.taskDescription,
            hintStyle: const TextStyle(color: WsColors.textSecondary),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: WsColors.accentBlue),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.reset,
                style: const TextStyle(color: WsColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                _addTask(controller.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: Text(s.start,
                style: const TextStyle(color: WsColors.accentBlue)),
          ),
        ],
      ),
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

  Widget _buildTaskItem(dynamic s, _TaskItem task, int index) {
    final isCurrent = task.status == 'current';
    final isDone = task.status == 'done';

    Color statusColor;
    String statusLabel;
    if (isDone) {
      statusColor = WsColors.accentGreen;
      statusLabel = s.done.toUpperCase();
    } else if (isCurrent) {
      statusColor = WsColors.accentYellow;
      statusLabel = s.current.toUpperCase();
    } else {
      statusColor = WsColors.textSecondary;
      statusLabel = s.upcoming.toUpperCase();
    }

    return GestureDetector(
      onTap: () => _toggleTask(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCurrent
              ? WsColors.accentYellow.withAlpha(15)
              : WsColors.bgDeep.withAlpha(120),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isCurrent
                ? WsColors.accentYellow.withAlpha(60)
                : const Color(0xFF1e3a5f),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                if (task.estimatedMinutes != null && !isDone) ...[
                  const SizedBox(width: 6),
                  Text(
                    '${task.estimatedMinutes} MIN',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: WsColors.textSecondary,
                    ),
                  ),
                ],
                const Spacer(),
                if (isDone)
                  const Icon(Icons.check_circle, size: 16, color: WsColors.accentGreen)
                else if (!isCurrent)
                  const Icon(Icons.radio_button_unchecked,
                      size: 16, color: WsColors.textSecondary),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              task.title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                color: WsColors.textPrimary,
                decoration: isDone ? TextDecoration.lineThrough : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;

  _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const strokeWidth = 6.0;

    final bgPaint = Paint()
      ..color = const Color(0xFF1e3a5f)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()
      ..color = WsColors.accentYellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
