import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';

/// Haptic feedback types
enum HapticFeedbackType {
  /// Light tap - For button presses, card taps
  light,

  /// Medium pulse - For task creation, request sent
  medium,

  /// Success pattern - For task completed, request accepted
  success,

  /// Warning pattern - For validation errors, blocked tasks
  warning,

  /// Error pattern - For failed actions, request rejected
  error,

  /// Selection - For item selection
  selection,

  /// Impact - For significant actions
  impact,
}

/// Service for managing haptic feedback throughout the app
class HapticsService {
  HapticsService();

  bool _isEnabled = true;
  bool _hasVibrator = false;
  bool _initialized = false;

  /// Initialize the haptics service
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Check if device has vibrator
      _hasVibrator = await Vibration.hasVibrator() ?? false;
      if (kDebugMode) {
        print('HapticsService: Vibrator available: $_hasVibrator');
      }
    } catch (e) {
      if (kDebugMode) {
        print('HapticsService: Error checking vibrator: $e');
      }
      _hasVibrator = false;
    }

    _initialized = true;
  }

  /// Check if haptics are enabled
  bool get isEnabled => _isEnabled && _hasVibrator;

  /// Enable or disable haptics
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Trigger haptic feedback
  Future<void> trigger(HapticFeedbackType type) async {
    if (!isEnabled) return;

    try {
      switch (type) {
        case HapticFeedbackType.light:
          await _lightTap();
          break;
        case HapticFeedbackType.medium:
          await _mediumPulse();
          break;
        case HapticFeedbackType.success:
          await _successPattern();
          break;
        case HapticFeedbackType.warning:
          await _warningPattern();
          break;
        case HapticFeedbackType.error:
          await _errorPattern();
          break;
        case HapticFeedbackType.selection:
          await _selection();
          break;
        case HapticFeedbackType.impact:
          await _impact();
          break;
      }
    } catch (e) {
      if (kDebugMode) {
        print('HapticsService: Error triggering haptic: $e');
      }
    }
  }

  // Pattern implementations
  Future<void> _lightTap() async {
    await Vibration.vibrate(duration: 50, amplitude: 50);
  }

  Future<void> _mediumPulse() async {
    await Vibration.vibrate(duration: 100, amplitude: 128);
  }

  Future<void> _successPattern() async {
    // Quick double pulse
    await Vibration.vibrate(duration: 70, amplitude: 100);
    await Future.delayed(const Duration(milliseconds: 50));
    await Vibration.vibrate(duration: 70, amplitude: 150);
  }

  Future<void> _warningPattern() async {
    // Two medium pulses
    await Vibration.vibrate(duration: 80, amplitude: 120);
    await Future.delayed(const Duration(milliseconds: 100));
    await Vibration.vibrate(duration: 80, amplitude: 120);
  }

  Future<void> _errorPattern() async {
    // Three short sharp pulses
    for (int i = 0; i < 3; i++) {
      await Vibration.vibrate(duration: 50, amplitude: 255);
      if (i < 2) await Future.delayed(const Duration(milliseconds: 80));
    }
  }

  Future<void> _selection() async {
    await Vibration.vibrate(duration: 30, amplitude: 80);
  }

  Future<void> _impact() async {
    await Vibration.vibrate(duration: 150, amplitude: 200);
  }

  /// Custom vibration pattern
  Future<void> customPattern({
    required int duration,
    int amplitude = 128,
  }) async {
    if (!isEnabled) return;

    try {
      await Vibration.vibrate(
        duration: duration,
        amplitude: amplitude.clamp(0, 255),
      );
    } catch (e) {
      if (kDebugMode) {
        print('HapticsService: Error with custom pattern: $e');
      }
    }
  }

  /// Cancel ongoing vibration
  Future<void> cancel() async {
    try {
      await Vibration.cancel();
    } catch (e) {
      if (kDebugMode) {
        print('HapticsService: Error canceling vibration: $e');
      }
    }
  }
}
