import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Sound effect types
enum SoundEffect {
  /// Light tap sound for buttons
  tap,

  /// Success/completion sound
  success,

  /// Error/failure sound
  error,

  /// Notification received sound
  notification,

  /// Message/request sent sound
  sent,
}

/// Service for managing audio feedback throughout the app
class AudioService {
  AudioService();

  final AudioPlayer _player = AudioPlayer();
  bool _isEnabled = true;
  bool _initialized = false;
  double _volume = 0.5;

  /// Initialize the audio service
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await _player.setVolume(_volume);
      await _player.setReleaseMode(ReleaseMode.stop);
      if (kDebugMode) {
        print('AudioService: Initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('AudioService: Error initializing: $e');
      }
    }

    _initialized = true;
  }

  /// Check if audio is enabled
  bool get isEnabled => _isEnabled;

  /// Get current volume (0.0 to 1.0)
  double get volume => _volume;

  /// Enable or disable audio
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _player.setVolume(_volume);
  }

  /// Play a sound effect
  Future<void> play(SoundEffect effect) async {
    if (!isEnabled || !_initialized) return;

    final soundPath = _getSoundPath(effect);

    try {
      // Play the sound effect
      await _player.play(AssetSource(soundPath));
      
      if (kDebugMode) {
        print('AudioService: Playing sound: $soundPath');
      }
    } catch (e) {
      if (kDebugMode) {
        print('AudioService: Error playing sound $soundPath: $e');
      }
    }
  }

  /// Stop currently playing sound
  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (e) {
      if (kDebugMode) {
        print('AudioService: Error stopping sound: $e');
      }
    }
  }

  /// Get sound file path for effect
  String _getSoundPath(SoundEffect effect) {
    switch (effect) {
      case SoundEffect.tap:
        return 'sounds/tap.mp3';
      case SoundEffect.success:
        return 'sounds/success.mp3';
      case SoundEffect.error:
        return 'sounds/error.mp3';
      case SoundEffect.notification:
        return 'sounds/notification.mp3';
      case SoundEffect.sent:
        return 'sounds/sent.mp3';
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _player.dispose();
  }
}
