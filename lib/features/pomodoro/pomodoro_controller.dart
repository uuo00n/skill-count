import 'dart:async';

class PomodoroController {
  Duration totalDuration;
  Duration remaining;
  bool isRunning = false;
  Timer? _timer;
  final void Function() onTick;

  PomodoroController({
    required this.totalDuration,
    required this.onTick,
  }) : remaining = totalDuration;

  void start() {
    if (isRunning) return;
    isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (remaining.inSeconds > 0) {
        remaining -= const Duration(seconds: 1);
        onTick();
      } else {
        pause();
      }
    });
    onTick();
  }

  void pause() {
    _timer?.cancel();
    isRunning = false;
    onTick();
  }

  void reset() {
    _timer?.cancel();
    isRunning = false;
    remaining = totalDuration;
    onTick();
  }

  void setDuration(Duration duration) {
    _timer?.cancel();
    isRunning = false;
    totalDuration = duration;
    remaining = duration;
    onTick();
  }

  void dispose() {
    _timer?.cancel();
  }
}
