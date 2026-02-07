import 'dart:math';
import 'package:just_audio/just_audio.dart';

class WhiteNoiseService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> initialize() async {
    await _player.setLoopMode(LoopMode.one);
  }

  Future<void> playRandomPosition(String assetPath) async {
    // Load asset if not already loaded or if stopped
    if (_player.processingState == ProcessingState.idle ||
        _player.processingState == ProcessingState.completed) {
      await _player.setAsset(assetPath);
    }

    final duration = _player.duration;
    if (duration != null && duration > Duration.zero) {
      final randomPosition = Duration(
        milliseconds: Random().nextInt(duration.inMilliseconds),
      );
      await _player.seek(randomPosition);
    }

    await _player.play();
  }

  Future<void> pause() => _player.pause();

  Future<void> stop() => _player.stop();

  Future<void> setVolume(double volume) =>
      _player.setVolume(volume.clamp(0.0, 1.0));

  Stream<bool> get playingStream => _player.playingStream;

  bool get isPlaying => _player.playing;

  void dispose() => _player.dispose();
}
