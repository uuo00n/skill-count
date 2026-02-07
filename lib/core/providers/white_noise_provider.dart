import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/white_noise/white_noise_service.dart';

final whiteNoiseServiceProvider = Provider<WhiteNoiseService>((ref) {
  final service = WhiteNoiseService();
  service.initialize();
  ref.onDispose(() => service.dispose());
  return service;
});

final whiteNoisePlayingProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(whiteNoiseServiceProvider);
  return service.playingStream;
});

final whiteNoiseVolumeProvider = StateProvider<double>((ref) => 0.7);
