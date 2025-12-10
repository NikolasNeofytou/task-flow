import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../theme/tokens.dart';

/// Voice message recorder widget with record/stop/cancel controls
class VoiceRecorder extends StatefulWidget {
  const VoiceRecorder({
    super.key,
    required this.onRecordingComplete,
    required this.onCancel,
  });

  final void Function(String path, Duration duration) onRecordingComplete;
  final VoidCallback onCancel;

  @override
  State<VoiceRecorder> createState() => _VoiceRecorderState();
}

class _VoiceRecorderState extends State<VoiceRecorder>
    with SingleTickerProviderStateMixin {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  bool _isInitialized = false;
  Duration _duration = Duration.zero;
  Timer? _timer;
  late AnimationController _waveController;
  String? _recordingPath;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    try {
      await _recorder.openRecorder();
      setState(() => _isInitialized = true);
    } catch (e) {
      debugPrint('Error initializing recorder: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _waveController.dispose();
    _recorder.closeRecorder();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (!_isInitialized) return;

    try {
      // Check permissions
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone permission required')),
          );
        }
        return;
      }

      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/voice_${DateTime.now().millisecondsSinceEpoch}.aac';
      
      // Start recording
      await _recorder.startRecorder(
        toFile: filePath,
        codec: Codec.aacADTS,
        bitRate: 128000,
        sampleRate: 44100,
      );

      setState(() {
        _isRecording = true;
        _duration = Duration.zero;
        _recordingPath = filePath;
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _duration = Duration(seconds: timer.tick);
          });
        }
      });
    } catch (e) {
      debugPrint('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _recorder.stopRecorder();
      _timer?.cancel();
      setState(() => _isRecording = false);

      if (_recordingPath != null && File(_recordingPath!).existsSync()) {
        widget.onRecordingComplete(_recordingPath!, _duration);
      } else {
        debugPrint('Recording file not found');
      }
    } catch (e) {
      debugPrint('Error stopping recording: $e');
    }
  }

  Future<void> _cancelRecording() async {
    try {
      if (_isRecording) {
        await _recorder.stopRecorder();
      }
      _timer?.cancel();
      setState(() {
        _isRecording = false;
        _duration = Duration.zero;
      });

      // Delete the recording file
      if (_recordingPath != null) {
        final file = File(_recordingPath!);
        if (file.existsSync()) {
          await file.delete();
        }
        _recordingPath = null;
      }

      widget.onCancel();
    } catch (e) {
      debugPrint('Error canceling recording: $e');
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          if (!_isRecording) ...[
            // Record button
            IconButton.filled(
              onPressed: _isInitialized ? _startRecording : null,
              icon: const Icon(Icons.mic),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              _isInitialized ? 'Tap to record voice message' : 'Initializing...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ] else ...[
            // Recording UI
            _WaveformAnimation(controller: _waveController),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Recording...',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    _formatDuration(_duration),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontFeatures: [const FontFeature.tabularFigures()],
                        ),
                  ),
                ],
              ),
            ),
            // Cancel button
            IconButton(
              onPressed: _cancelRecording,
              icon: const Icon(Icons.close),
              color: colorScheme.error,
            ),
            const SizedBox(width: AppSpacing.xs),
            // Stop/Send button
            IconButton.filled(
              onPressed: _stopRecording,
              icon: const Icon(Icons.send),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Animated waveform visualization during recording
class _WaveformAnimation extends StatelessWidget {
  const _WaveformAnimation({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 32,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(5, (index) {
              final delay = index * 0.15;
              final value = (controller.value + delay) % 1.0;
              final height = 8 + (24 * (0.5 + 0.5 * (value < 0.5 ? value * 2 : (1 - value) * 2)));

              return Container(
                width: 3,
                height: height,
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

/// Voice message player widget
class VoiceMessagePlayer extends StatefulWidget {
  const VoiceMessagePlayer({
    super.key,
    required this.voicePath,
    required this.duration,
    this.isMe = false,
  });

  final String voicePath;
  final Duration duration;
  final bool isMe;

  @override
  State<VoiceMessagePlayer> createState() => _VoiceMessagePlayerState();
}

class _VoiceMessagePlayerState extends State<VoiceMessagePlayer> {
  final ap.AudioPlayer _audioPlayer = ap.AudioPlayer();
  bool _isPlaying = false;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == ap.PlayerState.playing;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      try {
        // Play the recorded voice file
        await _audioPlayer.play(ap.DeviceFileSource(widget.voicePath));
      } catch (e) {
        debugPrint('Error playing voice message: $e');
        // If file doesn't exist or can't play, try asset as fallback
        try {
          await _audioPlayer.play(ap.AssetSource('sounds/success.mp3'));
        } catch (e2) {
          debugPrint('Fallback audio also failed: $e2');
        }
      }
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = widget.duration.inMilliseconds > 0
        ? _position.inMilliseconds / widget.duration.inMilliseconds
        : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Play/Pause button
          IconButton(
            onPressed: _togglePlay,
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
            style: IconButton.styleFrom(
              backgroundColor: widget.isMe
                  ? Colors.white.withOpacity(0.2)
                  : colorScheme.primaryContainer,
              foregroundColor:
                  widget.isMe ? Colors.white : colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Waveform / Progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Simple progress bar (can be replaced with waveform visualization)
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: widget.isMe
                        ? Colors.white.withOpacity(0.3)
                        : colorScheme.outline.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation(
                      widget.isMe ? Colors.white : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDuration(_isPlaying ? _position : widget.duration),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: widget.isMe
                            ? Colors.white.withOpacity(0.8)
                            : colorScheme.onSurfaceVariant,
                        fontFeatures: [const FontFeature.tabularFigures()],
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Icon(
            Icons.mic,
            size: 16,
            color: widget.isMe
                ? Colors.white.withOpacity(0.6)
                : colorScheme.onSurfaceVariant.withOpacity(0.6),
          ),
        ],
      ),
    );
  }
}
