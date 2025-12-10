import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/audio_call_models.dart';

/// Provider for managing audio call state
final audioCallProvider = StateNotifierProvider<AudioCallNotifier, AudioCall?>((ref) {
  return AudioCallNotifier();
});

class AudioCallNotifier extends StateNotifier<AudioCall?> {
  AudioCallNotifier() : super(null);

  Timer? _durationTimer;

  /// Start a new audio call
  Future<void> startCall({
    required String channelId,
    required String channelName,
    List<CallParticipant> initialParticipants = const [],
  }) async {
    final callId = DateTime.now().millisecondsSinceEpoch.toString();
    
    state = AudioCall(
      id: callId,
      channelId: channelId,
      channelName: channelName,
      state: CallState.connecting,
      participants: initialParticipants,
      startTime: DateTime.now(),
    );

    // Simulate connection delay
    await Future.delayed(const Duration(seconds: 2));

    if (state?.id == callId) {
      state = state?.copyWith(state: CallState.connected);
      _startDurationTimer();
    }
  }

  /// Join an existing call
  Future<void> joinCall(String callId) async {
    if (state?.id != callId) return;

    state = state?.copyWith(state: CallState.connecting);

    await Future.delayed(const Duration(seconds: 1));

    if (state?.id == callId) {
      state = state?.copyWith(state: CallState.connected);
      _startDurationTimer();
    }
  }

  /// End the current call
  void endCall() {
    _durationTimer?.cancel();
    _durationTimer = null;
    state = null;
  }

  /// Toggle mute for current user
  void toggleMute() {
    if (state == null) return;
    state = state!.copyWith(isMuted: !state!.isMuted);

    // Update own participant mute status
    final participants = state!.participants.map((p) {
      if (p.isMe) {
        return p.copyWith(isMuted: state!.isMuted);
      }
      return p;
    }).toList();

    state = state!.copyWith(participants: participants);
  }

  /// Toggle speaker on/off
  void toggleSpeaker() {
    if (state == null) return;
    state = state!.copyWith(isSpeakerOn: !state!.isSpeakerOn);
  }

  /// Add a participant to the call
  void addParticipant(CallParticipant participant) {
    if (state == null) return;
    
    final participants = [...state!.participants, participant];
    state = state!.copyWith(participants: participants);
  }

  /// Remove a participant from the call
  void removeParticipant(String participantId) {
    if (state == null) return;

    final participants = state!.participants.where((p) => p.id != participantId).toList();
    state = state!.copyWith(participants: participants);
  }

  /// Update participant speaking state (simulated)
  void updateParticipantSpeaking(String participantId, bool isSpeaking) {
    if (state == null) return;

    final participants = state!.participants.map((p) {
      if (p.id == participantId) {
        return p.copyWith(isSpeaking: isSpeaking);
      }
      return p;
    }).toList();

    state = state!.copyWith(participants: participants);
  }

  /// Toggle mute for a specific participant (admin function)
  void toggleParticipantMute(String participantId) {
    if (state == null) return;

    final participants = state!.participants.map((p) {
      if (p.id == participantId) {
        return p.copyWith(isMuted: !p.isMuted);
      }
      return p;
    }).toList();

    state = state!.copyWith(participants: participants);
  }

  /// Start tracking call duration
  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state == null) {
        timer.cancel();
        return;
      }

      final elapsed = DateTime.now().difference(state!.startTime);
      state = state!.copyWith(duration: elapsed);
    });
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    super.dispose();
  }
}
