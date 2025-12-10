import 'package:flutter/material.dart';

/// Represents the state of an audio call
enum CallState {
  idle,
  ringing,
  connecting,
  connected,
  disconnected,
  failed,
}

/// Represents a participant in an audio call
class CallParticipant {
  final String id;
  final String name;
  final String? avatarUrl;
  final bool isMuted;
  final bool isSpeaking;
  final bool isMe;

  const CallParticipant({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.isMuted = false,
    this.isSpeaking = false,
    this.isMe = false,
  });

  CallParticipant copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    bool? isMuted,
    bool? isSpeaking,
    bool? isMe,
  }) {
    return CallParticipant(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isMuted: isMuted ?? this.isMuted,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      isMe: isMe ?? this.isMe,
    );
  }

  Color get statusColor {
    if (isMuted) return Colors.grey;
    if (isSpeaking) return Colors.green;
    return Colors.blue;
  }
}

/// Represents an active audio call
class AudioCall {
  final String id;
  final String channelId;
  final String channelName;
  final CallState state;
  final List<CallParticipant> participants;
  final Duration duration;
  final bool isMuted;
  final bool isSpeakerOn;
  final DateTime startTime;

  const AudioCall({
    required this.id,
    required this.channelId,
    required this.channelName,
    required this.state,
    this.participants = const [],
    this.duration = Duration.zero,
    this.isMuted = false,
    this.isSpeakerOn = false,
    required this.startTime,
  });

  AudioCall copyWith({
    String? id,
    String? channelId,
    String? channelName,
    CallState? state,
    List<CallParticipant>? participants,
    Duration? duration,
    bool? isMuted,
    bool? isSpeakerOn,
    DateTime? startTime,
  }) {
    return AudioCall(
      id: id ?? this.id,
      channelId: channelId ?? this.channelId,
      channelName: channelName ?? this.channelName,
      state: state ?? this.state,
      participants: participants ?? this.participants,
      duration: duration ?? this.duration,
      isMuted: isMuted ?? this.isMuted,
      isSpeakerOn: isSpeakerOn ?? this.isSpeakerOn,
      startTime: startTime ?? this.startTime,
    );
  }

  int get participantCount => participants.length;

  bool get isActive => state == CallState.connected || state == CallState.connecting;

  String get durationText {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
