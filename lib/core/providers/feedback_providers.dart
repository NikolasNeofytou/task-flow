import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/audio_service.dart';
import '../services/feedback_service.dart';
import '../services/haptics_service.dart';

/// Haptics service provider
final hapticsServiceProvider = Provider<HapticsService>((ref) {
  return HapticsService();
});

/// Audio service provider
final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Combined feedback service provider
final feedbackServiceProvider = Provider<FeedbackService>((ref) {
  return FeedbackService(
    hapticsService: ref.watch(hapticsServiceProvider),
    audioService: ref.watch(audioServiceProvider),
  );
});

/// State provider for haptics enabled/disabled
final hapticsEnabledProvider = StateProvider<bool>((ref) => true);

/// State provider for sound enabled/disabled
final soundEnabledProvider = StateProvider<bool>((ref) => true);

/// State provider for sound volume (0.0 to 1.0)
final soundVolumeProvider = StateProvider<double>((ref) => 0.5);

/// Watch settings and update services
class FeedbackSettingsNotifier extends Notifier<void> {
  @override
  void build() {
    final hapticsEnabled = ref.watch(hapticsEnabledProvider);
    final soundEnabled = ref.watch(soundEnabledProvider);
    final volume = ref.watch(soundVolumeProvider);

    final haptics = ref.read(hapticsServiceProvider);
    final audio = ref.read(audioServiceProvider);

    haptics.setEnabled(hapticsEnabled);
    audio.setEnabled(soundEnabled);
    audio.setVolume(volume);
  }
}

final feedbackSettingsProvider = NotifierProvider<FeedbackSettingsNotifier, void>(
  FeedbackSettingsNotifier.new,
);
