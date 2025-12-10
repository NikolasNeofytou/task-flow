import 'audio_service.dart';
import 'haptics_service.dart';

/// Feedback type combining haptics and sound
enum FeedbackType {
  /// Light interaction - button tap, card selection
  lightTap,

  /// Medium interaction - creating items, sending
  mediumImpact,

  /// Successful action - completed, accepted
  success,

  /// Warning - validation error, blocked
  warning,

  /// Error - failed action, rejected
  error,

  /// Selection - item selected from list
  selection,

  /// Navigation - tab change, page transition
  navigation,
}

/// Combined service for haptic and audio feedback
class FeedbackService {
  FeedbackService({
    required this.hapticsService,
    required this.audioService,
  });

  final HapticsService hapticsService;
  final AudioService audioService;

  /// Initialize both services
  Future<void> initialize() async {
    await Future.wait([
      hapticsService.initialize(),
      audioService.initialize(),
    ]);
  }

  /// Trigger combined feedback (haptics + sound)
  Future<void> trigger(FeedbackType type) async {
    switch (type) {
      case FeedbackType.lightTap:
        await Future.wait([
          hapticsService.trigger(HapticFeedbackType.light),
          audioService.play(SoundEffect.tap),
        ]);
        break;

      case FeedbackType.mediumImpact:
        await Future.wait([
          hapticsService.trigger(HapticFeedbackType.medium),
          audioService.play(SoundEffect.tap),
        ]);
        break;

      case FeedbackType.success:
        await Future.wait([
          hapticsService.trigger(HapticFeedbackType.success),
          audioService.play(SoundEffect.success),
        ]);
        break;

      case FeedbackType.warning:
        await Future.wait([
          hapticsService.trigger(HapticFeedbackType.warning),
          audioService.play(SoundEffect.error),
        ]);
        break;

      case FeedbackType.error:
        await Future.wait([
          hapticsService.trigger(HapticFeedbackType.error),
          audioService.play(SoundEffect.error),
        ]);
        break;

      case FeedbackType.selection:
        await hapticsService.trigger(HapticFeedbackType.selection);
        break;

      case FeedbackType.navigation:
        await hapticsService.trigger(HapticFeedbackType.light);
        break;
    }
  }

  /// Trigger only haptic feedback
  Future<void> haptic(HapticFeedbackType type) async {
    await hapticsService.trigger(type);
  }

  /// Trigger only audio feedback
  Future<void> sound(SoundEffect effect) async {
    await audioService.play(effect);
  }
}
