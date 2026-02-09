import 'dart:async';

/// 计时器模式
enum TimerMode { countDown, countUp }

/// 统一计时器抽象接口
///
/// 所有计时器（竞赛倒计时、练习正计时等）均实现此接口，
/// 确保 API 一致性，方便 UI 组件复用。
abstract class BaseTimerController {
  Stream<Duration> get timeUpdates;
  Duration get remaining;
  Duration get elapsed;
  double get progress;
  bool get isRunning;
  bool get isCompleted;
  TimerMode get mode;

  void start();
  void pause();
  void reset();
  void dispose();
}

/// 竞赛计时器实现
///
/// 支持 countDown（倒计时）和 countUp（正计时）两种模式，
/// 使用原生 [Timer.periodic] 驱动，每秒更新。
class CompetitionTimer implements BaseTimerController {
  final Duration _totalDuration;
  final TimerMode _mode;

  Timer? _timer;
  Duration _elapsed = Duration.zero;
  bool _isRunning = false;
  bool _isCompleted = false;

  /// 墙钟时间追踪：记录本次 start 的时刻
  DateTime? _startedAt;

  /// 暂停前已累积的时间
  Duration _accumulatedBeforePause = Duration.zero;

  final _controller = StreamController<Duration>.broadcast();

  CompetitionTimer({
    required Duration totalDuration,
    TimerMode mode = TimerMode.countDown,
  })  : _totalDuration = totalDuration,
        _mode = mode;

  // — 接口实现 ——————————————————————————————

  @override
  Stream<Duration> get timeUpdates => _controller.stream;

  @override
  Duration get remaining {
    if (_mode == TimerMode.countDown) {
      final r = _totalDuration - _elapsed;
      return r.isNegative ? Duration.zero : r;
    }
    return _totalDuration - _elapsed;
  }

  @override
  Duration get elapsed => _elapsed;

  @override
  double get progress {
    if (_totalDuration.inMilliseconds == 0) return 0;
    final p = _elapsed.inMilliseconds / _totalDuration.inMilliseconds;
    return p.clamp(0.0, 1.0);
  }

  @override
  bool get isRunning => _isRunning;

  @override
  bool get isCompleted => _isCompleted;

  @override
  TimerMode get mode => _mode;

  Duration get totalDuration => _totalDuration;

  // — 控制方法 ——————————————————————————————

  @override
  void start() {
    if (_isRunning || _isCompleted) return;
    _isRunning = true;
    _startedAt = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsed =
          _accumulatedBeforePause + DateTime.now().difference(_startedAt!);
      _controller.add(remaining);

      if (_mode == TimerMode.countDown && remaining <= Duration.zero) {
        _isCompleted = true;
        pause();
      }
    });
    _controller.add(remaining);
  }

  @override
  void pause() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    _accumulatedBeforePause = _elapsed;
    _startedAt = null;
    _controller.add(remaining);
  }

  @override
  void reset() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    _isCompleted = false;
    _elapsed = Duration.zero;
    _accumulatedBeforePause = Duration.zero;
    _startedAt = null;
    _controller.add(remaining);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}
