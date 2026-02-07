import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/ws_colors.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/providers/white_noise_provider.dart';

class WhiteNoisePage extends ConsumerWidget {
  const WhiteNoisePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = LocaleScope.of(context);
    final isPlayingAsync = ref.watch(whiteNoisePlayingProvider);
    final isPlaying = isPlayingAsync.valueOrNull ?? false;
    final volume = ref.watch(whiteNoiseVolumeProvider);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.surround_sound_outlined,
                    size: 24,
                    color: WsColors.accentCyan,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    s.whiteNoise,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: WsColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // Waveform icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: WsColors.accentCyan.withAlpha(20),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: WsColors.accentCyan.withAlpha(60),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.graphic_eq,
                  size: 48,
                  color: isPlaying
                      ? WsColors.accentCyan
                      : WsColors.textSecondary.withAlpha(120),
                ),
              ),
              const SizedBox(height: 48),

              // Play/Pause button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(40),
                  onTap: () {
                    final service = ref.read(whiteNoiseServiceProvider);
                    if (isPlaying) {
                      service.pause();
                    } else {
                      service.playRandomPosition(
                        'assets/audio/white_noise.mp3',
                      );
                    }
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: WsColors.accentCyan,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: WsColors.accentCyan.withAlpha(40),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 32,
                      color: WsColors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Volume slider
              Row(
                children: [
                  const Icon(
                    Icons.volume_down,
                    size: 20,
                    color: WsColors.textSecondary,
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: WsColors.accentCyan,
                        inactiveTrackColor: WsColors.border,
                        thumbColor: WsColors.accentCyan,
                        overlayColor: WsColors.accentCyan.withAlpha(30),
                        trackHeight: 4,
                      ),
                      child: Slider(
                        value: volume,
                        onChanged: (newVolume) {
                          ref.read(whiteNoiseVolumeProvider.notifier).state =
                              newVolume;
                          ref
                              .read(whiteNoiseServiceProvider)
                              .setVolume(newVolume);
                        },
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.volume_up,
                    size: 20,
                    color: WsColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Status display
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: WsColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: WsColors.border),
                ),
                child: Text(
                  isPlaying ? s.whiteNoisePlaying : s.whiteNoiseStopped,
                  style: const TextStyle(
                    fontSize: 14,
                    color: WsColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
